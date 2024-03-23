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
#include <dllapi.h>
#include <meta_api.h>
#include <log_meta.h>
#include <iostream>

#include "enginedef.h"
#include "serverdef.h"
#include "aslp.h"

#define CALL_ANGELSCRIPT(pfn, ...) if (ASEXT_CallHook){(*ASEXT_CallHook)(g_AngelHook.pfn, 0, __VA_ARGS__);}

void NewThink(edict_t* pEntity)
{
	if (fast_FNullEnt(pEntity))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pThink, pEntity->pvPrivateData, &meta_result);
	SET_META_RESULT(meta_result);
}

void NewTouch(edict_t* pentTouched, edict_t* pentOther)
{
	if (fast_FNullEnt(pentTouched) || fast_FNullEnt(pentOther))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pTouch, pentTouched->pvPrivateData, pentOther->pvPrivateData, &meta_result);
	SET_META_RESULT(meta_result);
}

void NewBlocked(edict_t* pentTouched, edict_t* pentOther)
{
	if (fast_FNullEnt(pentTouched) || fast_FNullEnt(pentOther))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pBlocked, pentTouched->pvPrivateData, pentOther->pvPrivateData, &meta_result);
	SET_META_RESULT(meta_result);
}

void NewKeyValue(edict_t* pentKeyvalue, KeyValueData* pkvd)
{
	if (fast_FNullEnt(pentKeyvalue) || !pkvd->fHandled)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	CString CStrKeyName = { 0 }; CStrKeyName.assign(pkvd->szKeyName, strlen(pkvd->szKeyName));
	CString CStrKeyValue = { 0 }; CStrKeyValue.assign(pkvd->szValue, strlen(pkvd->szValue));
	CString CStrClassname = { 0 }; CStrClassname.assign(pkvd->szClassName, strlen(pkvd->szClassName));

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pKeyValue, pentKeyvalue->pvPrivateData, &CStrKeyName, &CStrKeyValue, &CStrClassname, &meta_result);
	CStrKeyName.dtor(); CStrKeyValue.dtor(); CStrClassname.dtor();
	SET_META_RESULT(meta_result);
}

void NewClientCommand(edict_t* pEntity)
{
	if (fast_FNullEnt(pEntity))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	std::string strCombined = CMD_ARGV(0) + ((CMD_ARGC() >= 2) ? (" " + std::string(CMD_ARGS())) : "");
	CString CStrMessage = { 0 }; CStrMessage.assign(strCombined.c_str(), strlen(strCombined.c_str()));

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pClientCommand, pEntity->pvPrivateData, &CStrMessage, &meta_result);
	CStrMessage.dtor();
	SET_META_RESULT(meta_result);
}

void NewStartFrame()
{
	SET_META_RESULT(META_RES::MRES_IGNORED);
}

void NewPM_Move(playermove_t* pmove, int server)
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

int NewAddToFullPack(struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet)
{
	if (fast_FNullEnt(ent) || fast_FNullEnt(host) || !state || !player)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	/*
	if ((ent->v.effects & EF_NODRAW) && (ent != host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (!ent->v.modelindex || !STRING(ent->v.model))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if ((ent->v.flags & FL_SPECTATOR) && (ent != host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (ent != host && !ENGINE_CHECK_VISIBILITY((const struct edict_s*)ent, pSet))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (ent->v.flags & FL_SKIPLOCALHOST && (hostflags & 1) && (ent->v.owner == host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}
	*/

	META_RES meta_result = META_RES::MRES_IGNORED;
	int result = 0;
	CALL_ANGELSCRIPT(pAddToFullPack, &state, entindex, ent, host, hostflags, player, &meta_result, &result);
	RETURN_META_VALUE(meta_result, result);
}

void NewThink_Post(edict_t* pEntity)
{
	if (fast_FNullEnt(pEntity))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	CALL_ANGELSCRIPT(pThink_Post, pEntity->pvPrivateData, &meta_result);
	SET_META_RESULT(meta_result);
}

int NewAddToFullPack_Post(struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet)
{
	if (fast_FNullEnt(ent) || fast_FNullEnt(host) || !state || !player)
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	/*
	if ((ent->v.effects & EF_NODRAW) && (ent != host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (!ent->v.modelindex || !STRING(ent->v.model))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if ((ent->v.flags & FL_SPECTATOR) && (ent != host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (ent != host && !ENGINE_CHECK_VISIBILITY((const struct edict_s*)ent, pSet))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	if (ent->v.flags & FL_SKIPLOCALHOST && (hostflags & 1) && (ent->v.owner == host))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}
	*/

	META_RES meta_result = META_RES::MRES_IGNORED;
	int result = 0;
	CALL_ANGELSCRIPT(pAddToFullPack_Post, &state, entindex, ent, host, hostflags, player, &meta_result, &result);
	RETURN_META_VALUE(meta_result, result);
}

