/*
Script made for Kez's map and now recycled into a plugin.
must include my scripts callbacks and utils since the code is there and the plugin is only used for clientsay Set

LINKS:
https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/callbacks.as
https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/utils.as

	"plugin"
	{
		"name" "autohop"
		"script" "mikk/autohop"
	}
*/

#include "../../maps/mikk/entities/utils"
#include "../../maps/mikk/callbacks"
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor
	(
		"Mikk
		----------------------------------------
		Auto-Bhopping plugin

		  //
		  ('>
		  /rr
		*( ))_
	
		Plugin made by Mikk
	
		Type in chat /bhop to toggle auto-hop mode
	
		it works by pressing A/D relativelly and you'll autojump with that.

		Download from the main repository: https://github.com/Mikk155
		"
	);

	g_Module.ScriptInfo.SetContactInfo
	(
		"https://discord.gg/VsNnE3A7j8
		----------------------------------------
		"
	);
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
	int lenguage;
}

HookReturnCode MapChange()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null or !pPlayer.IsConnected() )
			continue;

		string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_bhopping");
        int iLanguage = int(ckLenguageIs.GetFloat());

		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
	}

	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_bhopping");
	int iLanguage = int(ckLenguageIs.GetFloat());
		
	if( g_PlayerKeepLenguage.exists(SteamID) )
	{
        PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict(pPlayer.edict()), SteamID );
	}
    else
    {
		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
    }
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
    CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_bhopping");
    int iLanguage = int(ckLenguageIs.GetFloat());

    PlayerKeepLenguageData pData;
	pData.lenguage = iLanguage;
	g_PlayerKeepLenguage[SteamID] = pData;   

    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

	if( pPlayer is null )
		return;

	PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	ckLenguage.SetKeyvalue("$f_bhopping", int(pData.lenguage));
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();

	if ( pArguments.ArgC() >= 1 )
	{
		if( pArguments[0] == "/bhop" )
		{
			if( pPlayer.GetCustomKeyvalues().GetKeyvalue("$f_bhopping").GetFloat() == 1 )
			{
				pPlayer.GetCustomKeyvalues().SetKeyvalue( "$f_bhopping", 0 );
				MLANBHOP::MSG( pPlayer, "on" );
			}
			else
			{
				pPlayer.GetCustomKeyvalues().SetKeyvalue( "$f_bhopping", 1 );
				MLANBHOP::MSG( pPlayer, "off" );
			}
		}
	}
	return HOOK_CONTINUE;
}

void MapInit()
{
	g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void Think()
{
	CTriggerScripts::AutoHop( null );
}

namespace MLANBHOP
{
	void MSG( CBasePlayer@ pPlayer, const string msg )
	{
		int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

		if( iLanguage == 1 ) // Spanish
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else if( iLanguage == 2 ) // Portuguese
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else if( iLanguage == 3 ) // German
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else if( iLanguage == 4 ) // French
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else if( iLanguage == 5 ) // Italian
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else if( iLanguage == 6 ) // Esperanto
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
		else // English
		{
			if( msg == "off" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now disabled.\n" );
			else if( msg == "on" )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AUTO-BHOP] auto-hop is now enabled. use A/D relativelly.\n" );
		}
	}
}