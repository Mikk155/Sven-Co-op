/*
 * Copyright (c) 2001-2006 Will Day <willday@hpgx.net>
 *
 *    This file is part of Metamod.
 *
 *    Metamod is free software; you can redistribute it and/or modify it
 *    under the terms of the GNU General Public License as published by the
 *    Free Software Foundation; either version 2 of the License, or (at
 *    your option) any later version.
 *
 *    Metamod is distributed in the hope that it will be useful, but
 *    WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Metamod; if not, write to the Free Software Foundation,
 *    Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *    In addition, as a special exception, the author gives permission to
 *    link the code of this program with the Half-Life Game Engine ("HL
 *    Engine") and Modified Game Libraries ("MODs") developed by Valve,
 *    L.L.C ("Valve").  You must obey the GNU General Public License in all
 *    respects for all of the code used other than the HL Engine and MODs
 *    from Valve.  If you modify this file, you may extend this exception
 *    to your version of the file, but you are not obligated to do so.  If
 *    you do not wish to do so, delete this exception statement from your
 *    version.
 *
 */

#include <extdll.h>
#include <meta_api.h>
#include <h_export.h>
#include <pm_defs.h>

#include "asext_api.h"
#include "aslp.h"

#include <fmt/format.h>
#include <windows.h>

#include "Hooks/KeyValue.hpp"
#include "Hooks/ModelIndex.hpp"
#include "Hooks/PM_Move.hpp"
#include "Hooks/PrecacheModel.hpp"
#include "Hooks/ServerActivate.hpp"
#include "Hooks/ServerDeactivate.hpp"
#include "Hooks/SetModel.hpp"
#include "Hooks/ShouldCollide.hpp"
#include "Hooks/UserMessage.hpp"
#include "Hooks/AddToFullPack.hpp"
#include "Hooks/ClientCommand.hpp"
#include "Hooks/ClientUserInfoChanged.hpp"

static NEW_DLL_FUNCTIONS gNewDllFunctionTable =
{
	NULL,
	NULL,
	Hooks::Pre::ShouldCollide,
	// Added 2005/08/11 (no SDK update):
	NULL, //void(*pfnCvarValue)(const edict_t *pEnt, const char *value);
	// Added 2005/11/21 (no SDK update):
	//    value is "Bad CVAR request" on failure (i.e that user is not connected or the cvar does not exist).
	//    value is "Bad Player" if invalid player edict.
	NULL,//void(*pfnCvarValue2)(const edict_t *pEnt, int requestID, const char *cvarName, const char *value);
};

static DLL_FUNCTIONS gFunctionTable = {
	NULL, // pfnGameInit
	NULL, // pfnSpawn
	NULL, // pfnThink
	NULL, // pfnUse
	NULL, // pfnTouch
	NULL, // pfnBlocked
	Hooks::Pre::KeyValue,
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
	Hooks::Pre::ClientCommand,
	Hooks::Pre::ClientUserInfoChanged,
	Hooks::Pre::ServerActivate, 
	NULL, // pfnServerDeactivate
	NULL, // pfnPlayerPreThink
	NULL, // pfnPlayerPostThink
	NULL, // pfnStartFrame
	NULL, // pfnParmsNewLevel
	NULL, // pfnParmsChangeLevel
	NULL, // pfnGetGameDescription
	NULL, // pfnPlayerCustomization
	NULL, // pfnSpectatorConnect
	NULL, // pfnSpectatorDisconnect
	NULL, // pfnSpectatorThink
	NULL, // pfnSys_Error
	Hooks::Pre::PM_Move,
	NULL, // pfnPM_Init
	NULL, // pfnPM_FindTextureType
	NULL, // pfnSetupVisibility
	NULL, // pfnUpdateClientData
	Hooks::Pre::AddToFullPack,
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

static DLL_FUNCTIONS gFunctionTable_Post = {
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
	Hooks::Post::ServerActivate, 
	Hooks::Post::ServerDeactivate,
	NULL, // pfnPlayerPreThink
	NULL, // pfnPlayerPostThink
	NULL, // pfnStartFrame
	NULL, // pfnParmsNewLevel
	NULL, // pfnParmsChangeLevel
	NULL, // pfnGetGameDescription
	NULL, // pfnPlayerCustomization
	NULL, // pfnSpectatorConnect
	NULL, // pfnSpectatorDisconnect
	NULL, // pfnSpectatorThink
	NULL, // pfnSys_Error
	Hooks::Post::PM_Move,
	NULL, // pfnPM_Init
	NULL, // pfnPM_FindTextureType
	NULL, // pfnSetupVisibility
	NULL, // pfnUpdateClientData
	Hooks::Post::AddToFullPack,
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

enginefuncs_t meta_engfuncs = {
	Hooks::PrecacheModel,
	NULL, // pfnPrecacheSound()
	Hooks::SetModel,
	Hooks::ModelIndex,
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
	Hooks::UserMessage::Begin,
	Hooks::UserMessage::End,
	Hooks::UserMessage::Byte,
	Hooks::UserMessage::Char,
	Hooks::UserMessage::Short,
	Hooks::UserMessage::Long,
	Hooks::UserMessage::Angle,
	Hooks::UserMessage::Coord,
	Hooks::UserMessage::String,
	Hooks::UserMessage::Entity,
	NULL, // pfnCVarRegister()
	NULL, // pfnCVarGetFloat()
	NULL, // pfnCVarGetString()
	NULL, // pfnCVarSetFloat()
	NULL, // pfnCVarSetString()
	NULL, // pfnAlertMessage()
	NULL, // pfnEngineFprintf()
	NULL, // pfnPvAllocEntPrivateData()
	NULL, // pfnPvEntPrivateData()
	NULL, // pfnFreeEntPrivateData()
	NULL, // pfnSzFromIndex()
	NULL, // pfnAllocString()
	NULL,  // pfnGetVarsOfEnt()
	NULL, // pfnPEntityOfEntOffset()
	NULL, // pfnEntOffsetOfPEntity()
	NULL, // pfnIndexOfEdict()
	NULL, // pfnPEntityOfEntIndex()
	NULL, // pfnFindEntityByVars()
	NULL, // pfnGetModelPtr()
	Hooks::UserMessage::Register,
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
	NULL,  // pfnGetPlayerUserId()
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
	NULL, // pfnVoice_GetClientListening()
	NULL, // pfnVoice_SetClientListening()
	NULL, // pfnGetPlayerAuthId()
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
	NULL, // pfnQueryClientCvarValue()
	NULL, // pfnQueryClientCvarValue2()
	NULL, // pfnEngCheckParm()
};

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved )
{
    switch (ul_reason_for_call)
    {
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
		default:
			break;
    }
    return TRUE;
}

// From SDK dlls/h_export.cpp:

//! Holds engine functionality callbacks
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

#define REGISTER_TABLE( name, table, version, type, value ) \
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
	return value; \
}

extern bool InstallEngineHook();

REGISTER_TABLE( GetEntityAPI2, gFunctionTable, INTERFACE_VERSION, DLL_FUNCTIONS, (TRUE) )
REGISTER_TABLE( GetEntityAPI2_Post, gFunctionTable_Post, INTERFACE_VERSION, DLL_FUNCTIONS, (TRUE) )
REGISTER_TABLE( GetNewDLLFunctions, gNewDllFunctionTable, INTERFACE_VERSION, NEW_DLL_FUNCTIONS, (TRUE) )
REGISTER_TABLE( GetEngineFunctions, meta_engfuncs, ENGINE_INTERFACE_VERSION, enginefuncs_t, InstallEngineHook() )
