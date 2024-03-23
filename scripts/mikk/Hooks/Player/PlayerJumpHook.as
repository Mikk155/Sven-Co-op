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
namespace Player {
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