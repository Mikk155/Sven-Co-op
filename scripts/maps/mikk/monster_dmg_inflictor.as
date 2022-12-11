/*
DOWNLOAD:

scripts/maps/mikk/monster_dmg_inflictor.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/monster_dmg_inflictor"
*/

#include "utils"

namespace monster_dmg_inflictor
{
    CScheduledFunction@ g_DmgInflictors = g_Scheduler.SetTimeout( "CreateScript", 4.0f );

    void CreateScript()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            if( pEntity !is null
            && pEntity.GetCustomKeyvalues().GetKeyvalue( "$i_damage_inflictor" ).GetFloat() == 1
            && !string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ).IsEmpty() )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName","monster_dmg_inflictor::PassAttacker" },
                    { "m_iMode", "1" },
                    { "targetname", "DMG_INFLICTOR_" + string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ) }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

                UTILS::Debug( "[monster_dmg_inflictor::CreateScript]" );
                UTILS::Debug( "Created trigger_script for entity '" + pEntity.pev.classname + "'" );
                UTILS::Debug( "with target '" + string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ) + "'" );
                UTILS::Debug( "when TriggerCondition fired. Attacker will be passed as !activator" );
                g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "TriggerTarget", "DMG_INFLICTOR_" + string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ) );
            }
        }
    }

    void PassAttacker( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pActivator !is null )
        {
            string target = string( cast<CBaseMonster@>(pActivator).m_iszTriggerTarget ).SubString( 14, string( cast<CBaseMonster@>(pActivator).m_iszTriggerTarget ).Length() );

            CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );
            
            if( pInflictor !is null )
            {
                CBaseEntity@ pAttacker = ( pInflictor.IsPlayer() ) ? pInflictor : g_EntityFuncs.Instance( pInflictor.pev.owner );

                if( pAttacker !is null )
                {
                    UTILS::Trigger( target, pAttacker, pActivator, USE_TOGGLE, 0.0f );
                }
            }
        }
    }
}// end namespace