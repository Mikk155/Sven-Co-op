/*
DOWNLOAD:

scripts/maps/mikk/trigger_hurt_remote.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/trigger_hurt_remote"
*/

#include "utils"

namespace trigger_hurt_remote
{
    CScheduledFunction@ g_HurtRemote = g_Scheduler.SetTimeout( "FindHurtRemotes", 1.0f );

    enum trigger_hurt_remote_flags{ DONT_GIB = 16 };

    void FindHurtRemotes()
    {
        CBaseEntity@ pHurt = null;

        while( ( @pHurt = g_EntityFuncs.FindEntityByClassname( pHurt, "trigger_hurt_remote" ) ) !is null )
        {
            if( pHurt.pev.SpawnFlagBitSet( DONT_GIB ) && pHurt !is null )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName","trigger_hurt_remote::DontGibTarget" },
                    { "m_iMode", "1" },
                    { "targetname", pHurt.GetTargetname() }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );
            }
        }
    }

    void DontGibTarget( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        CBaseEntity@ pHurt = null;

        while( ( @pHurt = g_EntityFuncs.FindEntityByClassname( pHurt, "trigger_hurt_remote" ) ) !is null )
        {
            if( pHurt.pev.SpawnFlagBitSet( DONT_GIB ) && pHurt !is null )
            {
                if( string( pHurt.pev.target ) == "!activator" && pActivator !is null )
                {
                    if( pActivator.IsPlayer() )
                    {
                        cast<CBasePlayer@>( pActivator ).GetObserver().StartObserver( pActivator.pev.origin, pActivator.pev.angles, false );
                    }
                    else
                    {
                        if( !string( cast<CBaseMonster@>( pActivator ).m_iszTriggerTarget ).IsEmpty() )
                        {
                            UTILS::Trigger( string( cast<CBaseMonster@>( pActivator ).m_iszTriggerTarget ), pActivator, pHurt, USE_TOGGLE, 0.0f );
                        }
                        g_EntityFuncs.Remove( pActivator );
                    }
                }
                else if( !string( pHurt.pev.target ).IsEmpty() )
                {
                    CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, string( pHurt.pev.target ) );
                    
                    if( pEntity !is null )
                    {
                        if( pEntity.IsPlayer() )
                        {
                            cast<CBasePlayer@>( pEntity ).GetObserver().StartObserver( pEntity.pev.origin, pEntity.pev.angles, false );
                        }
                        else
                        {
                            if( !string( cast<CBaseMonster@>( pEntity ).m_iszTriggerTarget ).IsEmpty() )
                            {
                                UTILS::Trigger( string( cast<CBaseMonster@>( pEntity ).m_iszTriggerTarget ), pEntity, pHurt, USE_TOGGLE, 0.0f );
                            }
                            g_EntityFuncs.Remove( pEntity );
                        }
                    }
                }
            }
        }
    }
}// end namespace