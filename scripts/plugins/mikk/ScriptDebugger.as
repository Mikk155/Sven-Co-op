/*
Shows debug messages from our scripts.

    INSTALL:

    "plugin"
    {
        "name" "ScriptDebugger"
        "script" "mikk/ScriptDebugger"
    }
*/

#include "../../maps/mikk/utils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo
	(
		"Mikk: https://github.com/Mikk155
		Gaftherman: https://github.com/Gaftherman
		Discord: https://discord.gg/VsNnE3A7j8"
	);
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
    int lenguage;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

    if( g_PlayerKeepLenguage.exists(SteamID) )
    {
        PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict( pPlayer.edict() ), SteamID );
    }
    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

    if( pPlayer is null )
        return;

    PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);

    pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_debug", int(pData.lenguage) );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();

    if( args.Arg(0) == "/debug" )
    {
        if( UTILS::GetCKV( pPlayer, "$i_debug" ) == 0 )
            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_debug", 1 );
        else
            pPlayer.GetCustomKeyvalues().SetKeyvalue( "$i_debug", 0 );

        string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

        PlayerKeepLenguageData pData;
        pData.lenguage = UTILS::GetCKV( pPlayer, "$i_debug" );
        g_PlayerKeepLenguage[SteamID] = pData;
    }
    return HOOK_CONTINUE;
}