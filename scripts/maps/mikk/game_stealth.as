// -TODO custom AS function pass spotted and monster
#include "utils"

namespace game_stealth
{
    void Register()
    {
        g_Scheduler.SetInterval( "game_stealth_think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'game_stealth' ) +
            g_ScriptInfo.Description( 'Stealth gamemode' ) +
            g_ScriptInfo.Wiki( 'game_stealth' ) +
            g_ScriptInfo.Author( 'Gaftherman' ) +
            g_ScriptInfo.GetGithub( 'Gaftherman' ) +
            g_ScriptInfo.GetDiscord()
        );
    }

    void game_stealth_think()
    {
        CBaseEntity@ pMoster = null;

        while( ( @pMoster = g_EntityFuncs.FindEntityByClassname( pMoster, "monster_*" ) ) !is null )
        {
            if( pMoster.IsMonster() && atoi( g_Util.GetCKV( pMoster, "$i_stealth" ) ) == 1 && pMoster.IsAlive() )
            {
                CBaseMonster@ pEnemy = cast<CBaseMonster@>( pMoster );

                if( pEnemy.m_hEnemy.GetEntity() !is null )
                {
                    CBaseEntity@ pSpotted = cast<CBaseEntity@>( pEnemy.m_hEnemy.GetEntity() );

                    if( atoi( g_Util.GetCKV( pMoster, "$i_stealthmode" ) ) == 0 )
                    {
                        if( !string( cast<CBaseMonster@>( pSpotted ).m_iszTriggerTarget ).IsEmpty() )
                        {
                            g_EntityFuncs.FireTargets( string( cast<CBaseMonster@>( pSpotted ).m_iszTriggerTarget ), pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                        }

                        g_EntityFuncs.Remove( pSpotted );
                        g_EntityFuncs.FireTargets( pEnemy.pev.target, pSpotted, pEnemy, USE_TOGGLE, 0.0f );
                    }

                    if( pSpotted.IsPlayer() )
                    {
                        CBasePlayer@ pPlayer = cast<CBasePlayer@>( pEnemy.m_hEnemy.GetEntity() );

                        if( pPlayer !is null )
                        {
                            pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
                            g_Util.Trigger( g_Util.GetCKV( pEnemy, '$s_stealth_target' ), pSpotted, pEnemy, USE_TOGGLE, atof( g_Util.GetCKV( pEnemy, '$f_stealth_delay' ) ) );
                        }
                    }

                    if( g_Util.GetCKV( pEnemy, '$s_stealth_function' ) != '' )
                    {
                        g_Reflection.TriggerFunction( g_Util.GetCKV( pEnemy, '$s_stealth_function' ) );
                    }
                    pEnemy.m_hEnemy = null;
                }
            }
        }
    }
}