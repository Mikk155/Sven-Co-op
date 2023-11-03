enum CMKEntityFuncs_enum
{
    CMKEntityFuncs_ACTIVATOR_ONLY = 0,
    CMKEntityFuncs_ALL_PLAYERS,
    CMKEntityFuncs_ALL_BUT_ACTIVATOR,
    CMKEntityFuncs_ALL_ALIVE_PLAYER,
    CMKEntityFuncs_ALL_DEAD_PLAYER,
}

class CMKEntityFuncs
{
    string CustomKeyValue( CBaseEntity@ pEntity, const string&in m_iszKey, const string&in m_iszValue = String::EMPTY_STRING )
    {
        if( pEntity is null )
        {
            return String::INVALID_INDEX;
        }

        if( m_iszValue != String::EMPTY_STRING )
        {
            g_EntityFuncs.DispatchKeyValue( pEntity.edict(), m_iszKey, m_iszValue );
        }
        

        return pEntity.GetCustomKeyvalues().GetKeyvalue( m_iszKey ).GetString();
    }

    bool WhoAffected( CBasePlayer@ pPlayer, CMKEntityFuncs_enum m_eAffectType = CMKEntityFuncs_ACTIVATOR_ONLY, CBaseEntity@ pActivator = null )
    {
        if( pPlayer is null )
        {
            return false;
        }

        switch( m_eAffectType )
        {
            case CMKEntityFuncs_ACTIVATOR_ONLY:
            {
                return ( pPlayer is pActivator );
            }
            case CMKEntityFuncs_ALL_PLAYERS:
            {
                return true;
            }
            case CMKEntityFuncs_ALL_BUT_ACTIVATOR:
            {
                return ( pPlayer !is pActivator );
            }
            case CMKEntityFuncs_ALL_ALIVE_PLAYER:
            {
                return ( pPlayer.IsAlive() );
            }
            case CMKEntityFuncs_ALL_DEAD_PLAYER:
            {
                return ( !pPlayer.IsAlive() );
            }
        }
        return false;
    }

    void DamagePerSecond( EHandle hVictim, EHandle hInflictor, int itimes, int idamage, int dmgbits )
    {
        if( hVictim.IsValid() && hInflictor.IsValid() )
        {
            CBaseEntity@ pInflictor = hInflictor.GetEntity();
            CBaseMonster@ pVictim = cast<CBaseMonster@>( hVictim.GetEntity() );

            if( pInflictor !is null && pVictim !is null && pVictim.IsAlive() )
            {
                pVictim.TakeDamage( pInflictor.pev, pInflictor.pev, idamage, DMG( dmgbits ) );

                itimes--;

                if( itimes > 0 )
                {
                    g_Scheduler.SetTimeout( @this, 'DamagePerSecond', 1.0f, hVictim, hInflictor, itimes, idamage, dmgbits );
                }
            }
        }
    }

    bool CustomEntity( string &in m_iszName, bool &in bPrecache = false )
    {
        if( !g_CustomEntityFuncs.IsCustomEntity( m_iszName ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( m_iszName + '::' + m_iszName, m_iszName );
        }

        if( bPrecache )
        {
            g_Game.PrecacheOther( m_iszName );
        }

        return g_CustomEntityFuncs.IsCustomEntity( m_iszName );
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
    }

    void TriggerDelayed( string m_iszTarget, CBaseEntity@ pActivator, CBaseEntity@ pCaller, int UseTypex )
    {
        g_EntityFuncs.FireTargets( m_iszTarget, pActivator, pCaller, itout( UseTypex ), 0.0f );
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
}