int NewShouldCollide(edict_t* pentTouched, edict_t* pentOther)
{
	if (fast_FNullEnt(pentTouched) || fast_FNullEnt(pentOther))
	{
		SET_META_RESULT(META_RES::MRES_IGNORED);
		return 0;
	}

	META_RES meta_result = META_RES::MRES_IGNORED;
	int result = 0;
	CALL_ANGELSCRIPT(pShouldCollide, pentTouched->pvPrivateData, pentOther->pvPrivateData, &meta_result, &result);
	RETURN_META_VALUE(meta_result, result);
}
#undef CALL_ANGELSCRIPT

static DLL_FUNCTIONS gFunctionTable =
{
	NULL,					// pfnGameInit
	NULL,					// pfnSpawn
	NewThink,				// pfnThink
	NULL,					// pfnUse
	NewTouch,				// pfnTouch
	NewBlocked,				// pfnBlocked
	NewKeyValue,			// pfnKeyValue
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
	NewClientCommand,		// pfnClientCommand
	NULL,					// pfnClientUserInfoChanged
	NewServerActivate,		// pfnServerActivate
	NULL,					// pfnServerDeactivate

	NULL,					// pfnPlayerPreThink
	NULL,					// pfnPlayerPostThink

	NewStartFrame,			// pfnStartFrame
	NULL,					// pfnParmsNewLevel
	NULL,					// pfnParmsChangeLevel

	NULL,					// pfnGetGameDescription
	NULL,					// pfnPlayerCustomization

	NULL,					// pfnSpectatorConnect
	NULL,					// pfnSpectatorDisconnect
	NULL,					// pfnSpectatorThink

	NULL,					// pfnSys_Error

	NewPM_Move,				// pfnPM_Move
	NULL,					// pfnPM_Init
	NULL,					// pfnPM_FindTextureType

	NULL,					// pfnSetupVisibility
	NULL,					// pfnUpdateClientData
	NewAddToFullPack,		// pfnAddToFullPack
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

static DLL_FUNCTIONS gFunctionTable_Post =
{
	NULL,					// pfnGameInit
	NULL,					// pfnSpawn
	NewThink_Post,			// pfnThink
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
	NewAddToFullPack_Post,	// pfnAddToFullPack
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

C_DLLEXPORT int GetEntityAPI2(DLL_FUNCTIONS* pFunctionTable, int* interfaceVersion)
{
	if (!pFunctionTable)
	{
		LOG_ERROR(PLID, "GetEntityAPI2 called with null pFunctionTable");
		return FALSE;
	}
	else if (*interfaceVersion != INTERFACE_VERSION)
	{
		LOG_ERROR(PLID, "GetEntityAPI2 version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION);
		//! Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return FALSE;
	}

	memcpy(pFunctionTable, &gFunctionTable, sizeof(DLL_FUNCTIONS));
	return TRUE;
}

C_DLLEXPORT int GetEntityAPI2_Post(DLL_FUNCTIONS* pFunctionTable, int* interfaceVersion)
{
	if (!pFunctionTable)
	{
		LOG_ERROR(PLID, "GetEntityAPI2_Post called with null pFunctionTable");
		return FALSE;
	}
	else if (*interfaceVersion != INTERFACE_VERSION)
	{
		LOG_ERROR(PLID, "GetEntityAPI2_Post version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION);
		//! Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return FALSE;
	}
	memcpy(pFunctionTable, &gFunctionTable_Post, sizeof(DLL_FUNCTIONS));
	return TRUE;
}

static NEW_DLL_FUNCTIONS gNewDllFunctionTable =
{
	// Called right before the object's memory is freed. 
	// Calls its destructor.
	NULL,
	NULL,
	NewShouldCollide,

	// Added 2005/08/11 (no SDK update):
	NULL,//void(*pfnCvarValue)(const edict_t *pEnt, const char *value);

	// Added 2005/11/21 (no SDK update):
	//    value is "Bad CVAR request" on failure (i.e that user is not connected or the cvar does not exist).
	//    value is "Bad Player" if invalid player edict.
	NULL,//void(*pfnCvarValue2)(const edict_t *pEnt, int requestID, const char *cvarName, const char *value);
};

C_DLLEXPORT int GetNewDLLFunctions(NEW_DLL_FUNCTIONS* pNewDllFunctionTable,
	int* interfaceVersion)
{
	if (!pNewDllFunctionTable) {
		LOG_ERROR(PLID, "GetNewDLLFunctions called with null pFunctionTable");
		return(FALSE);
	}
	else if (*interfaceVersion != NEW_DLL_FUNCTIONS_VERSION) {
		LOG_ERROR(PLID, "GetNewDLLFunctions version mismatch; requested=%d ours=%d", *interfaceVersion, NEW_DLL_FUNCTIONS_VERSION);
		//! Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = NEW_DLL_FUNCTIONS_VERSION;
		return(FALSE);
	}
	memcpy(pNewDllFunctionTable, &gNewDllFunctionTable, sizeof(NEW_DLL_FUNCTIONS));

	return(TRUE);
}