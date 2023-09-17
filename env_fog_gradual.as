#include 'as_register'

namespace env_fog_gradual
{
    void MapInit()
    {
        m_EntityFuncs.CustomEntity( 'env_fog_gradual' );

        m_ScriptInfo.SetScriptInfo
        (
            {
                { 'script', 'env_fog_gradual' },
                { 'description', 'env_fog gradual' }
            }
        );
    }

    void Remove()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'config_map_cvars' ) ) !is null )
        {
            g_EntityFuncs.DispatchKeyValue( pEntity.edict(), 'm_iAffectedPlayer', 1 );
            pEntity.Use( null, null, USE_OFF, 0.0f );
        }

        g_CustomEntityFuncs.UnRegisterCustomEntity( 'env_fog_gradual' );
    }

    class env_fog_gradual : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private array<int> iPlayers;
        private RGBA m_VecColorOFF = RGBA( 0, 0, 0, 0 );
        private RGBA m_VecColorON = RGBA( 255, 255, 255, 0 );
        private int m_iStartOFF, m_iStartON;
        private int m_iEndOFF, m_iEndON;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "m_VecColorOFF" )
            {
                m_VecColorOFF = atorgba( szValue );
            }
            else if( szKey == "m_VecColorON" )
            {
                m_VecColorON = atorgba( szValue );
            }
            else if( szKey == "m_iStartOFF" )
            {
                m_iStartOFF = atoi( szValue );
            }
            else if( szKey == "m_iStartON" )
            {
                m_iStartON = atoi( szValue );
            }
            else if( szKey == "m_iEndOFF" )
            {
                m_iEndOFF = atoi( szValue );
            }
            else if( szKey == "m_iEndON" )
            {
                m_iEndON = atoi( szValue );
            }
            return BaseClass.KeyValue( szKey, szValue );
        }

        void Spawn()
        {
            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float delay )
        {
            for( int i = 1; i <= g_Engine.maxClients; i++ ) 
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                if( pPlayer !is null && m_EntityFuncs.WhoAffected( pPlayer, m_iAffectedPlayer, pActivator ) )
                {
                    Alternate( pPlayer.entindex(), UseType );
                }
            }
        }

        void Alternate( int &in eidx, USE_TYPE &in UseType )
        {
            if( UseType == USE_ON )
            {
                if( iPlayers.find( eidx ) < 0 )
                    iPlayers.insertLast( eidx );
            }
            else if( UseType == USE_OFF )
            {
                if( iPlayers.find( eidx ) >= 0 )
                    iPlayers.removeAt( iPlayers.find( eidx ) );
                m_Effect.fog( g_PlayerFuncs.FindPlayerByIndex( eidx ), 0 );
            }
            else
            {
                if( iPlayers.find( eidx ) < 0 )
                {
                    iPlayers.insertLast( eidx );
                }
                else
                {
                    iPlayers.removeAt( iPlayers.find( eidx ) );
                    m_Effect.fog( g_PlayerFuncs.FindPlayerByIndex( eidx ), 0 );
                }
            }
        }

        void Think()
        {
            if( iPlayers.length() < 1 )
            {
                self.pev.nextthink = g_Engine.time + 0.1f;
                return;
            }

            for( uint eidx = 0; eidx < iPlayers.length(); eidx++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayers[eidx] );

                if( pPlayer is null && iPlayers.find( iPlayers[eidx] ) >= 0 )
                {
                    iPlayers.removeAt( iPlayers.find( iPlayers[eidx] ) );
                    continue;
                }

                m_Debug.Server( '=================================' );
                m_Debug.Server( 'Found index ' + iPlayers[eidx] );

                int i=0;

                if( !m_CustomKeyValue.HasKey( pPlayer, '$v_config_fog_color' ) )
                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_color', Vector( m_VecColorOFF.r, m_VecColorOFF.g, m_VecColorOFF.b ).ToString() );

                string m_VecColor;
                m_CustomKeyValue.GetValue( pPlayer, '$v_config_fog_color', m_VecColor );

                RGBA New = atorgba( m_VecColor );

                if( New.r != m_VecColorON.r || New.g != m_VecColorON.g || New.b != m_VecColorON.b )
                {
                    if( New.r > m_VecColorON.r ) New.r--; else if( New.r < m_VecColorON.r ) New.r++; else i++;

                    if( New.g > m_VecColorON.g ) New.g--; else if( New.g < m_VecColorON.g ) New.g++; else i++;

                    if( New.b > m_VecColorON.b ) New.b--; else if( New.b < m_VecColorON.b ) New.b++; else i++;

                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_color', Vector( New.r, New.g, New.b ).ToString() );
                    m_Debug.Server( 'rendermode ' + Vector( New.r, New.g, New.b ).ToString() );
                }

                if( !m_CustomKeyValue.HasKey( pPlayer, '$v_config_fog_start' ) )
                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_start', m_iStartOFF );

                int m_iStart;
                m_CustomKeyValue.GetValue( pPlayer, '$v_config_fog_start', m_iStart );

                if( m_iStart != m_iStartON )
                {
                    if( m_iStart > m_iStartON ) m_iStart--; else if( m_iStart < m_iStartON ) m_iStart++; else i++;

                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_start',m_iStart );
                    m_Debug.Server( 'startdis ' + m_iStart );
                }

                if( !m_CustomKeyValue.HasKey( pPlayer, '$v_config_fog_end' ) )
                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_end', m_iEndOFF );

                int m_iEnd;
                m_CustomKeyValue.GetValue( pPlayer, '$v_config_fog_end', m_iEnd );

                if( m_iEnd != m_iEndON )
                {
                    if( m_iEnd > m_iEndON ) m_iEnd--; else if( m_iEnd < m_iEndON ) m_iEnd++; else i++;

                    m_CustomKeyValue.SetValue( pPlayer, '$v_config_fog_end',m_iEnd );
                    m_Debug.Server( 'enddis ' + m_iEnd );
                }

                if( i != 5 )
                {
                    m_Debug.Server( 'Repeat; 1 ' );
                    m_Effect.fog( pPlayer, 1, New.r, New.g, New.b, m_iStart, m_iEnd );
                }
            }

            self.pev.nextthink = ( self.pev.frags > 0.0f ? self.pev.frags : g_Engine.time + 0.00001f );
        }
    }
}