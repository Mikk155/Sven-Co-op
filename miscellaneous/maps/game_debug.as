#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace game_debug
{
    void Register()
    {
        g_Util.Debugs = true;
        g_Util.CustomEntity( 'game_debug' );
        g_Scheduler.SetTimeout( "InitDebuggers", 1.0f );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'game_debug' ) +
            g_ScriptInfo.Description( 'Entity wich when fired, shows a debug message, also shows other entities being triggered' ) +
            g_ScriptInfo.Wiki( 'game_debug' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum game_debug_spawnflags
    {
        GENERATED_ENTITY = 1
    }

    class game_debug : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( spawnflag( GENERATED_ENTITY ) )
            {
                Debugger( self, pActivator, pCaller, useType );
            }
            else
            {
                string Message = g_Util.StringReplace( string_t( self.pev.message ),
                {
                    { "!frags", string( self.pev.frags ) },
                    { "!iuser1", string( self.pev.iuser1 ) },
                    { "!activator", ( pActivator is null ) ? 'null' : string( pActivator.pev.classname ) + " " + ( pActivator.IsPlayer() ? string( pActivator.pev.netname ) : string( pActivator.pev.targetname ) ) },
                    { "!caller", ( pCaller is null ) ? 'null' : string( pCaller.pev.classname ) + " name " + ( pCaller.IsPlayer() ? string( pCaller.pev.netname ) : string( pCaller.pev.targetname ) ) },
                    { "!netname", string( self.pev.netname ) },
                    { "!usetype", string( useType ) + ' [' + UseTypeIs( useType ) + ']' }
                } );

                g_Util.Debug( "[DEBUG] " + Message );
            }
        }
    }

    void Debugger( CBaseEntity@ self, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType )
    {
        string TriggerDebugger = 'Fired entity "' + self.GetTargetname() + '"\n';
        
        if( pCaller !is null )
        {
            TriggerDebugger = TriggerDebugger + ' Caller "' + pCaller.GetClassname() + '"\n';

            if( pCaller.GetTargetname() != '' )
            {
                TriggerDebugger = TriggerDebugger + ' name "' + pCaller.GetTargetname() + '"\n';
            }
        }

        if( pActivator !is null )
        {
            TriggerDebugger = TriggerDebugger + ' Activator "' + pActivator.GetClassname() + '"\n';

            if( pActivator.IsPlayer() )
            {
                TriggerDebugger = TriggerDebugger + ' name "' + string( pActivator.pev.netname ) + '"\n';
            }
            else if( pActivator.GetTargetname() != '' )
            {
                TriggerDebugger = TriggerDebugger + ' name "' + pActivator.GetTargetname() + '"\n';
            }
        }

        TriggerDebugger = TriggerDebugger + ' USE_TYPE "' + UseTypeIs( useType ) + '"\n';

        g_Util.Debug( "===\n[DEBUG] " + TriggerDebugger + '===\n' );
    }
    
    string UseTypeIs( USE_TYPE useType )
    {
        if( useType == USE_OFF )
        {
            return 'USE_OFF';
        }
        else if( useType == USE_ON )
        {
            return 'USE_ON';
        }
        else if( useType == USE_SET )
        {
            return 'USE_SET';
        }
        else if( useType == USE_KILL )
        {
            return 'USE_KILL';
        }
        return 'USE_TOGGLE';
    }
    
    void ondestroyfn( CBaseEntity@ pEntity )
    {
        Debugger( pEntity, null, null, USE_KILL );
    }

    void InitDebuggers()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "*" ) ) !is null )
        {
            if( pEntity !is null && pEntity.pev.targetname != '' && pEntity.pev.classname != 'game_debug' )
            {
                dictionary g_Dictionary;
                g_Dictionary [ "targetname" ] = string( pEntity.pev.targetname );
                g_Dictionary [ "spawnflags" ] = '1';
                g_Dictionary [ "ondestroyfn" ] = 'game_debug::ondestroyfn';
                g_EntityFuncs.CreateEntity( "game_debug", g_Dictionary );
            }
        }
    }
}
