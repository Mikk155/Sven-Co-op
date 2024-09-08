#include 'utils/as_utils'

namespace player_nightvision
{
    RGBA m_NightVision = RGBA( 0, 255, 0, 255 );
    int m_iLifeTime = 5;

    void MapInit()
    {
        g_Scheduler.SetInterval( "Think", 0.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    }

    void Think()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.pev.effects == EF_DIMLIGHT && pPlayer.IsAlive() && pPlayer.IsConnected() )
            {
                RGBA m_VecColorNew = m_NightVision;

                if( m_CustomKeyValue.HasKey( pPlayer, '$s_lp_nightvision' ) )
                {
                    string m_Vec4DString;

                    m_CustomKeyValue.GetValue( pPlayer, '$s_lp_nightvision', m_Vec4DString );

                    m_VecColorNew = ( m_Vec4DString.IsEmpty() ? m_NightVision : atorgba( m_Vec4DString  ) );
                }

                Vector vecSrc = pPlayer.EyePosition();
                NetworkMessage netMsg( MSG_ONE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict() );
                netMsg.WriteByte( TE_DLIGHT );
                netMsg.WriteCoord( vecSrc.x );
                netMsg.WriteCoord( vecSrc.y );
                netMsg.WriteCoord( vecSrc.z );
                netMsg.WriteByte( int( m_VecColorNew.a ) );
                netMsg.WriteByte( int( m_VecColorNew.r ) );
                netMsg.WriteByte( int( m_VecColorNew.g ) );
                netMsg.WriteByte( int( m_VecColorNew.b ) );
                netMsg.WriteByte( m_iLifeTime );
                netMsg.WriteByte( 1 );
                netMsg.End();
            }
        }
    }
}