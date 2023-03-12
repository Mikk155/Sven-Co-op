#include "utils"
namespace trigger_multiple
{
    CScheduledFunction@ g_IterateAllOccupants = g_Scheduler.SetTimeout( "FindTriggerMultiples", 0.0f );

    enum spawnflags
    {
        MONSTERS = 1,
        NOCLIENTS = 2,
        PUSHABLES = 4,
        IterateAllOccupants = 64
    };

    void FindTriggerMultiples()
    {
        CBaseEntity@ pTriggers = null;

        while( ( @pTriggers = g_EntityFuncs.FindEntityByClassname( pTriggers, "trigger_multiple" ) ) !is null )
        {
            if( pTriggers is null )
            {
                continue;
            }

            if( pTriggers.pev.SpawnFlagBitSet( IterateAllOccupants ) )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName","trigger_multiple::TriggerForAllOccupants" },
                    { "m_iMode", "1" },
                    { "targetname", "iterateoccupants_" + string( pTriggers.pev.target ) }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

                g_EntityFuncs.DispatchKeyValue( pTriggers.edict(), "target", "iterateoccupants_" + string( pTriggers.pev.target ) );
            }
        }

        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#trigger_multiple\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow trigger_multiple entity to fire its target for every one inside its volume.\n"
        );
    }

    void TriggerForAllOccupants( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pCaller is null )
            return;

        if( pCaller.pev.SpawnFlagBitSet( MONSTERS ) )
            g_TriggerMultiple.Trigger( 'monster*', pCaller );

        if( !pCaller.pev.SpawnFlagBitSet( NOCLIENTS ) )
            g_TriggerMultiple.Trigger( 'player', pCaller );

        if( pCaller.pev.SpawnFlagBitSet( PUSHABLES ) )
            g_TriggerMultiple.Trigger( 'func_pushable', pCaller );
    }
}
// End of namespace

CTriggerMultiple g_TriggerMultiple;

final class CTriggerMultiple
{
    void Trigger( const string& in szClassname, CBaseEntity@ pCaller )
    {
        int iLenght = string( pCaller.pev.target ).Length();
        string target = string( pCaller.pev.target ).SubString( 17, iLenght );

        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szClassname ) ) !is null )
        {
            if( pEntity is null
            || pEntity.IsPlayer() && !pEntity.IsAlive()
            || pEntity.IsMonster() && !pEntity.IsAlive() )
            {
                continue;
            }

            if( pCaller.Intersects( pEntity ) )
            {
                g_EntityFuncs.FireTargets( target, pEntity, pCaller, USE_TOGGLE, 0.0 );
            }
        }
    }
}
// End of final class