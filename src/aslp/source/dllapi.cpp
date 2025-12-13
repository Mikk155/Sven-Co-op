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

#include "asext_api.h"
#include "angelscript.h"

#include "dlldef.h"
#include <pm_defs.h>

#define CALL_ANGELSCRIPT(pfn, ...) if (ASEXT_CallHook){(*ASEXT_CallHook)(g_AngelHook.pfn, 0, __VA_ARGS__);}

#pragma region PreHooks
static bool s_HookedFlag = false;
static void ServerActivate(edict_t* pEdictList, int edictCount, int clientMax) {
	extern void LoadGMRFromCFG();
	LoadGMRFromCFG();

	if (s_HookedFlag) {
		SET_META_RESULT(MRES_IGNORED);
		return;
	}

	extern void VTableHook();
	VTableHook();
	s_HookedFlag = true;
	SET_META_RESULT(MRES_HANDLED);
}
static void ClientCommand(edict_t* pEntity) {
	if (!pEntity->pvPrivateData) {
		SET_META_RESULT(MRES_IGNORED);
		return;
	}
	const char* pcmd = CMD_ARGV(0);
	if (!strncmp(pcmd, "medic", 5)) {
		CALL_ANGELSCRIPT(pPlayerCallMedic, pEntity->pvPrivateData);
		SET_META_RESULT(MRES_HANDLED);
		return;
	}
	else if (!strncmp(pcmd, "grenade", 7)) {
		CALL_ANGELSCRIPT(pPlayerCallGrenade, pEntity->pvPrivateData);
		SET_META_RESULT(MRES_HANDLED);
		return;
	}
	else if (!strncmp(pcmd, "aslp_generate_docs", 11))
	{
		extern void GenerateScriptPredefined(const asIScriptEngine * engine);
		GenerateScriptPredefined(ASEXT_GetServerManager()->scriptEngine);
		SET_META_RESULT(MRES_SUPERCEDE);
		return;
	}
	SET_META_RESULT(MRES_IGNORED);
}
static void ClientUserInfoChanged(edict_t* pEntity, char* infobuffer) {
	if (pEntity == nullptr) {
		SET_META_RESULT(MRES_IGNORED);
		return;
	}
	int uiFlag = 0;
	CALL_ANGELSCRIPT(pPlayerUserInfoChanged, pEntity->pvPrivateData, infobuffer, &uiFlag);
	if (uiFlag != 0)
		SET_META_RESULT(MRES_SUPERCEDE);
	else
		SET_META_RESULT(MRES_HANDLED);
}

void PM_Move(playermove_t* pmove, int server)
{
	if (!pmove)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pPM_Move, &pmove, server, &meta_result);
	RETURN_META(meta_result);
}

int AddToFullPack(struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet)
{
	if (!ent->pvPrivateData || !host->pvPrivateData || !state || !player)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	int result = 0;
	CALL_ANGELSCRIPT(pAddToFullPack, &state, entindex, ent, host, hostflags, player, &meta_result, &result);
	RETURN_META_VALUE(meta_result, result);
}

