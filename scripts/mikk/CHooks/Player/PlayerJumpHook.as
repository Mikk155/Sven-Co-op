
namespace Hooks
{
    namespace Player
    {
        namespace PlayerJumpHook
        {
            funcdef HookReturnCode PlayerJumpHook( CBasePlayer@ );

            array<PlayerJumpHook@> PlayerJumpHooks;

            bool Register( ref @pFunction )
            {
                PlayerJumpHook@ pHook = cast<PlayerJumpHook@>( pFunction );

                if( pHook is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Player::PlayerJumpHook( CBasePlayer@ pPlayer ) Not found.\n' );
                    return false;
                }
                else
                {
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Player::PlayerJumpHook( CBasePlayer@ pPlayer ).\n' );

                    PlayerJumpHooks.insertLast( @pHook );

                    if( Hooks::m_bPlayerPreThinkHook == false )
                    {
                        Hooks::m_bPlayerPreThinkHook = g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
                    }
                    return true;
                }
            }

            void Remove( ref @pFunction )
            {
                PlayerJumpHook@ pHook = cast<PlayerJumpHook@>( pFunction );

                if( PlayerJumpHooks.findByRef( pHook ) >= 0 )
                {
                    PlayerJumpHooks.removeAt( PlayerJumpHooks.findByRef( pHook ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerJump.\n' );
                }
                else
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerJump.\n' );
                }
                CheckPlayerPreThinkHook();
            }

            void RemoveAll()
            {
                PlayerJumpHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Player::PlayerJumpPlayerJump.\n' );
                CheckPlayerPreThinkHook();
            }

            void PlayerJumpFunction( CBasePlayer@ pPlayer )
            {
                if( pPlayer !is null && PlayerJumpHooks.length() > 0 )
                {
                    if( pPlayer.pev.button & IN_JUMP != 0 && pPlayer.pev.flags & FL_ONGROUND != 0 )
                    {
                        for( uint ui = 0; ui < PlayerJumpHooks.length(); ui++ )
                        {
                            PlayerJumpHook@ pHook = cast<PlayerJumpHook@>( PlayerJumpHooks[ui] );

                            if( pHook !is null && pHook( pPlayer ) == HOOK_HANDLED )
                            {
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}