#include "utils/mapblacklist"

const string iszConfigFile = 'scripts/plugins/mikk/survival_respawn.txt';

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://discord.gg/VsNnE3A7j8" );

    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

bool MapBlackListed;

void MapInit()
{
    if( g_SurvivalMode.MapSupportEnabled() )
    {
        mapblacklist( iszConfigFile, MapBlackListed );

        if( !MapBlackListed )
        {
            g_SurvivalMode.SetDelayBeforeStart( 0.0f );
        }
    }
}

dictionary TrackPlayers;

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( !MapBlackListed && pPlayer !is null )
    {
        bool IsInDict = TrackPlayers.exists( string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

        if( !IsInDict )
        {
            pPlayer.Respawn();
            TrackPlayers[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'Joined';
        }

        g_Scheduler.SetTimeout( "PrintMsg", 2.0f, @pPlayer, IsInDict );
    }
    return HOOK_CONTINUE;
}

void PrintMsg( CBasePlayer@ pPlayer, bool bAddedToDict = false )
{
    if( bAddedToDict )
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "You have been respawned before, no respawning allowed for rejoining.\n" );
    }
    else
    {
        g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Survival mode is active. No more respawning allowed for connected players.\n" );
    }
        
}

HookReturnCode MapChange()
{
    TrackPlayers.deleteAll();
    return HOOK_CONTINUE;
}