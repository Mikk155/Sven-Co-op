/*
DOWNLOAD:

scripts/maps/mikk/trigger_individual.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/trigger_individual"

*/

#include "utils"

namespace trigger_individual
{
    CScheduledFunction@ g_Renders = g_Scheduler.SetTimeout( "FindIndividualTriggers", 0.0f );

    array<string> Entities =
    {
        "func_button",
        "trigger_multiple",
        "trigger_relay",
        "item_*",
        "ammo_*",
        "weapon_*"
    };

    void FindIndividualTriggers()
    {
        for( uint i = 0; i < Entities.length(); ++i )
        {
            CBaseEntity@ pEntity = null;

            while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, Entities[i] ) ) !is null)
            {
                if( pEntity is null )
                    continue;

                if( pEntity.GetCustomKeyvalues().GetKeyvalue( "$i_trigger_individual" ).GetFloat() == 1 )
                {
                    dictionary g_keyvalues =
                    {
                        { "m_iszScriptFunctionName","trigger_individual::TriggerIndividually" },
                        { "m_iMode", "1" },
                        { "targetname", "individual_" + string( pEntity.pev.target ) }
                    };
                    g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

                    //pEntity.pev.target = "individual_" + string( pEntity.pev.target );
                    g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "target", "individual_" + string( pEntity.pev.target ) );
                }
            }
        }
    }

    void TriggerIndividually( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pActivator is null or pCaller is null )
            return;

        string target = string( pCaller.pev.target ).SubString( 11, string( pCaller.pev.target ).Length() );

        if( !pActivator.GetCustomKeyvalues().HasKeyvalue( "$i_fireonce_" + target ) )
        {
            pActivator.GetCustomKeyvalues().SetKeyvalue("$i_fireonce_" + target, 1 );
            UTILS::Trigger( target, pActivator, pCaller, useType, 0.0f );
        }
    }
}