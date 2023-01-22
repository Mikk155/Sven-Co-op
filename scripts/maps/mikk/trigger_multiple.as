namespace trigger_multiple
{
    // Entities supported for flag 8 (Everything else) if flag 64 (Iterate all occupants) is enabled as well
    // if you want to use this feature then register in map init the next function.
    
    // g_TriggerMultiple.LoadConfigFile( "full path to your file.txt" );

    // this text file will define wich entities can make trigger_multiple fire its target.

    array<string> EverythingElse;

    CScheduledFunction@ g_IterateAllOccupants = g_Scheduler.SetTimeout( "FindTriggerMultiples", 0.0f );

    enum trigger_multiple_flags
    {
        MONSTERS = 1,
        NOCLIENTS = 2,
        PUSHABLES = 4,
        EVERTHINGELSE = 8,
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
            "Script: trigger_multiple\n"
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

        if( pCaller.pev.SpawnFlagBitSet( EVERTHINGELSE ) )
            for( uint ui = 0; ui < EverythingElse.length(); ++ui )
                g_TriggerMultiple.Trigger( EverythingElse[ui], pCaller );
    }
}
// End namespace

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

    void LoadConfigFile( const string& in szPath = 'scripts/maps/mikk/trigger_multiple.txt' )
    {
        File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Util.DebugMessage( "WARNING: Failed to open " + szPath + " no config initialized for spawnflag 8 (everything else)" );
            return;
        }

        while( !pFile.EOFReached() )
        {
            string line;
            pFile.ReadLine( line );
            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' ) { continue; }
            trigger_multiple::EverythingElse.insertLast( line );
        }
        pFile.Close();
    }
}
// End of final class