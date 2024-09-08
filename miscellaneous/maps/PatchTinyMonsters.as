namespace tinymonsters
{
    CScheduledFunction@ g_Init = g_Scheduler.SetTimeout( @DaFuk, "patchme", 0.0f );

    // Stupid schedulers doesn't obey namespaces.
    Dafuk DaFuk;
    final class Dafuk
    {
        void patchme()
        {
            CBaseEntity@ pTriggers = null;

            while( ( pTriggers = g_EntityFuncs.FindEntityByClassname( @pTriggers, "trigger_*" ) ) !is null )
            {
                if( pTriggers.GetCustomKeyvalues().GetKeyvalue( "$i_tiny_monsters" ).GetString() != 0 )
                {
                    CBaseEntity@ pScript = Create( "trigger_script", g_vecZero, g_vecZero, true, pTriggers.edict() );

                    if( pScript !is null )
                    {
                        g_EntityFuncs.DispatchKeyValue( pScript.edict(), "m_iszScriptFunctionName", "PatchTinyMonsters" );
                        g_EntityFuncs.DispatchKeyValue( pScript.edict(), "m_flThinkDelta", "0.1" );
                        g_EntityFuncs.DispatchKeyValue( pScript.edict(), "m_iMode", "2" );
                        g_EntityFuncs.DispatchKeyValue( pScript.edict(), "spawnflags", "1" );
                        g_EntityFuncs.DispatchSpawn( pScript );
                    }
                }
            }
        }
    }

    void PatchTinyMonsters( CBaseEntity@ self )
    {
        CBaseEntity@ pTrigger = g_EntityFuncs.Instance( self.pev.owner );

        if( pTrigger is null || pTrigger.pev.solid == SOLID_NOT || pTrigger.GetCustomKeyvalues().GetKeyvalue( "$i_tiny_monsters" ).GetString() == 0 )
            return;

        array<CBaseEntity@>pEntities;

        g_EntityFuncs.EntitiesInBox( pEntities, pTriggers.pev.mins, pTriggers.pev.maxs, FL_MONSTER );

        for( uint i = 0; i < pEntities.length(); i++ )
        {
            if( pEntities[i] !is null && AllowedMonsters.find( string( pEntities[i].GetClassname() ) ) >= 0 )
            {
                pTrigger.Touch( pEntities[i] );
            }
        }
    }
}