static DLL_FUNCTIONS gFunctionTable = {
	NULL,					// pfnGameInit
	NULL,					// pfnSpawn
	NULL,					// pfnThink
	NULL,					// pfnUse
	NULL,					// pfnTouch
	NULL,					// pfnBlocked
	NULL,					// pfnKeyValue
	NULL,					// pfnSave
	NULL,					// pfnRestore
	NULL,					// pfnSetAbsBox

	NULL,					// pfnSaveWriteFields
	NULL,					// pfnSaveReadFields

	NULL,					// pfnSaveGlobalState
	NULL,					// pfnRestoreGlobalState
	NULL,					// pfnResetGlobalState

	NULL,					// pfnClientConnect
	NULL,					// pfnClientDisconnect
	NULL,					// pfnClientKill
	NULL,					// pfnClientPutInServer
	ClientCommand,			// pfnClientCommand
	ClientUserInfoChanged,	// pfnClientUserInfoChanged
	ServerActivate,			// pfnServerActivate
	NULL,					// pfnServerDeactivate

	NULL,					// pfnPlayerPreThink
	NULL,					// pfnPlayerPostThink

	NULL,					// pfnStartFrame
	NULL,					// pfnParmsNewLevel
	NULL,					// pfnParmsChangeLevel

	NULL,					// pfnGetGameDescription
	NULL,					// pfnPlayerCustomization

	NULL,					// pfnSpectatorConnect
	NULL,					// pfnSpectatorDisconnect
	NULL,					// pfnSpectatorThink

	NULL,					// pfnSys_Error

	PM_Move,			  // pfnPM_Move
	NULL,					// pfnPM_Init
	NULL,					// pfnPM_FindTextureType

	NULL,					// pfnSetupVisibility
	NULL,					// pfnUpdateClientData
	AddToFullPack,		 // pfnAddToFullPack
	NULL,					// pfnCreateBaseline
	NULL,					// pfnRegisterEncoders
	NULL,					// pfnGetWeaponData
	NULL,					// pfnCmdStart
	NULL,					// pfnCmdEnd
	NULL,					// pfnConnectionlessPacket
	NULL,					// pfnGetHullBounds
	NULL,					// pfnCreateInstancedBaselines
	NULL,					// pfnInconsistentFile
	NULL,					// pfnAllowLagCompensation
};
C_DLLEXPORT int GetEntityAPI2(DLL_FUNCTIONS* pFunctionTable,
	int* interfaceVersion) {
	if (!pFunctionTable) {
		UTIL_LogPrintf("GetEntityAPI2 called with null pFunctionTable");
		return(FALSE);
	}
	else if (*interfaceVersion != INTERFACE_VERSION) {
		UTIL_LogPrintf("GetEntityAPI2 version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION);
		//! Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return(FALSE);
	}
	memcpy(pFunctionTable, &gFunctionTable, sizeof(DLL_FUNCTIONS));
	return(TRUE);
}
#pragma endregion

#pragma region PostHook
static void GameInitPost() {
	static cvar_t fixgmr = { const_cast<char*>("sv_fixgmr"),const_cast<char*>("1"), FCVAR_SERVER };
	CVAR_REGISTER(&fixgmr);
	SET_META_RESULT(MRES_HANDLED);
}
static int Spawn_Post(edict_t* pent) {
	if (pent != nullptr) {
		if (pent->pvPrivateData != nullptr) {
			CALL_ANGELSCRIPT(pEntitySpawn, pent->pvPrivateData);
			if ((VARS(pent)->flags & FL_MONSTER) > 0) {
				const char* szName = STRING((VARS(pent)->classname));
				if (!strncmp(szName, "monster_", 8))
					CALL_ANGELSCRIPT(pMonsterSpawn, pent->pvPrivateData);
			}
		}
	}
	SET_META_RESULT(MRES_HANDLED);
	return 1919810;
}

int AddToFullPack_Post(struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet)
{
	if (!ent->pvPrivateData || !host->pvPrivateData || !state || !player)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	int result = 0;
	CALL_ANGELSCRIPT(pAddToFullPack_Post, &state, entindex, ent, host, hostflags, player, &meta_result, &result);
	RETURN_META_VALUE(meta_result, result);
}

static DLL_FUNCTIONS gFunctionTable_Post = {
	GameInitPost,			// pfnGameInit
	Spawn_Post,				// pfnSpawn
	NULL,					// pfnThink
	NULL,					// pfnUse
	NULL,					// pfnTouch
	NULL,					// pfnBlocked
	NULL,					// pfnKeyValue
	NULL,					// pfnSave
	NULL,					// pfnRestore
	NULL,					// pfnSetAbsBox

	NULL,					// pfnSaveWriteFields
	NULL,					// pfnSaveReadFields

	NULL,					// pfnSaveGlobalState
	NULL,					// pfnRestoreGlobalState
	NULL,					// pfnResetGlobalState

	NULL,					// pfnClientConnect
	NULL,					// pfnClientDisconnect
	NULL,					// pfnClientKill
	NULL,					// pfnClientPutInServer
	NULL,					// pfnClientCommand
	NULL,					// pfnClientUserInfoChanged
	NULL,					// pfnServerActivate
	NULL,					// pfnServerDeactivate

	NULL,					// pfnPlayerPreThink
	NULL,					// pfnPlayerPostThink

	NULL,					// pfnStartFrame
	NULL,					// pfnParmsNewLevel
	NULL,					// pfnParmsChangeLevel

	NULL,					// pfnGetGameDescription
	NULL,					// pfnPlayerCustomization

	NULL,					// pfnSpectatorConnect
	NULL,					// pfnSpectatorDisconnect
	NULL,					// pfnSpectatorThink

	NULL,					// pfnSys_Error

	NULL,					// pfnPM_Move
	NULL,					// pfnPM_Init
	NULL,					// pfnPM_FindTextureType

	NULL,					// pfnSetupVisibility
	NULL,					// pfnUpdateClientData
	AddToFullPack_Post,	// pfnAddToFullPack
	NULL,					// pfnCreateBaseline
	NULL,					// pfnRegisterEncoders
	NULL,					// pfnGetWeaponData
	NULL,					// pfnCmdStart
	NULL,					// pfnCmdEnd
	NULL,					// pfnConnectionlessPacket
	NULL,					// pfnGetHullBounds
	NULL,					// pfnCreateInstancedBaselines
	NULL,					// pfnInconsistentFile
	NULL,					// pfnAllowLagCompensation
};
C_DLLEXPORT int GetEntityAPI2_Post(DLL_FUNCTIONS* pFunctionTable,
	int* interfaceVersion) {
	if (!pFunctionTable) {
		UTIL_LogPrintf("GetEntityAPI2 called with null pFunctionTable");
		return(FALSE);
	}
	else if (*interfaceVersion != INTERFACE_VERSION) {
		UTIL_LogPrintf("GetEntityAPI2 version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION);
		//! Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return(FALSE);
	}
	memcpy(pFunctionTable, &gFunctionTable_Post, sizeof(DLL_FUNCTIONS));
	return(TRUE);
}
#pragma endregion