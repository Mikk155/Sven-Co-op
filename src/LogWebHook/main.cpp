#include <string>
#include <string_view>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <thread>
#include <mutex>
#include <queue>
#include <condition_variable>
#include <atomic>
#include <chrono>

#include "../aslp/utils/curl.hpp"

namespace std { using ::_snprintf; }
#include <nlohmann/json.hpp>
#include <fmt/format.h>

#ifdef CURL_EXTERNAL_TEST
#include <windows.h>
#else
#include <extdll.h>
#include <meta_api.h>
#include <h_export.h>
#include <pm_defs.h>
#endif

using string = std::string;
using string_view = std::string_view;
using json = nlohmann::json;
namespace filesystem = std::filesystem;
using namespace std::string_view_literals;

string g_webhook_url;
std::vector<std::string> g_headers = {};
string g_structure;
size_t g_message_pos;

std::queue<string> g_queue;
std::condition_variable g_conditional;
std::atomic<bool> g_running = false;
std::thread g_worker;
std::mutex g_mutex;

#ifdef CURL_EXTERNAL_TEST
#define LOG_ARGS(fmt_str, ...) fmt::print( "[LogWebHook] " fmt_str "\n", __VA_ARGS__ )
#define LOG(fmt_str) fmt::print( "[LogWebHook] " fmt_str "\n" )
#else
#define LOG_ARGS(fmt_str, ...) ALERT( at_console, fmt::format( "[LogWebHook] " fmt_str "\n", __VA_ARGS__).c_str() )
#define LOG(fmt_str, ...) ALERT( at_console, "[LogWebHook] " fmt_str "\n" )
#endif

static bool LoadJsonConfig()
{
	g_headers.resize(0);
	g_webhook_url.clear();
	g_structure.clear();

#ifdef CURL_EXTERNAL_TEST
    filesystem::path fileName = filesystem::current_path() / ".."/".."/"LogWebHook"/"LogWebHook.json";
#else
    filesystem::path fileName = filesystem::current_path() / "svencoop"/"addons"/"metamod"/"dlls"/"LogWebHook.json";
#endif

	string fileNameString = fileName.string();

	if( !filesystem::exists( fileName ) )
	{
		LOG_ARGS( "Couldn't find file \"{}\"", fileNameString.c_str() );
		return false;
	}

	std::ifstream fileStream( fileNameString.c_str() );

	if( !fileStream.is_open() )
	{
		LOG_ARGS( "Couldn't open file \"{}\"", fileNameString.c_str() );
		return false;
	}

	try
	{
		json configObject = json::parse( fileStream, nullptr, true, true );

		auto getString = [&]( string_view key, string& value )
		{
			if( auto it = configObject.find( key ); it != configObject.end() )
			{
				value = it->get<string>();
			}
			else
			{
				throw std::runtime_error( fmt::format( "Missing required string field \"{}\"", string(key) ) );
			}
		};

		getString( "webhook"sv, g_webhook_url );

		if( auto it = configObject.find( "structure" ); it != configObject.end() )
		{
			g_structure = it.value().dump();

			// Test if the structure is all right
			g_message_pos = g_structure.find( "%1" );

			if( g_message_pos == std::string::npos )
			{
				throw std::runtime_error( "Missing formatter keyword \"%1\" in the \"structure\" field." );
			}
		}
		else
		{
			throw std::runtime_error( "Missing required object field \"structure\"" );
		}

		if( auto it = configObject.find( "headers" ); it != configObject.end() )
		{
			for( const auto& item : it.value() )
			{
				g_headers.push_back( item.get<string>() );
			}
		}
		else
		{
			throw std::runtime_error( "Missing required array of string field \"headers\"" );
		}
	}
	catch( const std::exception& exception )
	{
		LOG_ARGS( "Couldn't parse json file \"{}\"", fileNameString.c_str() );
		LOG_ARGS( "Error: \"{}\"", exception.what() );
		return false;
	}

	return true;
}

