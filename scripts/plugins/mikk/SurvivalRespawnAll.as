//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include "../../mikk/json"
#include "../../mikk/Language"
#include "../../mikk/PlayerFuncs"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( "plugins/mikk/SurvivalRespawnAll.json" );
}

json pJson;
dictionary TrackPlayers;

void MapInit()
{
    TrackPlayers.deleteAll();
    g_Hooks.RemoveHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );

    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) < 1 )
    {
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
        if( pJson[ 'INSTANT_ENABLE', true ] && g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.GetStartOn() )
        {
            g_SurvivalMode.SetDelayBeforeStart( 0.0f );
            g_SurvivalMode.Activate( true );
        }
    }
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        if( !TrackPlayers.exists( PlayerFuncs::GetSteamID( pPlayer ) ) )
        {
            g_Scheduler.SetTimeout( "SpawnPlayer", 4.5f, EHandle( pPlayer ) );
        }
    }
    return HOOK_CONTINUE;
}

void SpawnPlayer( EHandle hPlayer )
{
    if( hPlayer.IsValid() && g_SurvivalMode.IsActive() )
    {
        CBasePlayer@ pPlayer = cast<CBasePlayer>( hPlayer.GetEntity() );

        if( pPlayer !is null )
        {
            if( !pPlayer.IsAlive() )
            {
                PlayerFuncs::RespawnPlayer( pPlayer );
            }
            Language::Print( pPlayer, pJson[ "SPAWNED", {} ] );
            TrackPlayers[ PlayerFuncs::GetSteamID( pPlayer ) ] = "Spawned";
        }
    }
}
