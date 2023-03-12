#include "utils"
namespace env_render
{
    CScheduledFunction@ g_Renders = g_Scheduler.SetTimeout( "FindEnvRenders", 0.0f );

    void FindEnvRenders()
    {
        CBaseEntity@ pRender = null;

        while( ( @pRender = g_EntityFuncs.FindEntityByClassname( pRender, "env_render" ) ) !is null )
        {
            if( pRender.pev.SpawnFlagBitSet( 32 ) && pRender !is null )
            {
                if( string( pRender.pev.targetname ).IsEmpty() || string( pRender.pev.target ).IsEmpty() || string( pRender.pev.renderamt ).IsEmpty() ){continue;}

                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName", "env_render::Use" },
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

        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#env_render\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow env_render to gradually fade its target.\n"
        );
    }

    void Use( CBaseEntity@ pTriggerScript )
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
                g_Util.Trigger( string( pTriggerScript.pev.netname ), pTriggerScript, pTriggerScript, USE_TOGGLE, 0.0f );
                g_EntityFuncs.FireTargets( string( pTriggerScript.pev.targetname ), pTriggerScript, pTriggerScript, USE_OFF, 0.0f );
            }
        }
    }
}
// End of namespace