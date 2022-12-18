/*
DOWNLOAD:

scripts/maps/mikk/env_render.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/env_render"

*/

#include "utils"

namespace env_render
{
    enum env_render_gradual_flags{ GRADUALLY_RENDER = 32 };

    CScheduledFunction@ g_Renders = g_Scheduler.SetTimeout( "FindEnvRenders", 0.0f );

    void FindEnvRenders()
    {
        CBaseEntity@ pRender = null;

        while( ( @pRender = g_EntityFuncs.FindEntityByClassname( pRender, "env_render" ) ) !is null )
        {
            if( pRender.pev.SpawnFlagBitSet( GRADUALLY_RENDER ) && pRender !is null )
            {
                if( string( pRender.pev.targetname ).IsEmpty() || string( pRender.pev.target ).IsEmpty() || string( pRender.pev.renderamt ).IsEmpty() ){continue;}

                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName", "env_render::RenderGraduallyFade" },
                    { "m_iMode", "2" },
                    { "target", string( pRender.pev.target ) },
                    { "netname", string( pRender.pev.netname ) },
                    { "m_flThinkDelta", ( string( pRender.pev.health ).IsEmpty() ) ? "0.045" : string( pRender.pev.health ) },
                    { "renderamt", string( pRender.pev.renderamt ) },
                    { "targetname", pRender.GetTargetname() }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );
                g_EntityFuncs.Remove( pRender );
            }
        }
    }

    void RenderGraduallyFade( CBaseEntity@ pTriggerScript )
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, string( pTriggerScript.pev.target ) ) ) !is null)
        {
            if( pTriggerScript.pev.renderamt > pEntity.pev.renderamt )
            {
                pEntity.pev.renderamt += ( pTriggerScript.pev.frags <= 0 ) ? 1 : int( pTriggerScript.pev.frags );
            }
            else
            {
                pEntity.pev.renderamt -= ( pTriggerScript.pev.frags <= 0 ) ? 1 : int( pTriggerScript.pev.frags );
            }

            if( pEntity.pev.renderamt == pTriggerScript.pev.renderamt )
            {
                UTILS::Trigger( string( pTriggerScript.pev.netname ), pTriggerScript, pTriggerScript, USE_TOGGLE, 0.0f );
                UTILS::Trigger( string( pTriggerScript.pev.targetname ), pTriggerScript, pTriggerScript, USE_OFF, 0.0f );
            }
        }
    }
}// end namespace