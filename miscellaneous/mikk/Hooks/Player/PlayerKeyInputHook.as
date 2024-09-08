
namespace Hooks {
namespace Player {
namespace PlayerKeyInputHook
{
    funcdef HookReturnCode PlayerKeyInputHook( CBasePlayer@, In_Buttons, const bool );

    array<PlayerKeyInputHook@> PlayerKeyInputHooks;

    bool Register( ref @pFunction )
    {
        PlayerKeyInputHook@ pHook = cast<PlayerKeyInputHook@>( pFunction );

        if( pHook is null )
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Player::PlayerKeyInputHook( CBasePlayer@, In_Buttons m_iButton, const bool m_bReleased ) Not found.\n' );
            return false;
        }
        else
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Player::PlayerKeyInputHook( CBasePlayer@, In_Buttons m_iButton, const bool m_bReleased ).\n' );

            PlayerKeyInputHooks.insertLast( @pHook );

            if( Hooks::m_bPlayerPreThinkHook == false )
            {
                Hooks::m_bPlayerPreThinkHook = g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
            }
            return true;
        }
    }

    void Remove( ref @pFunction )
    {
        PlayerKeyInputHook@ pHook = cast<PlayerKeyInputHook@>( pFunction );

        if( PlayerKeyInputHooks.findByRef( pHook ) >= 0 )
        {
            PlayerKeyInputHooks.removeAt( PlayerKeyInputHooks.findByRef( pHook ) );
            g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerKeyInput.\n' );
        }
        else
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerKeyInput.\n' );
        }
        CheckPlayerPreThinkHook();
    }

    void RemoveAll()
    {
        PlayerKeyInputHooks.resize( 0 );
        g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Player::PlayerKeyInput.\n' );
        CheckPlayerPreThinkHook();
    }

    array<int> iBits =
    {
        1,      // IN_ATTACK
        2,      // IN_JUMP
        4,      // IN_DUCK
        8,      // IN_FORWARD
        16,     // IN_BACK
        32,     // IN_USE
        64,     // IN_CANCEL
        128,    // IN_LEFT
        256,    // IN_RIGHT
        512,    // IN_MOVELEFT
        1024,   // IN_MOVERIGHT
        2048,   // IN_ATTACK2
        4096,   // IN_RUN
        8192,   // IN_RELOAD
        16384,  // IN_ALT1
        32768   // IN_SCORE
    };

    void PlayerKeyInputFunction( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null || PlayerKeyInputHooks.length() > 0 )
        {
            for( uint uib = 0; uib < iBits.length(); uib++ )
            {
                int iOldButton = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_keyinput_' + iBits[ uib ] ).GetInteger();

                if( pPlayer.pev.button & In_Buttons( iBits[ uib ] ) != iOldButton )
                {
                    for( uint ui = 0; ui < PlayerKeyInputHooks.length(); ui++ )
                    {
                        PlayerKeyInputHook@ pHook = cast<PlayerKeyInputHook@>( PlayerKeyInputHooks[ui] );

                        if( pHook !is null && pHook( pPlayer, In_Buttons( iBits[ uib ] ), ( iOldButton == 0 ? false : true ) ) == HOOK_HANDLED )
                        {
                            break;
                        }
                    }
                }
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_keyinput_' + iBits[ uib ], string( pPlayer.pev.button & In_Buttons( iBits[ uib ] ) ) );
            }
        }
    }
}
}
}