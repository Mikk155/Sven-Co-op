#include "utils"
namespace monster_damage_inflictor
{
    CScheduledFunction@ g_DmgInflictors = g_Scheduler.SetTimeout( "CreateScript", 0.0f );

    void CreateScript()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            if( pEntity !is null
            && !string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ).IsEmpty()
            && pEntity.GetCustomKeyvalues().GetKeyvalue( "$i_damage_inflictor" ).GetInteger() == 1 )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName","monster_damage_inflictor::PassAttacker" },
                    { "m_iMode", "1" },
                    { "targetname", "DMG_INFLICTOR_" + string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ) }
                };
                CBaseEntity@ pScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

                if( pScript !is null )
                    g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "TriggerTarget", "DMG_INFLICTOR_" + string( cast<CBaseMonster@>(pEntity).m_iszTriggerTarget ) );
            }
        }

        g_Util.ScriptAuthor.insertLast
        (
            "Script: monster_damage_inflictor\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Feature for passing a monster's Attacker/damage inflictor as a !activator.\n"
        );
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
                    g_EntityFuncs.FireTargets( target, pAttacker, pActivator, USE_TOGGLE, 0.0f );
                }
            }
        }
    }
}// end namespace