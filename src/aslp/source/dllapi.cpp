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
static NEW_DLL_FUNCTIONS gNewDllFunctionTable =
{
	// Called right before the object's memory is freed. 
	// Calls its destructor.
	NULL,
	NULL,
	NULL,

	// Added 2005/08/11 (no SDK update):
	NULL,//void(*pfnCvarValue)(const edict_t *pEnt, const char *value);

	// Added 2005/11/21 (no SDK update):
	//    value is "Bad CVAR request" on failure (i.e that user is not connected or the cvar does not exist).
	//    value is "Bad Player" if invalid player edict.
	NULL,//void(*pfnCvarValue2)(const edict_t *pEnt, int requestID, const char *cvarName, const char *value);
};

C_DLLEXPORT int GetNewDLLFunctions( NEW_DLL_FUNCTIONS* pNewDllFunctionTable, int* interfaceVersion )
{
	if( !pNewDllFunctionTable )
	{
		LOG_ERROR( PLID, "GetNewDLLFunctions called with null pFunctionTable" );
		return(FALSE);
	}
	else if( *interfaceVersion != NEW_DLL_FUNCTIONS_VERSION )
	{
		LOG_ERROR( PLID, "GetNewDLLFunctions version mismatch; requested=%d ours=%d", *interfaceVersion, NEW_DLL_FUNCTIONS_VERSION );
		// Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = NEW_DLL_FUNCTIONS_VERSION;
		return(FALSE);
	}
	memcpy(pNewDllFunctionTable, &gNewDllFunctionTable, sizeof(NEW_DLL_FUNCTIONS));
	return(TRUE);
}

static void ServerActivate( edict_t* pEdictList, int edictCount, int clientMax )
{
	extern void LoadGMRFromCFG();
	LoadGMRFromCFG();

	static bool s_HookedFlag = false;

	if( s_HookedFlag )
	{
		SET_META_RESULT(MRES_IGNORED);
		return;
	}

	extern void VTableHook();
	VTableHook();

	s_HookedFlag = true;

	SET_META_RESULT(MRES_HANDLED);
}

static void ClientCommand( edict_t* pEntity )
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	if( pEntity->pvPrivateData )
	{
		CALL_ANGELSCRIPT( pCientCommandHook, pEntity->pvPrivateData, &meta_result );

		const char* pcmd = CMD_ARGV(0);

		if( !strncmp( pcmd, "aslp_generate_docs", 11 ) )
		{
			extern void GenerateScriptPredefined( const asIScriptEngine * engine );
			GenerateScriptPredefined( ASEXT_GetServerManager()->scriptEngine );
			meta_result = MRES_SUPERCEDE;
		}
	}

	SET_META_RESULT(meta_result);
}

static void ClientUserInfoChanged( edict_t* pEntity, char* infobuffer )
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	CALL_ANGELSCRIPT( pPlayerUserInfoChanged, ( pEntity != nullptr ? pEntity->pvPrivateData : nullptr ), infobuffer, &meta_result );

	SET_META_RESULT(meta_result);
}

static void PrePM_Move( playermove_t* pmove, int server )
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	if( pmove != nullptr )
	{
		CALL_ANGELSCRIPT( pPreMovement, &pmove, &meta_result );
	}

	RETURN_META(meta_result);
}

static int PreAddToFullPack( struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet )
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	if( ent->pvPrivateData && host->pvPrivateData && state )
	{
		addtofullpack_t data = { state, entindex, ent, host, hostflags, player };

		CALL_ANGELSCRIPT( pPreAddToFullPack, &data, &meta_result );

		// Skip packet
		if( data.Result )
		{
			RETURN_META_VALUE( META_RES::MRES_SUPERCEDE, 0 );
		}
	}

	RETURN_META_VALUE(meta_result, 0);
}

static DLL_FUNCTIONS gFunctionTable = {
	// pfnGameInit
	NULL,
	// pfnSpawn
	NULL,
	// pfnThink
	NULL,
	// pfnUse
	NULL,
	// pfnTouch
	NULL,
	// pfnBlocked
	NULL,
	// pfnKeyValue
	NULL,
	// pfnSave
	NULL,
	// pfnRestore
	NULL,
	// pfnSetAbsBox
	NULL,
	// pfnSaveWriteFields
	NULL,
	// pfnSaveReadFields
	NULL,
	// pfnSaveGlobalState
	NULL,
	// pfnRestoreGlobalState
	NULL,
	// pfnResetGlobalState
	NULL,
	// pfnClientConnect
	NULL,
	// pfnClientDisconnect
	NULL,
	// pfnClientKill
	NULL,
	// pfnClientPutInServer
	NULL,
	// pfnClientCommand
	ClientCommand, 
	// pfnClientUserInfoChanged
	ClientUserInfoChanged,
	// pfnServerActivate
	ServerActivate, 
	// pfnServerDeactivate
	NULL,
	// pfnPlayerPreThink
	NULL,
	// pfnPlayerPostThink
	NULL,
	// pfnStartFrame
	NULL,
	// pfnParmsNewLevel
	NULL,
	// pfnParmsChangeLevel
	NULL,
	// pfnGetGameDescription
	NULL,
	// pfnPlayerCustomization
	NULL,
	// pfnSpectatorConnect
	NULL,
	// pfnSpectatorDisconnect
	NULL,
	// pfnSpectatorThink
	NULL,
	// pfnSys_Error
	NULL,
	// pfnPM_Move
	PrePM_Move, 
	// pfnPM_Init
	NULL,
	// pfnPM_FindTextureType
	NULL,
	// pfnSetupVisibility
	NULL,
	// pfnUpdateClientData
	NULL,
	// pfnAddToFullPack
	PreAddToFullPack,
	// pfnCreateBaseline
	NULL,
	// pfnRegisterEncoders
	NULL,
	// pfnGetWeaponData
	NULL,
	// pfnCmdStart
	NULL,
	// pfnCmdEnd
	NULL,
	// pfnConnectionlessPacket
	NULL,
	// pfnGetHullBounds
	NULL,
	// pfnCreateInstancedBaselines
	NULL,
	// pfnInconsistentFile
	NULL,
	// pfnAllowLagCompensation
	NULL,
};

