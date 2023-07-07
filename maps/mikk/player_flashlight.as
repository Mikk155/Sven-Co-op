#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'

namespace player_flashlight
{
    void Register()
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @player_flashlight::PlayerSpawn );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_flashlight' ) +
            g_ScriptInfo.Description( 'Afraid Of Monsters style limited flashlight' ) +
            g_ScriptInfo.Wiki( 'player_flashlight' ) +
            g_ScriptInfo.Author( 'Zorbos' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    CCVar g_Flashlight ( "flashlight", "200", "custom max flashlight", ConCommandFlag::AdminOnly );

    CScheduledFunction@ g_Think = g_Scheduler.SetInterval( "Think", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );

    RGBA BatteryColor1 = RGBA( 255, 255, 255, 0 );
    RGBA BatteryColor2 = RGBA( 255, 0, 0, 0 );
    bool HideMessage = false;

    void Think()
    {
        if( atoi( g_Flashlight.GetString() ) == -1 )
        {
            return;
        }

        HUDTextParams pParams;
        pParams.x = 0.975;
        pParams.y = -0.93;
        pParams.fadeinTime = 0.0;
        pParams.fadeoutTime = 0.0;
        pParams.holdTime = 1.0;
        pParams.fxTime = 0.0;
        pParams.channel = 3;

        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
            
            if( pPlayer is null )
                continue;

            int iFlashLight = atoi( g_Util.CKV( pPlayer, '$f_pf_flashlight' ) );

            if( iFlashLight > 20)
            {
                pParams.a1 = BatteryColor1.a;
                pParams.r1 = BatteryColor1.r;
                pParams.g1 = BatteryColor1.g;
                pParams.b1 = BatteryColor1.b;
            }
            else
            {
                pParams.a1 = BatteryColor2.a;
                pParams.r1 = BatteryColor2.r;
                pParams.g1 = BatteryColor2.g;
                pParams.b1 = BatteryColor2.b;
            }

            float CurrentPercentage = ( float( iFlashLight ) / atof( g_Flashlight.GetString() ) ) *100;

            if( !HideMessage )
            {
                g_PlayerFuncs.HudMessage( pPlayer, pParams, string( int( CurrentPercentage ) )  + '%' );
            }
            
            if( pPlayer.FlashlightIsOn() )
            {
                if( iFlashLight <= 0 )
                {
                    pPlayer.FlashlightTurnOff();
                }
                else
                {
                    g_Util.CKV( pPlayer, '$f_pf_flashlight', atof( g_Util.CKV( pPlayer, '$f_pf_flashlight' ) ) - 0.1f );
                }
            }

            pPlayer.m_iFlashBattery = int( CurrentPercentage );
        }
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && pPlayer.HasSuit() )
        {
            g_Util.CKV( pPlayer, '$f_pf_flashlight', atof( g_Flashlight.GetString() ) );
        }
        return HOOK_CONTINUE;
    }
}
