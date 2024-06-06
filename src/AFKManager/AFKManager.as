#include "fft"
#include "json"
#include "Discord"
#include "Language"
#include "EntityFuncs"
#include "PlayerFuncs"
#include "CustomKeyValues"

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

void MapStart() { pJson.reload( "plugins/mikk/AFKManager.json" ); }

void Command( const CCommand@ args ) { AFK_TIME = atoi( args[1] ); }

CClientCommand CMD( "afk", "AFKManager max afk time", @Command, ConCommandFlag::AdminOnly );

const int MaxTime() { return ( AFK_TIME >= 11 ? AFK_TIME : int( pJson[ 'max afk time' ] ) ); }

class CAFKManagerData
{
    bool afk;
    int time;
    bool live;

    void opIndex( bool _afk_, int _time_, bool _live_ )
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
                bool( ckvd[ pPlayer, 'afkmanager_afk' ] ),
                    int( ckvd[ pPlayer, 'afkmanager_time' ] ),
                        bool( ckvd[ pPlayer, 'afkmanager_live' ] )
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
            ckvd[ pPlayer, 'afkmanager_afk', pData.afk ];
            ckvd[ pPlayer, 'afkmanager_time', pData.time ];
            ckvd[ pPlayer, 'afkmanager_live', pData.live ];
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
        else if( pJson[ 'Add afk to names', false ] && bool( ckvd[ pPlayer, 'afkmanager_afk' ] ) )
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
    if( hPlayer.IsValid() )
    {
       CBaseEntity@ pPlayer = hPlayer.GetEntity();

        if( pPlayer !is null )
        {
            pPlayer.pev.netname = name;
        }
    }
}

void Join( CBasePlayer@ pPlayer, bool &in ByChat = false )
{
    if( pPlayer !is null && !bool( ckvd[ pPlayer, 'afkmanager_afk' ] ) )
    {
        if( !ByChat )
        {
            Language::Print( pPlayer, pJson[ 'youve_moved_afk', {} ], MKLANG::CHAT );
            dictionary gpArgs = { { 'name', string( pPlayer.pev.netname ) } };
            Language::Print( pPlayer, pJson[ 'player_join_afk', {} ], MKLANG::CHAT, gpArgs );
            Discord::print( string( pJson[ 'player_join_afk', {} ][ Discord::language() ] ), gpArgs );
        }

        if( g_SurvivalMode.MapSupportEnabled() && g_SurvivalMode.IsActive() && g_PlayerFuncs.GetNumPlayers() == 1 )
        {
            if( ByChat )
            {
                Language::Print( pPlayer, pJson[ 'youcantsurvival', {} ], MKLANG::CHAT );
            }
            return;
        }

        ckvd[ pPlayer, 'afkmanager_afk', true ];

        if( pPlayer.IsAlive() )
        {
            if( pJson[ 'respawn on exit', false ] )
            {
                ckvd[ pPlayer, 'afkmanager_live', true ];
            }

            pPlayer.GetObserver().StartObserver( pPlayer.EyePosition(), pPlayer.pev.angles, false );

            if( bool( pJson[ "spectate a player" ] ) )
            {
                pPlayer.pev.iuser1 = OBS_CHASE_LOCKED;
            }
        }
    }
}

void Leave( CBasePlayer@ pPlayer )
{
    if( pPlayer !is null )
    {
        dictionary gpArgs = { { 'name', string( pPlayer.pev.netname ) }, { 'time', fft::to_string( int( ckvd[ pPlayer, 'afkmanager_time' ] ) ) } };
        Language::Print( pPlayer, pJson[ 'player_left_afk', {} ], MKLANG::CHAT, gpArgs );
        Discord::print( string( pJson[ 'player_left_afk', {} ][ Discord::language() ] ), gpArgs );

        ckvd[ pPlayer, 'afkmanager_afk', false ];
        ckvd[ pPlayer, 'afkmanager_time', 0 ];

        if( bool( ckvd[ pPlayer, 'afkmanager_live' ] ) )
        {
            PlayerFuncs::RespawnPlayer( pPlayer );
        }
    }
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    if( bool( ckvd[ pPlayer, 'afkmanager_afk' ] ) )
    {
        if( g_Engine.time > float( ckvd[ pPlayer, 'afkmanager_think' ] ) )
        {
            ckvd[ pPlayer, 'afkmanager_time', int( ckvd[ pPlayer, 'afkmanager_time' ] ) + 1 ];
            ckvd[ pPlayer, 'afkmanager_think', g_Engine.time + 1.0f ];
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
            if( int( ckvd[ pPlayer, 'afkmanager_button' ] ) != pPlayer.pev.button )
            {
                ckvd[ pPlayer, 'afkmanager_button', pPlayer.pev.button ];
                ckvd[ pPlayer, 'afkmanager_time', 0 ];
            }

            if( g_Engine.time > float( ckvd[ pPlayer, 'afkmanager_think' ] ) )
            {
                int time =  int( ckvd[ pPlayer, 'afkmanager_time' ] );

                if( time >= MaxTime() )
                {
                    if( g_PlayerFuncs.GetNumPlayers() == g_Engine.maxClients
                    && ( g_PlayerFuncs.AdminLevel( pPlayer ) < AdminLevel_t::ADMIN_YES || !pJson[ 'protect admins', true ] ) )
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
                else if( g_PlayerFuncs.GetNumPlayers() == 1 )
                {
                    return HOOK_CONTINUE;
                }
                else if( time > ( MaxTime() - 10 ) )
                {
                    Language::Print( pPlayer, pJson[ 'afk_advice', {} ], MKLANG::HUDMSG, { { 'time', string( MaxTime() - time ) } } );
                }
                ckvd[ pPlayer, 'afkmanager_time', int( ckvd[ pPlayer, 'afkmanager_time' ] ) + 1 ];
                ckvd[ pPlayer, 'afkmanager_think', g_Engine.time + 1.0f ];
            }
        }
    }
    return HOOK_CONTINUE;
}
