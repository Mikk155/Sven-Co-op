
namespace Hooks {
namespace Player {
namespace PlayerObserverModeHook
{
    funcdef HookReturnCode PlayerObserverModeHook( CBasePlayer@, ObserverMode );

    array<PlayerObserverModeHook@> PlayerObserverModeHooks;

    bool Register( ref @pFunction )
    {
        PlayerObserverModeHook@ pHook = cast<PlayerObserverModeHook@>( pFunction );

        if( pHook is null )
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Player::PlayerObserverModeHook( CBasePlayer@ pPlayer ) Not found.\n' );
            return false;
        }
        else
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Player::PlayerObserverModeHook( CBasePlayer@ pPlayer ).\n' );

            PlayerObserverModeHooks.insertLast( @pHook );

            if( Hooks::m_bPlayerPreThinkHook == false )
            {
                Hooks::m_bPlayerPreThinkHook = g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
            }
            return true;
        }
    }

    void Remove( ref @pFunction )
    {
        PlayerObserverModeHook@ pHook = cast<PlayerObserverModeHook@>( pFunction );

        if( PlayerObserverModeHooks.findByRef( pHook ) >= 0 )
        {
            PlayerObserverModeHooks.removeAt( PlayerObserverModeHooks.findByRef( pHook ) );
            g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerObserverModeHook.\n' );
        }
        else
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerObserverModeHook.\n' );
        }
        CheckPlayerPreThinkHook();
    }

    void RemoveAll()
    {
        PlayerObserverModeHooks.resize( 0 );
        g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Player::PlayerObserverModeHook.\n' );
        CheckPlayerPreThinkHook();
    }

    void PlayerObserverModeFunction( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && PlayerObserverModeHooks.length() > 0 )
        {
            int m_iUserData = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_observermode' ).GetInteger();

            if( pPlayer.pev.iuser1 != m_iUserData )
            {
                for( uint ui = 0; ui < PlayerObserverModeHooks.length(); ui++ )
                {
                    PlayerObserverModeHook@ pHook = cast<PlayerObserverModeHook@>( PlayerObserverModeHooks[ui] );

                    if( pHook !is null && pHook( pPlayer, ObserverMode( pPlayer.pev.iuser1 ) ) == HOOK_HANDLED )
                    {
                        break;
                    }
                }
            }
            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_observermode', string( pPlayer.pev.iuser1 ) );
        }
    }
}
}
}