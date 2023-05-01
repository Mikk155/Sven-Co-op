#include "utils"
namespace trigger_multiple_custom
{
    void Register()
    {
        g_Scheduler.SetTimeout( "trigger_multiple_custom_init", 0.0f );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_multiple_custom' ) +
            g_ScriptInfo.Description( 'Expands trigger_multiple entity' ) +
            g_ScriptInfo.Wiki( 'trigger_multiple_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    enum trigger_multiple_custom_spawnflags
    {
        MONSTERS = 1,
        NOCLIENTS = 2,
        PUSHABLES = 4,
        ITERATE_ALL_OCCUPANTS = 64
    };

    void trigger_multiple_custom_init()
    {
        CBaseEntity@ pTriggers = null;

        while( ( @pTriggers = g_EntityFuncs.FindEntityByClassname( pTriggers, "trigger_multiple" ) ) !is null )
        {
            if( pTriggers !is null )
            {
                if( g_Flag( pTriggers, ITERATE_ALL_OCCUPANTS ) || g_GetDelay( pTriggers ) > 0.0 )
                {
                    string iszTriggerScript = "trigger_multiple_custom_" + string( pTriggers.pev.target );
                    dictionary g_keyvalues =
                    {
                        { "m_iszScriptFunctionName", "trigger_multiple_custom::TriggerOccupants" },
                        { "m_iMode", "1" },
                        { "targetname", iszTriggerScript }
                    };
                    CBaseEntity@ pTriggerScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues, true );

                    if( pTriggerScript !is null )
                    {
                        g_EntityFuncs.DispatchKeyValue( pTriggers.edict(), "target", iszTriggerScript );
                        
                        if( g_GetDelay( pTriggers ) > 0.0 )
                        {
                            g_EntityFuncs.DispatchKeyValue( pTriggers.edict(), "wait", "0.1" );
                        }
                    }
                }
            }
        }
    }

    void TriggerOccupants( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pCaller !is null )
        {
            if( g_Flag( pCaller, MONSTERS ) )
            {
                g_TriggerTarget( 'monster*', pCaller );
            }

            if( !g_Flag( pCaller, NOCLIENTS ) )
            {
                g_TriggerTarget( 'player', pCaller );
            }

            if( g_Flag( pCaller, PUSHABLES ) )
            {
                g_TriggerTarget( 'func_pushable', pCaller );
            }
        }
    }

    bool g_Flag( CBaseEntity@ self, int flag )
    {
        if( self.pev.SpawnFlagBitSet( flag ) )
            return true;
        return false;
    }
    
    string g_GetTarget( CBaseEntity@ pCaller )
    {
        return string( pCaller.pev.target ).SubString( 24, string( pCaller.pev.target ).Length() );
    }

    void g_TriggerTarget( const string& in szClassname, CBaseEntity@ pCaller )
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szClassname ) ) !is null )
        {
            if( pEntity !is null )
            {
                if( pEntity.IsPlayer() || pEntity.IsMonster() )
                {
                    if( !pEntity.IsAlive() )
                    {
                        continue;
                    }
                }

                if( pCaller.Intersects( pEntity ) )
                {
                    if( g_GetDelay( pEntity ) > 0.0 )
                    {
                        continue;
                    }

                    g_Util.Trigger( g_GetTarget( pCaller ), pEntity, pCaller, USE_TOGGLE, 0.0f );
                    
                    if( g_GetDelay( pCaller ) > 0.0 )
                    {
                        g_GetDelay( pEntity, g_GetDelay( pCaller ) );
                        g_Scheduler.SetTimeout( "CWait", 0.1f, @pEntity );
                    }
                }
            }
        }
    }

    void CWait( CBaseEntity@ pEntity )
    {
        if( g_GetDelay( pEntity ) > 0.0 )
        {
            g_GetDelay( pEntity, g_GetDelay( pEntity ) -0.1f );
            g_Scheduler.SetTimeout( "CWait", 0.1f, @pEntity );
        }
    }

    float g_GetDelay( CBaseEntity@ pEntity, string value = '' )
    {
        if( value != '' )
            g_Util.SetCKV( pEntity, '$f_tmc_individual_delay', atof( value ) );
        return atof( g_Util.GetCKV( pEntity, '$f_tmc_individual_delay' ) );
    }
}