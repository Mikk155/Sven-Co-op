// vi: set ts=4 sw=4 :
// vim: set tw=75 :

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
#include <map>
#include "extern_hook.h"
#include <string>

#include <extdll.h>
#include <meta_api.h>

#include "enginedef.h"

#pragma region PreHooks
static int SV_ModelIndex(const char* m) {
	if (CVAR_GET_FLOAT("sv_fixgmr") > 0) {
		extern std::map<std::string, std::string> g_dicGMRmap;
		for (auto iter = g_dicGMRmap.begin(); iter != g_dicGMRmap.end(); iter++) {
			if (strcmp((*iter).first.c_str(), m) == 0) {
				SET_META_RESULT(MRES_SUPERCEDE);
				return MODEL_INDEX((*iter).second.c_str());
			}
		}
	}
	SET_META_RESULT(MRES_IGNORED);
	return 0;
}

#include "generate_as_networking.h"
extern CGenerateNetworkMessageAPI* g_NetworkMessageAPI;

static int MSG_Register( const char* name, int bytes )
{
	// Avoid re-call
	static bool registeringMessage = false;

	if( registeringMessage == true )
	{
		RETURN_META_VALUE(META_RES::MRES_IGNORED, 0);
	}

	registeringMessage = true;
	int messageID = REG_USER_MSG( name, bytes );
	registeringMessage = false;

	if( g_NetworkMessageAPI == nullptr )
		g_NetworkMessageAPI = new CGenerateNetworkMessageAPI();

	g_NetworkMessageAPI->Register( name, bytes, messageID );

	RETURN_META_VALUE(META_RES::MRES_SUPERCEDE, messageID);
}

