#include "utils/CGetInformation"
#include "utils/CUtils"
#include "utils/Reflection"

namespace game_stealth
{
    CScheduledFunction@ g_Think = null;

    void Register()
    {
        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'game_stealth' ) +
            g_ScriptInfo.Description( 'Stealth gamemode' ) +
            g_ScriptInfo.Wiki( 'game_stealth' ) +
            g_ScriptInfo.Author( 'Gaftherman' ) +
            g_ScriptInfo.GetGithub( 'Gaftherman' ) +
            g_ScriptInfo.GetDiscord()
        );

        if( g_Think !is null )
        {
            g_Scheduler.RemoveTimer( g_Think );
        }

        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "game_stealth*" ) ) !is null )
        {
            if( pEntity.IsMonster() )
            {
                @g_Think = g_Scheduler.SetInterval( "Think", 0.1f );
                break;
            }
        }
    }

    void Think()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, "game_stealth*" ) ) !is null )
        {
            if( pEntity.IsMonster() && pEntity.IsAlive() )
            {
                CBaseMonster@ pMonster = cast<CBaseMonster@>( pEntity );

                if( pMonster.m_hEnemy.GetEntity() !is null )
                {
                    CBaseEntity@ SpottedMonster = cast<CBaseEntity@>( pMonster.m_hEnemy.GetEntity() );

                    if( SpottedMonster !is null )
                    {
                        bool trigger = false;

                        int iKillMode = atoi( g_Util.CKV( pMonster, "$i_stealthKillmode" ) );

                        if( atoi( g_Util.CKV( pMonster, "$i_stealthmode" ) ) == 0 && SpottedMonster.IsMonster() )
                        {
                            if( iKillMode == 0 )
                            {
                                SpottedMonster.TakeDamage( null, null, SpottedMonster.pev.max_health, DMG_GENERIC );
                            }
                            else if( iKillMode == 1 )
                            {
                                string m_iszTriggerTarget = string( cast<CBaseMonster@>( SpottedMonster ).m_iszTriggerTarget );

                                if( !m_iszTriggerTarget.IsEmpty() )
                                {
                                    g_Util.Trigger( m_iszTriggerTarget, SpottedMonster, pMonster );
                                }

                                g_EntityFuncs.Remove( SpottedMonster );
                            }

                            trigger = true;
                        }

                        if( SpottedMonster.IsPlayer() )
                        {
                            CBasePlayer@ pPlayer = cast<CBasePlayer@>( SpottedMonster );

                            if( pPlayer !is null )
                            {
                                if( iKillMode == 0 )
                                {
                                    pPlayer.TakeDamage( null, null, pPlayer.pev.max_health, DMG_GENERIC );
                                }
                                else if( iKillMode == 1 )
                                {
                                    pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, atobool( g_Util.CKV( pMonster, "$i_stealthdeadbody" ) ) );
                                }

                                trigger = true;
                            }
                        }

                        if( trigger )
                        {
                            g_Util.Trigger( g_Util.CKV( pEntity, "$s_stealthspottarget" ), SpottedMonster, pMonster, USE_TOGGLE, atof( g_Util.CKV( pMonster, '$f_stealth_delay' ) ) );

                            if( atoi( g_Util.CKV( pMonster, "$i_stealthmemory" ) ) == 0 )
                            {
                                pMonster.m_hEnemy = null;
                            }
                        }
                    }
                }
            }
        }
    }
}