C_DLLEXPORT int GetEntityAPI2( DLL_FUNCTIONS* pFunctionTable, int* interfaceVersion )
{
	if( !pFunctionTable )
	{
		UTIL_LogPrintf( "GetEntityAPI2 called with null pFunctionTable" );
		return(FALSE);
	}
	else if( *interfaceVersion != INTERFACE_VERSION )
	{
		UTIL_LogPrintf( "GetEntityAPI2 version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION );
		// Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return(FALSE);
	}
	memcpy( pFunctionTable, &gFunctionTable, sizeof(DLL_FUNCTIONS) );
	return(TRUE);
}
#pragma endregion
#pragma region PostHook
static void GameInitPost()
{
	static cvar_t fixgmr = { const_cast<char*>( "sv_fixgmr" ),const_cast<char*>( "1" ), FCVAR_SERVER };
	CVAR_REGISTER(&fixgmr);

	SET_META_RESULT(MRES_HANDLED);
}

static int PostEntitySpawn( edict_t* pent )
{
	if( pent != nullptr )
	{
		CALL_ANGELSCRIPT( pPostEntitySpawn, pent );
	}

	SET_META_RESULT(META_RES::MRES_IGNORED;);

	return 1919810;
}

int PostAddToFullPack(struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet)
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	if( ent->pvPrivateData && host->pvPrivateData && state )
	{
		addtofullpack_t data = { state, entindex, ent, host, hostflags, player };

		CALL_ANGELSCRIPT( pPostAddToFullPack, &data, &meta_result );

		// Skip packet
		if( data.Result )
		{
			RETURN_META_VALUE( META_RES::MRES_SUPERCEDE, 0 );
		}
	}

	RETURN_META_VALUE(meta_result, 0);
}

void PostPM_Move( playermove_t* pmove, int server )
{
	META_RES meta_result = META_RES::MRES_IGNORED;

	if( pmove != nullptr )
	{
		CALL_ANGELSCRIPT( pPostMovement, &pmove, &meta_result );
	}

	RETURN_META(meta_result);
}

static DLL_FUNCTIONS gFunctionTable_Post = {
	// pfnGameInit
	GameInitPost,
	// pfnSpawn
	PostEntitySpawn,
	// pfnThink
	NULL,
	// pfnUse
	NULL,
	// pfnTouch
	NULL,
	// pfnBlocked
	NULL,
	// pfnKeyValue
	NULL,
	// pfnSave
	NULL,
	// pfnRestore
	NULL,
	// pfnSetAbsBox
	NULL,
	// pfnSaveWriteFields
	NULL,
	// pfnSaveReadFields
	NULL,
	// pfnSaveGlobalState
	NULL,
	// pfnRestoreGlobalState
	NULL,
	// pfnResetGlobalState
	NULL,
	// pfnClientConnect
	NULL,
	// pfnClientDisconnect
	NULL,
	// pfnClientKill
	NULL,
	// pfnClientPutInServer
	NULL,
	// pfnClientCommand
	NULL,
	// pfnClientUserInfoChanged
	NULL,
	// pfnServerActivate
	NULL,
	// pfnServerDeactivate
	NULL,
	// pfnPlayerPreThink
	NULL,
	// pfnPlayerPostThink
	NULL,
	// pfnStartFrame
	NULL,
	// pfnParmsNewLevel
	NULL,
	// pfnParmsChangeLevel
	NULL,
	// pfnGetGameDescription
	NULL,
	// pfnPlayerCustomization
	NULL,
	// pfnSpectatorConnect
	NULL,
	// pfnSpectatorDisconnect
	NULL,
	// pfnSpectatorThink
	NULL,
	// pfnSys_Error
	NULL,
	// pfnPM_Move
	PostPM_Move,
	// pfnPM_Init
	NULL,
	// pfnPM_FindTextureType
	NULL,
	// pfnSetupVisibility
	NULL,
	// pfnUpdateClientData
	NULL,
	// pfnAddToFullPack
	PostAddToFullPack,
	// pfnCreateBaseline
	NULL,
	// pfnRegisterEncoders
	NULL,
	// pfnGetWeaponData
	NULL,
	// pfnCmdStart
	NULL,
	// pfnCmdEnd
	NULL,
	// pfnConnectionlessPacket
	NULL,
	// pfnGetHullBounds
	NULL,
	// pfnCreateInstancedBaselines
	NULL,
	// pfnInconsistentFile
	NULL,
	// pfnAllowLagCompensation
	NULL,
};

C_DLLEXPORT int GetEntityAPI2_Post( DLL_FUNCTIONS* pFunctionTable, int* interfaceVersion )
{
	if( !pFunctionTable )
	{
		UTIL_LogPrintf( "GetEntityAPI2 called with null pFunctionTable" );
		return(FALSE);
	}
	else if( *interfaceVersion != INTERFACE_VERSION )
	{
		UTIL_LogPrintf( "GetEntityAPI2 version mismatch; requested=%d ours=%d", *interfaceVersion, INTERFACE_VERSION );
		// Tell metamod what version we had, so it can figure out who is out of date.
		*interfaceVersion = INTERFACE_VERSION;
		return(FALSE);
	}
	memcpy(pFunctionTable, &gFunctionTable_Post, sizeof(DLL_FUNCTIONS));
	return(TRUE);
}
#pragma endregion
