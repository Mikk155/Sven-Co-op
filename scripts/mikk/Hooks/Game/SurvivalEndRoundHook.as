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

namespace Hooks {
namespace Game {
/*@
    @prefix Hooks::Game::SurvivalEndRoundHook SurvivalEndRoundHook
    @body Hooks::Game
    Called once when a survival mode round ends at the moment there is no more alive players.
*/
namespace SurvivalEndRoundHook
{
    /*@
        @prefix SurvivalEndRoundHook
        Called once when a survival mode round ends at the moment there is no more alive players.
    */
    funcdef HookReturnCode SurvivalEndRoundHook();

    array<SurvivalEndRoundHook@> SurvivalEndRoundHooks;

    bool Register( ref @pFunction )
    {
        SurvivalEndRoundHook@ pHook = cast<SurvivalEndRoundHook@>( pFunction );

        if( pHook is null )
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Game::SurvivalEndRoundHook() Not found.\n' );
            return false;
        }
        else
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Game::SurvivalEndRoundHook().\n' );

            SurvivalEndRoundHooks.insertLast( @pHook );

            if( g_SurvivalEndRound.Think is null )
            {
                @g_SurvivalEndRound.Think = g_Scheduler.SetInterval( @g_SurvivalEndRound, "EndRoundThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
            }
            return true;
        }
    }

    void Remove( ref @pFunction )
    {
        SurvivalEndRoundHook@ pHook = cast<SurvivalEndRoundHook@>( pFunction );

        if( SurvivalEndRoundHooks.findByRef( pHook ) >= 0 )
        {
            SurvivalEndRoundHooks.removeAt( SurvivalEndRoundHooks.findByRef( pHook ) );
            g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Game::SurvivalEndRound.\n' );
        }
        else
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Game::SurvivalEndRound.\n' );
        }

        if( SurvivalEndRoundHooks.length() < 1 && g_SurvivalEndRound.Think !is null )
            g_Scheduler.RemoveTimer( g_SurvivalEndRound.Think );
    }

    void RemoveAll()
    {
        SurvivalEndRoundHooks.resize( 0 );
        g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Game::SurvivalEndRound.\n' );

        if( SurvivalEndRoundHooks.length() < 1 && g_SurvivalEndRound.Think !is null )
            g_Scheduler.RemoveTimer( g_SurvivalEndRound.Think );
    }

    CSurvivalEndRound g_SurvivalEndRound;

    class CSurvivalEndRound
    {
        CScheduledFunction@ Think = null;
        bool SurvivalEndRoundEnded( bool blEnded = false )
        {
            CBaseEntity@ pTarget = g_EntityFuncs.FindEntityByTargetname( null, "SurvivalEndRoundEndedHook" );

            if( pTarget is null )
            {
                @pTarget = Mikk.EntityFuncs.CreateEntity( { { 'classname', 'info_target' }, { 'targetname', 'SurvivalEndRoundEndedHook' } } );
            }

            if( pTarget !is null )
            {
                if( blEnded )
                    CustomKeyValue( pTarget, "$i_roundended", 1 );
                return ( CustomKeyValue( pTarget, "$i_roundended" ) == 1 );
            }
            return false;
        }

        void EndRoundThink()
        {
            if( !SurvivalEndRoundEnded() && SurvivalEndRoundHooks.length() > 0 && g_SurvivalMode.IsActive() && g_PlayerFuncs.GetNumPlayers() > 0 )
            {
                int iAlivePlayers = 0, iAllPlayers = 0;

                for( int iIndex = 1; iIndex <= g_Engine.maxClients; ++iIndex )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iIndex );

                    if( pPlayer !is null )
                    {
                        if( pPlayer.IsAlive() )
                        {
                            ++iAlivePlayers;
                        }
                        ++iAllPlayers;
                    }
                }

                if( iAllPlayers > 0 && iAlivePlayers == 0 )
                {
                    for( uint ui = 0; ui < SurvivalEndRoundHooks.length(); ui++ )
                    {
                        SurvivalEndRoundHook@ pHook = cast<SurvivalEndRoundHook@>( SurvivalEndRoundHooks[ui] );

                        if( pHook !is null && pHook() == HOOK_HANDLED )
                        {
                            break;
                        }
                    }
                    SurvivalEndRoundEnded( true );
                }
            }
        }
    }
}
}
}