void Worker()
{
	while( g_running )
	{
		std::unique_lock lock( g_mutex );

		g_conditional.wait( lock, []{ return !g_queue.empty() || !g_running; } );

		if( !g_running )
			break;

		if( !curl::IsActive() )
		{
		    std::this_thread::sleep_for( std::chrono::seconds( 5 ) );
			continue;
		}

		string message = std::move( g_queue.front() );
		g_queue.pop();
		size_t size = g_queue.size();
		lock.unlock();

		string body = string( g_structure );
	    body.replace( g_message_pos, 2, message );

		curl::Request req = {
			.url = g_webhook_url,
			.post = std::move( body ),
			.headers = g_headers
		};

		auto response = req.Perform();

		auto dynamicSleepTime = [&]() -> std::chrono::milliseconds
		{
			constexpr int min_delay = 200;
			constexpr int max_delay = 3000;

			if( size == 0 )
				return std::chrono::milliseconds( max_delay );

			if( size > 50 )
				return std::chrono::milliseconds( min_delay );

//                return std::chrono::milliseconds( static_cast<int>( max_delay - std::min( size / 50.0, 1.0 ) * ( max_delay - min_delay ) ) );
			return std::chrono::milliseconds( static_cast<int>( max_delay - min( size / 50.0, 1.0 ) * ( max_delay - min_delay ) ) );
		};

		std::this_thread::sleep_for( dynamicSleepTime() );
	}
}

static bool Initialize()
{
	if( g_running )
		return true;

	if( !curl::Initialize() )
	{
		LOG( "Could not load libcurl!" );
		return false;
	}

	if( !LoadJsonConfig() )
	{
		LOG( "Could not parse config. plugin will stay disabled until the file is modified." );
		return false;
	}

	g_running = true;
	g_worker = std::thread( Worker );

	return true;
}

void Shutdown()
{
	if( !g_running )
		return;

	std::lock_guard lock( g_mutex );
	std::queue<string> empty;
	std::swap( g_queue, empty );

	g_running = false;

	g_conditional.notify_all();

	if( g_worker.joinable() )
	{
		g_worker.join();
	}
}

void SendWebhookMessage( const char* buffer )
{
	string message = buffer;
	{
		std::lock_guard lock( g_mutex );
		g_queue.push( std::move( message ) );
	}

	g_conditional.notify_one();
}

#ifndef CURL_EXTERNAL_TEST
static bool inAlertMessageContext = false;
static void AlertMessage( ALERT_TYPE type, const char *szFmt, ... )
{
	if( inAlertMessageContext || !g_running || !szFmt || !curl::IsActive() || g_webhook_url.empty() )
		RETURN_META( META_RES::MRES_IGNORED );

	switch( type )
	{
		case ALERT_TYPE::at_notice:
		{
			break;
		}
		case ALERT_TYPE::at_console:
		{
			if( auto level = (int)CVAR_GET_FLOAT( "developer" ); level < 1 )
				RETURN_META( META_RES::MRES_IGNORED );
			break;
		}
		case ALERT_TYPE::at_aiconsole:
		{
			if( auto level = (int)CVAR_GET_FLOAT( "developer" ); level < 2 )
				RETURN_META( META_RES::MRES_IGNORED );
			break;
		}
		case ALERT_TYPE::at_warning:
		case ALERT_TYPE::at_error:
		case ALERT_TYPE::at_logged:
		{
			break;
		}
	}

	char buffer[2048];

	va_list ap;
	va_start(ap, szFmt);
	vsnprintf(buffer, sizeof(buffer), szFmt, ap);
	va_end(ap);

	inAlertMessageContext = true;
	LOG_ARGS( "Sending {}", buffer );
	inAlertMessageContext = false;

	SendWebhookMessage( buffer );

	RETURN_META( META_RES::MRES_IGNORED );
}

static void ServerActivate( edict_t* edictList, int edictCount, int clientMax )
{
	RETURN_META( META_RES::MRES_IGNORED );
}

static void StartFrame()
{
	RETURN_META( META_RES::MRES_IGNORED );
}

// Description of plugin
plugin_info_t Plugin_info = {
	META_INTERFACE_VERSION, // ifvers
	"Game Logs Webhook", // name
	"1.0", // version
	"2025", // date
	"Mikk", // author
	"https://github.com/Mikk155/Sven-Co-op", // url
	"LOGWEBHOOK", // logtag, all caps please
	PT_ANYTIME, // (when) loadable
	PT_ANYTIME, // (when) unloadable
};

enginefuncs_t g_engfuncs;
globalvars_t  *gpGlobals;

// Receive engine function table from engine.
// This appears to be the _first_ DLL routine called by the engine, so we
// do some setup operations here.
void WINAPI GiveFnptrsToDll( enginefuncs_t* pengfuncsFromEngine, globalvars_t *pGlobals )
{
	memcpy( &g_engfuncs, pengfuncsFromEngine, sizeof(enginefuncs_t) );
	gpGlobals = pGlobals;
}
// Global vars from metamod:
gamedll_funcs_t* gpGamedllFuncs;	// gameDLL function tables
mutil_funcs_t* gpMetaUtilFuncs;	// metamod utility functions
meta_globals_t* gpMetaGlobals;		// metamod globals

