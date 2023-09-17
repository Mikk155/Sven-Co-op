MEntityFuncs m_EntityFuncs;

enum WhoAffected
{
    AP_ACTIVATOR_ONLY = 0,
    AP_ALL_PLAYERS = 1,
    AP_ALL_BUT_ACTIVATOR = 2,
    AP_ALL_ALIVE_PLAYER = 3,
    AP_ALL_DEAD_PLAYER = 4
}

final class MEntityFuncs
{
    void CustomEntity( string m_iszName )
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( m_iszName ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( m_iszName + '::' + m_iszName, m_iszName );
        }
    }

    void Trigger( string m_iszTarget, CBaseEntity@ pActivator = null, CBaseEntity@ pCaller = null, USE_TYPE UseTypex = USE_TOGGLE, float m_fDelay = 0.0f )
    {
        if( m_iszTarget.IsEmpty() )
        {
            return;
        }

        CBaseEntity@ pKillEnt = null;

        if( UseTypex == USE_KILL )
        {
            while( ( @pKillEnt = g_EntityFuncs.FindEntityByTargetname( pKillEnt, m_iszTarget ) ) !is null )
            {
                g_EntityFuncs.Remove( pKillEnt );
            }
            return;
        }
        g_Scheduler.SetTimeout( @this, "TriggerDelayed", m_fDelay, m_iszTarget, @pActivator, @pCaller, uttoi( UseTypex ) );
        if( m_fDelay > 0.0f ) m_Debug.Server( '[MEntityFuncs::Trigger] Delayed trigger to \'' + m_iszTarget + '\' for ' + m_fDelay + ' seconds.', DEBUG_LEVEL_ALMOST );
    }

    void TriggerDelayed( string m_iszTarget, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int UseTypex )
    {
        g_EntityFuncs.FireTargets( m_iszTarget, pActivator, pCaller, itout( UseTypex ), 0.0f );

        m_Debug.Server( '[MEntityFuncs::Trigger] Fired entity \'' + m_iszTarget + '\'', DEBUG_LEVEL_ALMOST );
        if( pActivator !is null )
            m_Debug.Server( '[MEntityFuncs::Trigger] !activator \'' + ( pActivator.IsPlayer() ? string( pActivator.pev.netname ) : pActivator.GetTargetname() != '' ? pActivator.GetTargetname() : string( pActivator.pev.classname ) ) + '\'', DEBUG_LEVEL_ALMOST );
        if( pCaller !is null )
            m_Debug.Server( '[MEntityFuncs::Trigger] !caller \'' + ( pCaller.IsPlayer() ? string( pCaller.pev.netname ) : pCaller.GetTargetname() != '' ? pCaller.GetTargetname() : string( pCaller.pev.classname ) ) + '\'', DEBUG_LEVEL_ALMOST );
        m_Debug.Server( '[MEntityFuncs::Trigger] USE_TYPE \'' + string( UseTypex ) + '\' \'USE_' + ( UseTypex == 0 ? 'OFF' : UseTypex == 1 ? 'ON' : UseTypex == 2 ? 'SET' : UseTypex == 4 ? 'KILL' : 'TOGGLE' ) + '\'', DEBUG_LEVEL_ALMOST );

    }

    CBaseEntity@ CreateEntity( dictionary@ g_Keyvalues )
    {
        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( string( g_Keyvalues[ 'classname' ] ), g_Keyvalues, true );
        if( pEntity !is null && string( g_Keyvalues[ 'origin' ] ) != '' )
        {
            g_EntityFuncs.SetOrigin( pEntity, atov( string( g_Keyvalues[ 'origin' ] ) ) );
        }
        return pEntity;
    }

    int GetNumberOfEntities( string szMatch, bool TargetName = false )
    {
        int NumberOfEntities = 0;

        CBaseEntity@ pEntity = null;

        if( TargetName )
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, szMatch ) ) !is null ){
                ++NumberOfEntities;
            }
        }
        else
        {
            while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szMatch ) ) !is null ){
                ++NumberOfEntities;
            }
        }
        m_Debug.Server( '[MEntityFuncs::GetNumberOfEntities] Found \'' + string( NumberOfEntities ) + '\' Entities', DEBUG_LEVEL_ALMOST );

        return NumberOfEntities;
    }

    void GetRandomEntity( string szMatch, CBaseEntity@ &out pEntity, bool TargetName = false )
    {
        array<CBaseEntity@>EntityArray;

        CBaseEntity@ FindEnt = null;

        if( TargetName )
        {
            while( ( @FindEnt = g_EntityFuncs.FindEntityByTargetname( FindEnt, szMatch ) ) !is null )
            {
                EntityArray.insertLast( @FindEnt );
            }
        }
        else
        {
            while( ( @FindEnt = g_EntityFuncs.FindEntityByClassname( FindEnt, string( szMatch ) ) ) !is null )
            {
                EntityArray.insertLast( @FindEnt );
            }
        }
        @pEntity = EntityArray[ Math.RandomLong( 0, EntityArray.length() -1 ) ];
    }

    bool WhoAffected( CBasePlayer@ pPlayer, int m_iszAffectedPlayer = AP_ACTIVATOR_ONLY, CBaseEntity@ pActivator = null )
    {
        if( m_iszAffectedPlayer == AP_ACTIVATOR_ONLY && pPlayer is pActivator
        or m_iszAffectedPlayer == AP_ALL_PLAYERS
        or m_iszAffectedPlayer == AP_ALL_BUT_ACTIVATOR && pPlayer !is pActivator
        or m_iszAffectedPlayer == AP_ALL_ALIVE_PLAYER && pPlayer.IsAlive()
        or m_iszAffectedPlayer == AP_ALL_DEAD_PLAYER && !pPlayer.IsAlive() )
        {
            if( pPlayer !is null )
            {
                return true;
            }
        }
        return false;
    }
}