static void MSG_Begin( int msg_dest, int msg_type, const float *pOrigin = NULL, edict_t *ed = NULL )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Begin( msg_dest, msg_type, pOrigin, ed );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_End()
{
	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Byte( int input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Byte );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Char( int input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Char );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Short( int input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Short );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Long( int input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Long );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Angle( float input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Angle );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Coord( float input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Coord );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_String( const char* input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::String );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

static void MSG_Entity( int input )
{
	if( g_NetworkMessageAPI != nullptr )
		g_NetworkMessageAPI->Write( NetworkMessageByteType::Entity );

	SET_META_RESULT(META_RES::MRES_IGNORED);
}

enginefuncs_t meta_engfuncs = {
	NULL,						// pfnPrecacheModel()
	NULL,						// pfnPrecacheSound()
	NULL,						// pfnSetModel()
	SV_ModelIndex,						// pfnModelIndex()
	NULL,						// pfnModelFrames()

	NULL,						// pfnSetSize()
	NULL,						// pfnChangeLevel()
	NULL,						// pfnGetSpawnParms()
	NULL,						// pfnSaveSpawnParms()

	NULL,						// pfnVecToYaw()
	NULL,						// pfnVecToAngles()
	NULL,						// pfnMoveToOrigin()
	NULL,						// pfnChangeYaw()
	NULL,						// pfnChangePitch()

	NULL,						// pfnFindEntityByString()
	NULL,						// pfnGetEntityIllum()
	NULL,						// pfnFindEntityInSphere()
	NULL,						// pfnFindClientInPVS()
	NULL,						// pfnEntitiesInPVS()

	NULL,						// pfnMakeVectors()
	NULL,						// pfnAngleVectors()

	NULL,						// pfnCreateEntity()
	NULL,						// pfnRemoveEntity()
	NULL,						// pfnCreateNamedEntity()

	NULL,						// pfnMakeStatic()
	NULL,						// pfnEntIsOnFloor()
	NULL,						// pfnDropToFloor()

	NULL,						// pfnWalkMove()
	NULL,						// pfnSetOrigin()

	NULL,						// pfnEmitSound()
	NULL,						// pfnEmitAmbientSound()

	NULL,						// pfnTraceLine()
	NULL,						// pfnTraceToss()
	NULL,						// pfnTraceMonsterHull()
	NULL,						// pfnTraceHull()
	NULL,						// pfnTraceModel()
	NULL,						// pfnTraceTexture()
	NULL,						// pfnTraceSphere()
	NULL,						// pfnGetAimVector()

	NULL,						// pfnServerCommand()
	NULL,						// pfnServerExecute()
	NULL,						// pfnClientCommand()

	NULL,						// pfnParticleEffect()
	NULL,						// pfnLightStyle()
	NULL,						// pfnDecalIndex()
	NULL,						// pfnPointContents()

	MSG_Begin,						// pfnMessageBegin()
	MSG_End,						// pfnMessageEnd()

	MSG_Byte,						// pfnWriteByte()
	MSG_Char,						// pfnWriteChar()
	MSG_Short,						// pfnWriteShort()
	MSG_Long,						// pfnWriteLong()
	MSG_Angle,						// pfnWriteAngle()
	MSG_Coord,						// pfnWriteCoord()
	MSG_String,						// pfnWriteString()
	MSG_Entity,						// pfnWriteEntity()

	NULL,						// pfnCVarRegister()
	NULL,						// pfnCVarGetFloat()
	NULL,						// pfnCVarGetString()
	NULL,						// pfnCVarSetFloat()
	NULL,						// pfnCVarSetString()

	NULL,						// pfnAlertMessage()
	NULL,						// pfnEngineFprintf()

	NULL,						// pfnPvAllocEntPrivateData()
	NULL,						// pfnPvEntPrivateData()
	NULL,						// pfnFreeEntPrivateData()

	NULL,						// pfnSzFromIndex()
	NULL,						// pfnAllocString()

	NULL, 						// pfnGetVarsOfEnt()
	NULL,						// pfnPEntityOfEntOffset()
	NULL,						// pfnEntOffsetOfPEntity()
	NULL,						// pfnIndexOfEdict()
	NULL,						// pfnPEntityOfEntIndex()
	NULL,						// pfnFindEntityByVars()
	NULL,						// pfnGetModelPtr()

	MSG_Register,						// pfnRegUserMsg()

	NULL,						// pfnAnimationAutomove()
	NULL,						// pfnGetBonePosition()

	NULL,						// pfnFunctionFromName()
	NULL,						// pfnNameForFunction()

	NULL,						// pfnClientPrintf()
	NULL,						// pfnServerPrint()

	NULL,						// pfnCmd_Args()
	NULL,						// pfnCmd_Argv()
	NULL,						// pfnCmd_Argc()

	NULL,						// pfnGetAttachment()

	NULL,						// pfnCRC32_Init()
	NULL,						// pfnCRC32_ProcessBuffer()
	NULL,						// pfnCRC32_ProcessByte()
	NULL,						// pfnCRC32_Final()

	NULL,						// pfnRandomLong()
	NULL,						// pfnRandomFloat()

	NULL,						// pfnSetView()
	NULL,						// pfnTime()
	NULL,						// pfnCrosshairAngle()

	NULL,						// pfnLoadFileForMe()
	NULL,						// pfnFreeFile()

	NULL,						// pfnEndSection()
	NULL,						// pfnCompareFileTime()
	NULL,						// pfnGetGameDir()
	NULL,						// pfnCvar_RegisterVariable()
	NULL,						// pfnFadeClientVolume()
	NULL,						// pfnSetClientMaxspeed()
	NULL,						// pfnCreateFakeClient()
	NULL,						// pfnRunPlayerMove()
	NULL,						// pfnNumberOfEntities()

	NULL,						// pfnGetInfoKeyBuffer()
	NULL,						// pfnInfoKeyValue()
	NULL,						// pfnSetKeyValue()
	NULL,						// pfnSetClientKeyValue()

	NULL,						// pfnIsMapValid()
	NULL,						// pfnStaticDecal()
	NULL,						// pfnPrecacheGeneric()
	NULL, 						// pfnGetPlayerUserId()
	NULL,						// pfnBuildSoundMsg()
	NULL,						// pfnIsDedicatedServer()
	NULL,						// pfnCVarGetPointer()
	NULL,						// pfnGetPlayerWONId()

	NULL,						// pfnInfo_RemoveKey()
	NULL,						// pfnGetPhysicsKeyValue()
	NULL,						// pfnSetPhysicsKeyValue()
	NULL,						// pfnGetPhysicsInfoString()
	NULL,						// pfnPrecacheEvent()
	NULL,						// pfnPlaybackEvent()

	NULL,						// pfnSetFatPVS()
	NULL,						// pfnSetFatPAS()

	NULL,						// pfnCheckVisibility()

	NULL,						// pfnDeltaSetField()
	NULL,						// pfnDeltaUnsetField()
	NULL,						// pfnDeltaAddEncoder()
	NULL,						// pfnGetCurrentPlayer()
	NULL,						// pfnCanSkipPlayer()
	NULL,						// pfnDeltaFindField()
	NULL,						// pfnDeltaSetFieldByIndex()
	NULL,						// pfnDeltaUnsetFieldByIndex()

	NULL,						// pfnSetGroupMask()

	NULL,						// pfnCreateInstancedBaseline()
	NULL,						// pfnCvar_DirectSet()

	NULL,						// pfnForceUnmodified()

	NULL,						// pfnGetPlayerStats()

	NULL,						// pfnAddServerCommand()

	// Added in SDK 2.2:
	NULL,						// pfnVoice_GetClientListening()
	NULL,						// pfnVoice_SetClientListening()

	// Added for HL 1109 (no SDK update):
	NULL,						// pfnGetPlayerAuthId()

	// Added 2003/11/10 (no SDK update):
	NULL,						// pfnSequenceGet()
	NULL,						// pfnSequencePickSentence()
	NULL,						// pfnGetFileSize()
	NULL,						// pfnGetApproxWavePlayLen()
	NULL,						// pfnIsCareerMatch()
	NULL,						// pfnGetLocalizedStringLength()
	NULL,						// pfnRegisterTutorMessageShown()
	NULL,						// pfnGetTimesTutorMessageShown()
	NULL,						// pfnProcessTutorMessageDecayBuffer()
	NULL,						// pfnConstructTutorMessageDecayBuffer()
	NULL,						// pfnResetTutorMessageDecayData()

	// Added Added 2005-08-11 (no SDK update)
	NULL,						// pfnQueryClientCvarValue()
	// Added Added 2005-11-22 (no SDK update)
	NULL,						// pfnQueryClientCvarValue2()
	// Added 2009-06-17 (no SDK update)
	NULL,						// pfnEngCheckParm()
};
C_DLLEXPORT int GetEngineFunctions(enginefuncs_t* pengfuncsFromEngine,
	int* interfaceVersion)
{
	if (!pengfuncsFromEngine) {
		UTIL_LogPrintf("GetEngineFunctions called with null pengfuncsFromEngine");
		return false;
	}
	else if (*interfaceVersion != ENGINE_INTERFACE_VERSION) {
		UTIL_LogPrintf("GetEngineFunctions version mismatch; requested=%d ours=%d", *interfaceVersion, ENGINE_INTERFACE_VERSION);
		// Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = ENGINE_INTERFACE_VERSION;
		return false;
	}
	memcpy(pengfuncsFromEngine, &meta_engfuncs, sizeof(enginefuncs_t));

	return InstallEngineHook();
}
#pragma endregion