C_DLLEXPORT int Meta_Query( const char* interfaceVersion, plugin_info_t** pPlugInfo, mutil_funcs_t* pMetaUtilFuncs )
{
	gpMetaUtilFuncs = pMetaUtilFuncs;
	*pPlugInfo = &Plugin_info;
	return TRUE;
}

static DLL_FUNCTIONS gFunctionTable_Post = 
{
	NULL, // pfnGameInit
	NULL, // pfnSpawn
	NULL, // pfnThink
	NULL, // pfnUse
	NULL, // pfnTouch
	NULL, // pfnBlocked
	NULL, // pfnKeyValue
	NULL, // pfnSave
	NULL, // pfnRestore
	NULL, // pfnSetAbsBox
	NULL, // pfnSaveWriteFields
	NULL, // pfnSaveReadFields
	NULL, // pfnSaveGlobalState
	NULL, // pfnRestoreGlobalState
	NULL, // pfnResetGlobalState
	NULL, // pfnClientConnect
	NULL, // pfnClientDisconnect
	NULL, // pfnClientKill
	NULL, // pfnClientPutInServer
	NULL, // pfnClientCommand
	NULL, // pfnClientUserInfoChanged
	ServerActivate, // pfnServerActivate
	NULL, // pfnServerDeactivate
	NULL, // pfnPlayerPreThink
	NULL, // pfnPlayerPostThink
	StartFrame, // pfnStartFrame
	NULL, // pfnParmsNewLevel
	NULL, // pfnParmsChangeLevel
	NULL, // pfnGetGameDescription
	NULL, // pfnPlayerCustomization
	NULL, // pfnSpectatorConnect
	NULL, // pfnSpectatorDisconnect
	NULL, // pfnSpectatorThink
	NULL, // pfnSys_Error
	NULL, // pfnPM_Move
	NULL, // pfnPM_Init
	NULL, // pfnPM_FindTextureType
	NULL, // pfnSetupVisibility
	NULL, // pfnUpdateClientData
	NULL, // pfnAddToFullPack
	NULL, // pfnCreateBaseline
	NULL, // pfnRegisterEncoders
	NULL, // pfnGetWeaponData
	NULL, // pfnCmdStart
	NULL, // pfnCmdEnd
	NULL, // pfnConnectionlessPacket
	NULL, // pfnGetHullBounds
	NULL, // pfnCreateInstancedBaselines
	NULL, // pfnInconsistentFile
	NULL, // pfnAllowLagCompensation
};

