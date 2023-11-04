
namespace Hooks
{
    namespace Game
    {
        namespace SurvivalEndRoundHook
        {
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
            }

            void RemoveAll()
            {
                SurvivalEndRoundHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Game::SurvivalEndRound.\n' );
            }

            CSurvivalEndRound g_SurvivalEndRound;

            class CSurvivalEndRound
            {
                CScheduledFunction@ Think = null;
                private bool SurvivalEndRoundEnded;

                void EndRoundThink()
                {
                    if( !SurvivalEndRoundEnded && SurvivalEndRoundHooks.length() > 0 && g_SurvivalMode.IsActive() && g_PlayerFuncs.GetNumPlayers() > 0 )
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
                            SurvivalEndRoundEnded = true;
                        }
                    }
                }
            }
        }
    }
}