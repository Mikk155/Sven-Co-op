
namespace Hooks
{
    namespace Player
    {
        namespace PlayerFlashLightHook
        {
            funcdef HookReturnCode PlayerFlashLightHook( CBasePlayer@, const bool, int&out, int&out );

            array<PlayerFlashLightHook@> PlayerFlashLightHooks;

            bool Register( ref @pFunction )
            {
                PlayerFlashLightHook@ pHook = cast<PlayerFlashLightHook@>( pFunction );

                if( pHook is null )
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Player::PlayerFlashLightHook( CBasePlayer@ pPlayer, const bool m_bIsActive, int&out m_iRechargeSpeed, int&out m_iConsumeSpeed ) Not found.\n' );
                    return false;
                }
                else
                {
                    g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Player::PlayerFlashLightHook( CBasePlayer@ pPlayer, const bool m_bIsActive, int&out m_iRechargeSpeed, int&out m_iConsumeSpeed ).\n' );

                    PlayerFlashLightHooks.insertLast( @pHook );

                    if( Hooks::m_bPlayerPreThinkHook == false )
                    {
                        Hooks::m_bPlayerPreThinkHook = g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
                    }
                    return true;
                }
            }

            void Remove( ref @pFunction )
            {
                PlayerFlashLightHook@ pHook = cast<PlayerFlashLightHook@>( pFunction );

                if( PlayerFlashLightHooks.findByRef( pHook ) >= 0 )
                {
                    PlayerFlashLightHooks.removeAt( PlayerFlashLightHooks.findByRef( pHook ) );
                    g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerFlashLight.\n' );
                }
                else
                {
                    g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerFlashLight.\n' );
                }
                CheckPlayerPreThinkHook();
            }

            void RemoveAll()
            {
                PlayerFlashLightHooks.resize( 0 );
                g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Player::PlayerFlashLight.\n' );
                CheckPlayerPreThinkHook();
            }

            void PlayerFlashLightFunction( CBasePlayer@ pPlayer )
            {
                if( pPlayer !is null && PlayerFlashLightHooks.length() > 0 )
                {
                    if( pPlayer.pev.impulse == 100 )
                    {
                        for( uint ui = 0; ui < PlayerFlashLightHooks.length(); ui++ )
                        {
                            int m_iRechargeSpeed = 1;
                            int m_iConsumeSpeed = 1;

                            PlayerFlashLightHook@ pHook = cast<PlayerFlashLightHook@>( PlayerFlashLightHooks[ui] );

                            if( pHook !is null )
                            {
                                HookReturnCode m_uiHook = pHook( pPlayer, !pPlayer.FlashlightIsOn(), m_iRechargeSpeed, m_iConsumeSpeed );

                                if( m_iRechargeSpeed != 1 )
                                {
                                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight', string( m_iRechargeSpeed ) );
                                }

                                if( m_iConsumeSpeed != 1 )
                                {
                                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consume', string( m_iConsumeSpeed ) );
                                }

                                if( m_uiHook == HOOK_HANDLED )
                                {
                                    break;
                                }
                            }
                        }
                    }

                    // This is somewhat stupid, this should have been a feature a long ago
                    if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight' ) )
                    {
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight', 1 );
                    }

                    int m_iRechargeSpeed = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight' ).GetInteger();

                    if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_consume' ) )
                    {
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consume', 1 );
                    }

                    int m_iConsumeSpeed = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_consume' ).GetInteger();

                    if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_battery' ) )
                    {
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                    }

                    int m_iBattery = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_battery' ).GetInteger();

                    if( pPlayer.pev.effects & EF_DIMLIGHT != 0 )
                    {
                        if( m_iConsumeSpeed != 1 )
                        {
                            if( m_iBattery - 1 == pPlayer.m_iFlashBattery )
                            {
                                if( m_iConsumeSpeed > 1 )
                                {
                                    pPlayer.m_iFlashBattery -= m_iConsumeSpeed;
                                }
                                else if( m_iConsumeSpeed == 0 )
                                {
                                    pPlayer.m_iFlashBattery = m_iBattery;
                                }
                                else if( m_iConsumeSpeed < 0 )
                                {
                                    if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_consumespeed' ) )
                                    {
                                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iConsumeSpeed );
                                    }

                                    int m_iNextConsume = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_consumespeed' ).GetInteger();

                                    if( m_iNextConsume == 0 )
                                    {
                                        pPlayer.m_iFlashBattery -= 1;
                                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iConsumeSpeed );
                                    }
                                    else
                                    {
                                        pPlayer.m_iFlashBattery = m_iBattery;
                                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_consumespeed', m_iNextConsume + 1 );
                                    }
                                }
                            }
                        }
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                    }
                    else if( m_iRechargeSpeed != 1 )
                    {
                        if( m_iBattery + 1 == pPlayer.m_iFlashBattery )
                        {
                            pPlayer.m_iFlashBattery = m_iBattery;

                            if( !pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_hooks_flashlight_chargespeed' ) )
                            {
                                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iRechargeSpeed );
                            }

                            int m_iNextRecharge = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_chargespeed' ).GetInteger();

                            if( m_iRechargeSpeed < 0 )
                            {
                                if( m_iNextRecharge == 0 )
                                {
                                    if( pPlayer.m_iFlashBattery < 100 )
                                    {
                                        pPlayer.m_iFlashBattery += 1;
                                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iRechargeSpeed );
                                    }
                                }
                                else
                                {
                                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_chargespeed', m_iNextRecharge + 1 );
                                }
                            }
                            else if( m_iRechargeSpeed > 1 )
                            {
                                if( pPlayer.m_iFlashBattery < 100 )
                                {
                                    pPlayer.m_iFlashBattery += m_iNextRecharge;
                                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                                }
                            }
                        }
                        else
                        {
                            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                        }
                    }

                    int m_iFix = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$i_hooks_flashlight_battery' ).GetInteger();

                    if( pPlayer.m_iFlashBattery > 100 || m_iFix > 100 )
                    {
                        pPlayer.m_iFlashBattery = 100;
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                    }
                    else if( pPlayer.m_iFlashBattery <= 1 || m_iFix <= 1 )
                    {
                        pPlayer.m_iFlashBattery = 1;
                        g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$i_hooks_flashlight_battery', pPlayer.m_iFlashBattery );
                    }

                    if( pPlayer.m_iFlashBattery <= 1 )
                    {
                        pPlayer.pev.impulse = 0;
                    }
                }
            }
        }
    }
}