static enginefuncs_t meta_engfuncs = 
{
	NULL, // pfnPrecacheModel()
	NULL, // pfnPrecacheSound()
	NULL, // pfnSetModel()
	NULL, // pfnModelIndex()
	NULL, // pfnModelFrames()
	NULL, // pfnSetSize()
	NULL, // pfnChangeLevel()
	NULL, // pfnGetSpawnParms()
	NULL, // pfnSaveSpawnParms()
	NULL, // pfnVecToYaw()
	NULL, // pfnVecToAngles()
	NULL, // pfnMoveToOrigin()
	NULL, // pfnChangeYaw()
	NULL, // pfnChangePitch()
	NULL, // pfnFindEntityByString()
	NULL, // pfnGetEntityIllum()
	NULL, // pfnFindEntityInSphere()
	NULL, // pfnFindClientInPVS()
	NULL, // pfnEntitiesInPVS()
	NULL, // pfnMakeVectors()
	NULL, // pfnAngleVectors()
	NULL, // pfnCreateEntity()
	NULL, // pfnRemoveEntity()
	NULL, // pfnCreateNamedEntity()
	NULL, // pfnMakeStatic()
	NULL, // pfnEntIsOnFloor()
	NULL, // pfnDropToFloor()
	NULL, // pfnWalkMove()
	NULL, // pfnSetOrigin()
	NULL, // pfnEmitSound()
	NULL, // pfnEmitAmbientSound()
	NULL, // pfnTraceLine()
	NULL, // pfnTraceToss()
	NULL, // pfnTraceMonsterHull()
	NULL, // pfnTraceHull()
	NULL, // pfnTraceModel()
	NULL, // pfnTraceTexture()
	NULL, // pfnTraceSphere()
	NULL, // pfnGetAimVector()
	NULL, // pfnServerCommand()
	NULL, // pfnServerExecute()
	NULL, // pfnClientCommand()
	NULL, // pfnParticleEffect()
	NULL, // pfnLightStyle()
	NULL, // pfnDecalIndex()
	NULL, // pfnPointContents()
	NULL, // pfnMessageBegin()
	NULL, // pfnMessageEnd()
	NULL, // pfnWriteByte()
	NULL, // pfnWriteChar()
	NULL, // pfnWriteShort()
	NULL, // pfnWriteLong()
	NULL, // pfnWriteAngle()
	NULL, // pfnWriteCoord()
	NULL, // pfnWriteString()
	NULL, // pfnWriteEntity()
	NULL, // pfnCVarRegister()
	NULL, // pfnCVarGetFloat()
	NULL, // pfnCVarGetString()
	NULL, // pfnCVarSetFloat()
	NULL, // pfnCVarSetString()
	AlertMessage, // pfnAlertMessage()
	NULL, // pfnEngineFprintf()
	NULL, // pfnPvAllocEntPrivateData()
	NULL, // pfnPvEntPrivateData()
	NULL, // pfnFreeEntPrivateData()
	NULL, // pfnSzFromIndex()
	NULL, // pfnAllocString()
	NULL, // pfnGetVarsOfEnt()
	NULL, // pfnPEntityOfEntOffset()
	NULL, // pfnEntOffsetOfPEntity()
	NULL, // pfnIndexOfEdict()
	NULL, // pfnPEntityOfEntIndex()
	NULL, // pfnFindEntityByVars()
	NULL, // pfnGetModelPtr()
	NULL, // pfnRegUserMsg()
	NULL, // pfnAnimationAutomove()
	NULL, // pfnGetBonePosition()
	NULL, // pfnFunctionFromName()
	NULL, // pfnNameForFunction()
	NULL, // pfnClientPrintf()
	NULL, // pfnServerPrint()
	NULL, // pfnCmd_Args()
	NULL, // pfnCmd_Argv()
	NULL, // pfnCmd_Argc()
	NULL, // pfnGetAttachment()
	NULL, // pfnCRC32_Init()
	NULL, // pfnCRC32_ProcessBuffer()
	NULL, // pfnCRC32_ProcessByte()
	NULL, // pfnCRC32_Final()
	NULL, // pfnRandomLong()
	NULL, // pfnRandomFloat()
	NULL, // pfnSetView()
	NULL, // pfnTime()
	NULL, // pfnCrosshairAngle()
	NULL, // pfnLoadFileForMe()
	NULL, // pfnFreeFile()
	NULL, // pfnEndSection()
	NULL, // pfnCompareFileTime()
	NULL, // pfnGetGameDir()
	NULL, // pfnCvar_RegisterVariable()
	NULL, // pfnFadeClientVolume()
	NULL, // pfnSetClientMaxspeed()
	NULL, // pfnCreateFakeClient()
	NULL, // pfnRunPlayerMove()
	NULL, // pfnNumberOfEntities()
	NULL, // pfnGetInfoKeyBuffer()
	NULL, // pfnInfoKeyValue()
	NULL, // pfnSetKeyValue()
	NULL, // pfnSetClientKeyValue()
	NULL, // pfnIsMapValid()
	NULL, // pfnStaticDecal()
	NULL, // pfnPrecacheGeneric()
	NULL, // pfnGetPlayerUserId()
	NULL, // pfnBuildSoundMsg()
	NULL, // pfnIsDedicatedServer()
	NULL, // pfnCVarGetPointer()
	NULL, // pfnGetPlayerWONId()
	NULL, // pfnInfo_RemoveKey()
	NULL, // pfnGetPhysicsKeyValue()
	NULL, // pfnSetPhysicsKeyValue()
	NULL, // pfnGetPhysicsInfoString()
	NULL, // pfnPrecacheEvent()
	NULL, // pfnPlaybackEvent()
	NULL, // pfnSetFatPVS()
	NULL, // pfnSetFatPAS()
	NULL, // pfnCheckVisibility()
	NULL, // pfnDeltaSetField()
	NULL, // pfnDeltaUnsetField()
	NULL, // pfnDeltaAddEncoder()
	NULL, // pfnGetCurrentPlayer()
	NULL, // pfnCanSkipPlayer()
	NULL, // pfnDeltaFindField()
	NULL, // pfnDeltaSetFieldByIndex()
	NULL, // pfnDeltaUnsetFieldByIndex()
	NULL, // pfnSetGroupMask()
	NULL, // pfnCreateInstancedBaseline()
	NULL, // pfnCvar_DirectSet()
	NULL, // pfnForceUnmodified()
	NULL, // pfnGetPlayerStats()
	NULL, // pfnAddServerCommand()
	// Added in SDK 2.2:
	NULL, // pfnVoice_GetClientListening()
	NULL, // pfnVoice_SetClientListening()
	// Added for HL 1109 (no SDK update):
	NULL, // pfnGetPlayerAuthId()
	// Added 2003/11/10 (no SDK update):
	NULL, // pfnSequenceGet()
	NULL, // pfnSequencePickSentence()
	NULL, // pfnGetFileSize()
	NULL, // pfnGetApproxWavePlayLen()
	NULL, // pfnIsCareerMatch()
	NULL, // pfnGetLocalizedStringLength()
	NULL, // pfnRegisterTutorMessageShown()
	NULL, // pfnGetTimesTutorMessageShown()
	NULL, // pfnProcessTutorMessageDecayBuffer()
	NULL, // pfnConstructTutorMessageDecayBuffer()
	NULL, // pfnResetTutorMessageDecayData()
	// Added Added 2005-08-11 (no SDK update)
	NULL, // pfnQueryClientCvarValue()
	// Added Added 2005-11-22 (no SDK update)
	NULL, // pfnQueryClientCvarValue2()
	// Added 2009-06-17 (no SDK update)
	NULL, // pfnEngCheckParm()
};

