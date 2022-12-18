/*
DOWNLOAD:

scripts/maps/mikk/trigger_multiple.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/trigger_multiple"

*/

#include "utils"

namespace trigger_multiple
{
    CScheduledFunction@ g_MultiThreaded = g_Scheduler.SetTimeout( "FindTriggerMultiples", 0.0f );

    enum trigger_multiple_flags{ MULTI_THREADED = 64 };

    void FindTriggerMultiples()
    {
        CBaseEntity@ pTriggers = null;

        while( ( @pTriggers = g_EntityFuncs.FindEntityByClassname( pTriggers, "trigger_multiple" ) ) !is null )
        {
            if( pTriggers is null ) { continue; }

            if( pTriggers.pev.SpawnFlagBitSet( MULTI_THREADED ) )
            {
                dictionary g_keyvalues =
                {
                    { "m_iszScriptFunctionName","trigger_multiple::TriggerMultiThreaded" },
                    { "m_iMode", "1" },
                    { "targetname", "multithreaded_" + string( pTriggers.pev.target ) }
                };
                g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

                g_EntityFuncs.DispatchKeyValue( pTriggers.edict(), "target", "multithreaded_" + string( pTriggers.pev.target ) );
            }
        }
    }

    void TriggerMultiThreaded( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pCaller is null )
        {
            return;
        }

        int iLenght = string( pCaller.pev.target ).Length();
        string target = string( pCaller.pev.target ).SubString( 14, iLenght );

        CBaseEntity@ pEntity = null;

        while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "monster_*" ) ) !is null)
        {
            if( pEntity is null && !pEntity.IsAlive() )
                continue;

            if( pCaller.Intersects( pEntity ) )
            {
                UTILS::Trigger( target, pEntity, pCaller, useType, flValue );
            }
        }

        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || !pPlayer.IsAlive() )
                continue;

            if( pCaller.Intersects( pPlayer ) )
            {
                UTILS::Trigger( target, pPlayer, pCaller, useType, flValue );
            }
        }
    }
}// end namespace