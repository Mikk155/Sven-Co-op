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

#include "../../mikk/fft"
#include "../../mikk/json"
#include "../../mikk/Discord"
#include "../../mikk/Language"
#include "../../mikk/EntityFuncs"
#include "../../mikk/PlayerFuncs"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( "plugins/mikk/AFKManager.json" );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @PlayerPreThink );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
}

json pJson;

int AFK_TIME;

dictionary gData;

dictionary gPlayerData;

const string ckv = '$s_afkmanager_';

void MapStart() { pJson.reload( "plugins/mikk/AFKManager.json" ); }

void Command( const CCommand@ args ) { AFK_TIME = atoi( args[1] ); }

CClientCommand CMD( "afk", "AFKManager max afk time", @Command, ConCommandFlag::AdminOnly );

const int MaxTime() { return ( AFK_TIME >= 11 ? AFK_TIME : int( pJson[ 'max afk time' ] ) ); }

const bool IsAFK( CBaseEntity@ pPlayer ) { return ( atoi( CustomKeyValue( pPlayer, ckv + 'afk' ) ) == 1 ); }

class CAFKManagerData
{
    int afk;
    int time;
    int live;

    void opIndex( int _afk_, int _time_, int _live_ )
    {
        afk = _afk_;
        time = _time_;
        live = _live_;
    }
}

HookReturnCode MapChange()
{
    gPlayerData.deleteAll();

    for( int i = 0; i <= g_Engine.maxClients; i++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

        if( pPlayer !is null )
        {
            CAFKManagerData pData;

            pData[
                atoi( CustomKeyValue( pPlayer, ckv + 'afk' ) ),
                    atoi( CustomKeyValue( pPlayer, ckv + 'time' ) ),
                        atoi( CustomKeyValue( pPlayer, ckv + 'live' ) )
            ];

            gPlayerData[ PlayerFuncs::GetSteamID( pPlayer ) ] = pData;
        }
    }

    return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null && gPlayerData.exists( PlayerFuncs::GetSteamID( pPlayer ) ) )
    {
        CAFKManagerData@ pData = cast<CAFKManagerData@>( gPlayerData[ PlayerFuncs::GetSteamID( pPlayer ) ] );

        if( pData !is null )
        {
            CustomKeyValue( pPlayer, ckv + 'afk', pData.afk );
            CustomKeyValue( pPlayer, ckv + 'time', pData.time );
            CustomKeyValue( pPlayer, ckv + 'live', pData.live );
            gPlayerData.delete( PlayerFuncs::GetSteamID( pPlayer ) );
        }
    }

    return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();

    if( pPlayer !is null )
    {
        if( pParams.GetArguments()[0] == '/afk' )
        {
            Join( pParams.GetPlayer(), true );
        }
        else if( pJson[ 'Add afk to names', false ] && IsAFK( pPlayer ) )
        {
            string name = string( pPlayer.pev.netname );
            pPlayer.pev.netname = string_t( '(AFK) ' + name );
            g_Scheduler.SetTimeout( "RestoreName", 0.01f, EHandle( pPlayer ), string_t( name ) );
        }
    }
    return HOOK_CONTINUE;
}

void RestoreName( EHandle hPlayer, string_t name )
{
    CBaseEntity@ pPlayer = hPlayer.GetEntity();

    if( pPlayer !is null )
    {
        pPlayer.pev.netname = name;
    }
}

void Join( CBasePlayer@ pPlayer, bool &in ByChat = false )
{
    if( pPlayer !is null && !IsAFK( pPlayer ) )
    {
        Language::Print( pPlayer, pJson[ 'youve_moved_afk', {} ], MKLANG::CHAT );
        dictionary gpArgs = { { 'name', string( pPlayer.pev.netname ) } };
        Language::Print( pPlayer, pJson[ 'player_join_afk', {} ], MKLANG::CHAT, gpArgs );
        Discord::print( string( pJson[ 'player_join_afk', {} ][ Discord::language() ] ), gpArgs );

        CustomKeyValue( pPlayer, ckv + 'afk', 1 );

        if( pPlayer.IsAlive() )
        {
            if( pJson[ 'respawn on exit', false ] )
            {
                CustomKeyValue( pPlayer, ckv + 'live', 1 );
            }

            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
        }
    }
}

