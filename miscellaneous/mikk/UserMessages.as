//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

class MKUserMessages
{
    MKTempEnts Entity;

    void ServerName( string m_iszHostName = String::EMPTY_STRING, CBaseEntity@ pTargetPlayer = null )
    {
        if( m_iszHostName == String::EMPTY_STRING )
        {
            m_iszHostName = g_EngineFuncs.CVarGetString( 'hostname' );
        }

        if( pTargetPlayer is null )
        {
            NetworkMessage m( MSG_ALL, NetworkMessages::ServerName );
                m.WriteString( m_iszHostName );
            m.End();
        }
        else
        {
            NetworkMessage m( MSG_ONE, NetworkMessages::ServerName, pTargetPlayer.edict() );
                m.WriteString( m_iszHostName );
            m.End();
        }
    }
}

class MKTempEnts
{
    void Implosion( Vector VecStart = Vector( 0, 0, 0 ), uint8 radius = 255, uint8 count = 32, uint8 life = 30, CBaseEntity@ pTargetPlayer = null )
    {
        if( pTargetPlayer is null )
        {
            NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
                m.WriteByte( TE_IMPLOSION );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteByte( radius );
                m.WriteByte( count );
                m.WriteByte( life );
            m.End();
        }
        else
        {
            NetworkMessage m( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pTargetPlayer.edict() );
                m.WriteByte( TE_IMPLOSION );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteByte( radius );
                m.WriteByte( count );
                m.WriteByte( life );
            m.End();
        }
    }

    void DynamicLight( Vector VecStart = g_vecZero, RGBA color = RGBA( 255, 255, 255, 32 ), uint8 life = 255, uint8 noise = 255, CBaseEntity@ pTargetPlayer = null )
    {
        if( pTargetPlayer is null )
        {
            NetworkMessage m( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
                m.WriteByte( TE_DLIGHT );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteByte( color.a );
                m.WriteByte( color.r );
                m.WriteByte( color.g );
                m.WriteByte( color.b );
                m.WriteByte( life );
                m.WriteByte( noise );
            m.End();
        }
        else
        {
            NetworkMessage m( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pTargetPlayer.edict() );
                m.WriteByte( TE_DLIGHT );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteByte( color.a );
                m.WriteByte( color.r );
                m.WriteByte( color.g );
                m.WriteByte( color.b );
                m.WriteByte( life );
                m.WriteByte( noise );
            m.End();
        }
    }

    void Explosion( Vector VecStart, int g_sModelIndex, uint8 flDamage, uint8 flFrameRate, uint8 iFlags = TE_EXPLFLAG_NONE, CBaseEntity@ pTargetPlayer = null )
    {
        if( pTargetPlayer is null )
        {
            NetworkMessage m( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, null );
                m.WriteByte( TE_EXPLOSION );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteShort( g_sModelIndex );
                m.WriteByte( flDamage );
                m.WriteByte( flFrameRate );
                m.WriteByte( iFlags );
            m.End();
        }
        else
        {
            NetworkMessage m( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pTargetPlayer.edict() );
                m.WriteByte( TE_EXPLOSION );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteShort( g_sModelIndex );
                m.WriteByte( flDamage );
                m.WriteByte( flFrameRate );
                m.WriteByte( iFlags );
            m.End();
        }
    }

    void Smoke( Vector VecStart, int g_sModelIndex, uint8 flDamage, uint8 flFrameRate, CBaseEntity@ pTargetPlayer = null )
    {
        if( pTargetPlayer is null )
        {
            NetworkMessage m( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, null );
                m.WriteByte( TE_SMOKE );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteShort( g_sModelIndex );
                m.WriteByte( flDamage );
                m.WriteByte( flFrameRate );
            m.End();
        }
        else
        {
            NetworkMessage m( MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pTargetPlayer.edict() );
                m.WriteByte( TE_SMOKE );
                m.WriteCoord( VecStart.x );
                m.WriteCoord( VecStart.y );
                m.WriteCoord( VecStart.z );
                m.WriteShort( g_sModelIndex );
                m.WriteByte( flDamage );
                m.WriteByte( flFrameRate );
            m.End();
        }
    }
}