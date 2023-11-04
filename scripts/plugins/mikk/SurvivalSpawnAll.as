#include '../../mikk/as_utils'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( mk.GetDiscord() );

    mk.FileManager.GetMultiLanguageMessages( msg, 'scripts/plugins/mikk/SurvivalSpawnAll.ini' );

    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

dictionary msg;

void MapInit()
{
    if( g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsEnabled() )
    {
        // Stupid rushing time, you have only one life excluding checkpoints, that's what survival means
        g_SurvivalMode.SetDelayBeforeStart( 0.0f );
    }
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        if( !TrackPlayers.exists( string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ) )
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, dictionary( msg[ 'spawn' ] ), CMKPlayerFuncs_PRINT_CHAT );

            if( !pPlayer.IsAlive() )
            {
                mk.PlayerFuncs.RespawnPlayer( pPlayer );
            }

            TrackPlayers[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'Joined';
        }
        else
        {
            mk.PlayerFuncs.PrintMessage( pPlayer, dictionary( msg[ 'no spawn' ] ), CMKPlayerFuncs_PRINT_CHAT );
        }
    }
    return HOOK_CONTINUE;
}

dictionary TrackPlayers;

HookReturnCode MapChange()
{
    TrackPlayers.deleteAll();
    return HOOK_CONTINUE;
}