void Leave( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        int f = atoi( CustomKeyValue( pPlayer, ckv + 'time' ) );
        int h = f / 3600;
        int m = ( f % 3600 ) / 60;
        int s = f % 60;
        dictionary gpArgs = { { 'name', string( pPlayer.pev.netname ) }, { 'time', string(h) + ":" + string(m) + ":" + string(s) } };
        Language::Print( pPlayer, pJson[ 'player_left_afk', {} ], MKLANG::CHAT, gpArgs );
        Discord::print( string( pJson[ 'player_left_afk', {} ][ Discord::language() ] ), gpArgs );

        CustomKeyValue( pPlayer, ckv + 'afk', 0 );
        CustomKeyValue( pPlayer, ckv + 'time', 0 );

        if( CustomKeyValue( pPlayer, ckv + 'live' ) == 1 )
        {
            PlayerFuncs::RespawnPlayer( pPlayer );
        }
    }
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    // Player is AFK
    if( IsAFK( pPlayer ) )
    {
        if( g_Engine.time > atof( CustomKeyValue( pPlayer, ckv + 'think' ) ) )
        {
            CustomKeyValue( pPlayer, ckv + 'time', atoi( CustomKeyValue( pPlayer, ckv + 'time' ) ) + 1 );
            CustomKeyValue( pPlayer, ckv + 'think', g_Engine.time + 1.0f );
        }

        pPlayer.pev.nextthink = g_Engine.time + 0.1f;

        if( pPlayer.IsAlive() )
        {
            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
        }

        Language::Print( pPlayer, pJson[ 'hold_to_exit', {} ], MKLANG::BIND );

        if( pPlayer.pev.button & IN_USE > 0 )
        {
            Leave( pPlayer ); // Print empty string so it disappears as soon as the player press E
            g_PlayerFuncs.PrintKeyBindingString( pPlayer, '\n' );
        }
    }
    else if( pPlayer.IsAlive() )
    {
        if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) < 1 )
        {
            if( atoi( CustomKeyValue( pPlayer, ckv + 'button' ) ) != pPlayer.pev.button )
            {
                CustomKeyValue( pPlayer, ckv + 'button', pPlayer.pev.button );
                CustomKeyValue( pPlayer, ckv + 'time', 0 );
            }

            if( g_Engine.time > atof( CustomKeyValue( pPlayer, ckv + 'think' ) ) )
            {
                int time =  atoi( CustomKeyValue( pPlayer, ckv + 'time' ) );

                if( time >= MaxTime() )
                {
                    if( g_PlayerFuncs.GetNumPlayers() == g_Engine.maxClients
                    && ( g_PlayerFuncs.AdminLevel( pPlayer ) < AdminLevel_t::ADMIN_YES ) || !pJson[ 'protect admins', true ] )
                    {
                        g_EngineFuncs.ServerCommand(
                            "kick #" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() )+ " \"" +
                                Language::GetLanguage( pPlayer, pJson[ 'kick_reason', {} ] ) + "\"\n"
                        );

                        dictionary gpArgs = { { 'name', string( pPlayer.pev.netname ) } };
                        Language::Print( pPlayer, pJson[ 'kick_advice', {} ], MKLANG::CHAT, gpArgs );
                        Discord::print( string( pJson[ 'kick_advice', {} ][ Discord::language() ] ), gpArgs );
                    }
                    else
                    {
                        Join( pPlayer );
                    }
                }
                else if( time > ( MaxTime() - 10 ) )
                {
                    Language::Print( pPlayer, pJson[ 'afk_advice', {} ], MKLANG::HUDMSG, { { 'time', string( MaxTime() - time ) } } );
                }
                CustomKeyValue( pPlayer, ckv + 'time', atoi( CustomKeyValue( pPlayer, ckv + 'time' ) ) + 1 );
                CustomKeyValue( pPlayer, ckv + 'think', g_Engine.time + 1.0f );
            }
        }
    }
    return HOOK_CONTINUE;
}