#define REGISTER_TABLE( name, table, version, type ) \
C_DLLEXPORT int name( type* pFunctionTable, int* interfaceVersion ) { \
	if( !pFunctionTable ) { \
		ALERT( at_logged, #name " called with null pFunctionTable" ); \
		return(FALSE); \
	} \
	else if( *interfaceVersion != version ) { \
		ALERT( at_logged, fmt::format( #name " version mismatch; requested = {} ours = {}", *interfaceVersion, version ).c_str() ); \
		*interfaceVersion = version; \
		return(FALSE); \
	} \
	memcpy( pFunctionTable, &table, sizeof(type) ); \
	return (TRUE); \
}

REGISTER_TABLE( GetEntityAPI2_Post, gFunctionTable_Post, INTERFACE_VERSION, DLL_FUNCTIONS )
REGISTER_TABLE( GetEngineFunctions, meta_engfuncs, ENGINE_INTERFACE_VERSION, enginefuncs_t )

// Must provide at least one of these..
static META_FUNCTIONS gMetaFunctionTable = {
	NULL,			// pfnGetEntityAPI				HL SDK; called before game DLL
	NULL,			// pfnGetEntityAPI_Post			META; called after game DLL
	NULL,	// pfnGetEntityAPI2				HL SDK2; called before game DLL
	GetEntityAPI2_Post,			// pfnGetEntityAPI2_Post		META; called after game DLL
	NULL,			// pfnGetNewDLLFunctions		HL SDK2; called before game DLL
	NULL,			// pfnGetNewDLLFunctions_Post	META; called after game DLL
	GetEngineFunctions,	// pfnGetEngineFunctions	META; called before HL engine
	NULL,			// pfnGetEngineFunctions_Post	META; called after HL engine
};

C_DLLEXPORT int Meta_Attach( PLUG_LOADTIME, META_FUNCTIONS* pFunctionTable, meta_globals_t* pMGlobals, gamedll_funcs_t* pGamedllFuncs )
{
	if( !pFunctionTable || !gpMetaUtilFuncs->pfnGetEngineHandle() || !gpMetaUtilFuncs->pfnGetEngineBase() )
		return FALSE;

	gpMetaGlobals = pMGlobals;
	memcpy( pFunctionTable, &gMetaFunctionTable, sizeof(META_FUNCTIONS) );
	return Initialize() ? TRUE : FALSE;
}

C_DLLEXPORT int Meta_Detach( PLUG_LOADTIME, PL_UNLOAD_REASON )
{
	Shutdown();
	curl::Shutdown();
	return TRUE;
}
#else
int main()
{
	while( true )
	{
		if( !Initialize() )
			continue;

		string line;
		std::getline( std::cin, line );
		if( line == "quit" )
		{
			break;
		}
		else if( line == "refresh" )
		{
			Shutdown();
		}
		else if( g_running )
		{
			SendWebhookMessage( line.c_str() );
		}
        std::this_thread::sleep_for( std::chrono::seconds(1) );
    }

	Shutdown();
	curl::Shutdown();

	return 1;
}
#endif
