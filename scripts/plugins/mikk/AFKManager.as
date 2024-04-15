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

#include '../../mikk/shared'

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );

    Mikk.UpdateTimer( g_Think, 'Think', 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );

    pJson.load( "plugins/mikk/AFKManager.json" );
}

json pJson;

int AFKMaxTime = 500;

CScheduledFunction@ g_Think = null;

HookReturnCode ClientSay( SayParameters@ pParams )
{
    if( pParams.GetArguments()[0] == '/afk' )
    {
        Join( pParams.GetPlayer(), true );
    }
    return HOOK_CONTINUE;
}

dictionary Players;

void Join( CBasePlayer@ pPlayer, bool &in ByChat = false )
{
    if( pPlayer !is null && string( Players[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] ) != 'AFK' )
    {
        Players[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'AFK';

        if( !ByChat )
        {
            Mikk.Language.Print( pPlayer, pJson[ 'youve_moved_afk', {} ], MKLANG::CHAT );
            Mikk.Language.Print( pPlayer, pJson[ 'player_join_afk', {} ], MKLANG::CHAT, { { 'name', string( pPlayer.pev.netname ) } } );
        }

        CustomKeyValue( pPlayer, '$i_afkmanager_isafk', 1 );

        /*if( GetLPLevel( pPlayer ) > LP_NONE )
        {
            CustomKeyValue( pPlayer, '$i_afkmanager_live', ( pPlayer.IsAlive() ? '1' : '0' ) );
        }*/

        if( pPlayer.IsAlive() )
        {
            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
        }
    }
}

void Think()
{
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if( pPlayer is null || !pPlayer.IsConnected() )
            return;

        if( string( Players[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] ) == 'AFK' )
        {
            if( pPlayer.IsAlive() )
            {
                pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
            }

            Mikk.Language.Print( pPlayer, pJson[ 'hold_to_exit', {} ], MKLANG::BIND );

            if( pPlayer.pev.button & IN_USE > 0 )
            {
                Mikk.Language.Print( pPlayer, pJson[ 'client_left_afk', {} ], MKLANG::CHAT );
                Mikk.Language.Print( pPlayer, pJson[ 'player_left_afk', {} ], MKLANG::CHAT, { { 'name', string( pPlayer.pev.netname ) } } );

                CustomKeyValue( pPlayer, '$i_afkmanager', 0 );
                Players[ string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) ] = 'notAFK';
                CustomKeyValue( pPlayer, '$i_afkmanager_isafk', 0 );
                pPlayer.pev.nextthink = 0.1f;

                int iKeepLife = 0;
                CustomKeyValue( pPlayer, '$i_afkmanager_live', iKeepLife );

                if( iKeepLife == 1 )
                {
                    CBaseEntity@ pSpawns = null;

                    while( ( @pSpawns = g_EntityFuncs.FindEntityByClassname( pSpawns, 'info_player_deathmatch' ) ) !is null )
                    {
                        if( g_PlayerFuncs.IsSpawnPointValid( pSpawns, pPlayer ) )
                        {
                            g_EntityFuncs.SetOrigin( pPlayer, pSpawns.pev.origin );
                            pPlayer.pev.angles = pSpawns.pev.angles;
                            pPlayer.Revive();
                            break;
                        }
                    }
                }

                return;
            }
            pPlayer.pev.nextthink = g_Engine.time + 3.0f;
            return;
        }

        if( pJson[ 'blacklist maps', {} ][ string( g_Engine.mapname ), false ] )
        {
            return;
        }

        Vector VecOrigin; atov( CustomKeyValue( pPlayer, '$v_afkmanager_origin', VecOrigin.ToString() ) );
        Vector VecAngles; atov( CustomKeyValue( pPlayer, '$v_afkmanager_angles', VecAngles.ToString() ) );
        int iAFKTime = 0;
        CustomKeyValue( pPlayer, '$i_afkmanager', iAFKTime );
        if( iAFKTime < 0 )
            iAFKTime = 0;

        if( pPlayer.IsAlive() )
        {
            if( iAFKTime == AFKMaxTime )
            {
                if( g_PlayerFuncs.GetNumPlayers() == g_Engine.maxClients /*&& GetLPLevel( pPlayer ) > 0*/ )
                {
                    Mikk.Language.Print( pPlayer, pJson[ 'kick_advice', {} ], MKLANG::CHAT, { { 'name', string( pPlayer.pev.netname ) } } );

                    g_EngineFuncs.ServerCommand
                    (
                        "kick #" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() )+ " \"" +
                        Mikk.Language.GetLanguage( pPlayer, pJson[ 'kick_reason', {} ] ) + "\"\n"
                    );
                }
                else
                {
                    Join( pPlayer );
                }
            }
            else if( iAFKTime > AFKMaxTime - 10 )
            {
                string sti = string( AFKMaxTime - iAFKTime );
                Mikk.Language.Print( pPlayer, pJson[ 'afk_advice', {} ], MKLANG::HUDMSG, { { 'time', sti } } );
                Mikk.Language.Print( pPlayer, pJson[ 'afk_advice', {} ], MKLANG::CONSOLE, { { 'time', sti } } );
            }

            if( pPlayer.pev.origin != VecOrigin && pPlayer.pev.angles != VecAngles )
            {
                CustomKeyValue( pPlayer, '$v_afkmanager_origin', pPlayer.pev.origin.ToString() );
                CustomKeyValue( pPlayer, '$v_afkmanager_angles', pPlayer.pev.angles.ToString() );
                CustomKeyValue( pPlayer, '$i_afkmanager', 0 );
            }
            else
            {
                CustomKeyValue( pPlayer, '$i_afkmanager', iAFKTime + 1 );
            }
        }
    }
}