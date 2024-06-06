namespace UserMessages
{
    enum TargetFilter
    {
        NONE = 0,
        DEAD = 1,
        ALIVE = 2,
        OBSERVER = 4,
        ACTIVATOR = 8,
        CUSTOMKEYVALUE = 16,
        ALL_EXCEPT_ACTIVATOR = 32
    }

    array<int> NetworkClients( TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> iPlayers;

        for( int i = 0; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                if( m_ClientFilter == NONE )
                {
                    iPlayers.insertLast( i );
                    continue;
                }

                if( !pPlayer.IsAlive() && ( m_ClientFilter & TargetFilter::DEAD ) != 0
                || pPlayer.IsAlive() && ( m_ClientFilter & TargetFilter::ALIVE ) != 0
                || pPlayer.GetObserver().IsObserver() && ( m_ClientFilter & TargetFilter::OBSERVER ) != 0
                || pPlayer is pActivator && ( m_ClientFilter & TargetFilter::ACTIVATOR ) != 0
                || pPlayer !is pActivator && ( m_ClientFilter & TargetFilter::ALL_EXCEPT_ACTIVATOR ) != 0
                || pPlayer.GetCustomKeyvalues().GetKeyvalue( "$i_UserMessageTargetFilter" ).GetInteger() == 1 && ( m_ClientFilter & TargetFilter::CUSTOMKEYVALUE ) != 0
                ){ continue; }

                iPlayers.insertLast( i );
            }
        }
        return iPlayers;
    }

    array<int> ClientCommand( string m_iszCommand, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                    msg.WriteString( ';' + m_iszCommand + ';' );
                msg.End();
            }
        }
        return m;
    }

    array<int> PlayerSay( CBaseEntity@ pTarget, string m_szMessage, uint8 uiColor = 2, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE, NetworkMessages::NetworkMessageType(74), pPlayer.edict() );
                    msg.WriteByte( pTarget.entindex() );
                    msg.WriteByte( uiColor );
                    msg.WriteString( m_szMessage + '\n' );
                msg.End();
            }
        }
        return m;
    }

    array<int> ServerName( string m_iszHostName = String::EMPTY_STRING, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        if( m_iszHostName == String::EMPTY_STRING )
            m_iszHostName = g_EngineFuncs.CVarGetString( 'hostname' );

        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE, NetworkMessages::ServerName, pPlayer.edict() );
                    msg.WriteString( m_iszHostName );
                msg.End();
            }
        }
        return m;
    }

    // -TODO snippets para abajo
    array<int> Implosion( Vector VecStart = Vector( 0, 0, 0 ), uint8 radius = 255, uint8 count = 32, uint8 life = 30, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
                    msg.WriteByte( TE_IMPLOSION );
                    msg.WriteCoord( VecStart.x );
                    msg.WriteCoord( VecStart.y );
                    msg.WriteCoord( VecStart.z );
                    msg.WriteByte( radius );
                    msg.WriteByte( count );
                    msg.WriteByte( life );
                msg.End();
            }
        }
        return m;
    }

    array<int> DynamicLight( Vector VecStart = g_vecZero, RGBA color = RGBA( 255, 255, 255, 32 ), uint8 life = 255, uint8 noise = 255, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
                    msg.WriteByte( TE_DLIGHT );
                    msg.WriteCoord( VecStart.x );
                    msg.WriteCoord( VecStart.y );
                    msg.WriteCoord( VecStart.z );
                    msg.WriteByte( color.a );
                    msg.WriteByte( color.r );
                    msg.WriteByte( color.g );
                    msg.WriteByte( color.b );
                    msg.WriteByte( life );
                    msg.WriteByte( noise );
                msg.End();
            }
        }
        return m;
    }

    array<int> Explosion( Vector VecStart, int g_sModelIndex, uint8 flDamage, uint8 flFrameRate, uint8 iFlags = TE_EXPLFLAG_NONE, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
                    msg.WriteByte( TE_EXPLOSION );
                    msg.WriteCoord( VecStart.x );
                    msg.WriteCoord( VecStart.y );
                    msg.WriteCoord( VecStart.z );
                    msg.WriteShort( g_sModelIndex );
                    msg.WriteByte( flDamage );
                    msg.WriteByte( flFrameRate );
                    msg.WriteByte( iFlags );
                msg.End();
            }
        }
        return m;
    }

    array<int> Smoke( Vector VecStart, int g_sModelIndex, uint8 flDamage, uint8 flFrameRate, TargetFilter m_ClientFilter = TargetFilter::NONE, CBasePlayer@ pActivator = null )
    {
        array<int> m = NetworkClients( m_ClientFilter, pActivator );

        for( uint ui = 0; ui < m.length(); ui++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( m[ui] );

            if( pPlayer !is null && pPlayer.IsConnected() )
            {
                NetworkMessage msg( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
                    msg.WriteByte( TE_SMOKE );
                    msg.WriteCoord( VecStart.x );
                    msg.WriteCoord( VecStart.y );
                    msg.WriteCoord( VecStart.z );
                    msg.WriteShort( g_sModelIndex );
                    msg.WriteByte( flDamage );
                    msg.WriteByte( flFrameRate );
                msg.End();
            }
        }
        return m;
    }
}