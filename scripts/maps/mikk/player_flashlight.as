#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'

namespace player_flashlight
{
    void Register()
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_flashlight' ) +
            g_ScriptInfo.Description( 'Afraid Of Monsters style limited flashlight' ) +
            g_ScriptInfo.Wiki( 'player_flashlight' ) +
            g_ScriptInfo.Author( 'Zorbos' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    // as_command flashlight flashlight amt
    CCVar g_Flashlight ( "flashlight", "100", "custom max flashlight", ConCommandFlag::AdminOnly );

    CScheduledFunction@ g_Think = g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );

    void Think()
    {
        if( atoi( g_Flashlight.GetString() ) == -1 )
        {
            return;
        }

        HUDTextParams pParams;
        pParams.x = 0.975;
        pParams.y = -0.93;
        pParams.a1 = 0;
        pParams.r1 = 255;
        pParams.fadeinTime = 0.0;
        pParams.fadeoutTime = 0.0;
        pParams.holdTime = 1.0;
        pParams.fxTime = 0.0;
        pParams.channel = 4;

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
            
            if( pPlayer is null )
                continue;

            int iFlashLight = atoi( g_Util.GetCKV( pPlayer, '$f_pf_flashlight' ) );

            if( iFlashLight > 20)
            {
                pParams.g1 = 255;
                pParams.b1 = 255;
            }
            else
            {
                pParams.g1 = 0;
                pParams.b1 = 0;
            }

            g_PlayerFuncs.HudMessage( pPlayer, pParams, string( iFlashLight )  + '%' );

            
            if( pPlayer.FlashlightIsOn() )
            {
                if( iFlashLight <= 0 )
                {
                    pPlayer.FlashlightTurnOff();
                }

                g_Util.SetCKV( pPlayer, '$f_pf_flashlight', atof( g_Util.GetCKV( pPlayer, '$f_pf_flashlight' ) ) - 0.1f );
            }

            pPlayer.m_iFlashBattery = atoi( g_Util.GetCKV( pPlayer, '$f_pf_flashlight' ) );
        }
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && pPlayer.HasSuit() )
        {
            g_Util.SetCKV( pPlayer, '$f_pf_flashlight', atof( g_Flashlight.GetString() ) );
        }
        return HOOK_CONTINUE;
    }
}