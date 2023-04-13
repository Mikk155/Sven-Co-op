#include "utils"

bool game_debug_register = g_Util.CustomEntity( 'game_debug::game_debug','game_debug' );

namespace game_debug
{
    enum game_debug_spawnflags
    {
        IsFromScriptNotMap = 1
    }

    class game_debug : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( spawnflag( IsFromScriptNotMap ) )
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
                    { "!usetype", string( useType ) }
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

            if( pActivator.GetTargetname() != '' )
            {
                TriggerDebugger = TriggerDebugger + ' name "' + pActivator.GetTargetname() + '"\n';
            }
        }

        string UseTypex = 'USE_TOGGLE';

        if( useType == USE_OFF )
        {
            UseTypex = 'USE_OFF';
        }
        else if( useType == USE_ON )
        {
            UseTypex = 'USE_ON';
        }
        else if( useType == USE_SET )
        {
            UseTypex = 'USE_SET';
        }
        else if( useType == USE_KILL )
        {
            UseTypex = 'USE_KILL';
        }

        TriggerDebugger = TriggerDebugger + ' USE_TYPE "' + UseTypex + '"\n';

        g_Util.Debug( "===\n[DEBUG] " + TriggerDebugger + '===\n' );
    }
    
    void ondestroyfn( CBaseEntity@ pEntity )
    {
        Debugger( pEntity, null, null, USE_KILL );
    }

    CScheduledFunction@ g_Debugger = g_Scheduler.SetTimeout( "InitDebuggers", 1.0f );

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