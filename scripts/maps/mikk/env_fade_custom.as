#include "utils"
namespace env_fade_custom
{
    class env_fade_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle hActivator = null;
        private float m_ffadein, m_fholdtime, m_ffadeout;
        private int m_ifaderadius, m_iall_players, m_iuse_set;
        private bool m_bis_zone = true;
        private int SpawnFlags, SpawnFlagsOut;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_ffadein" )
            {
                m_ffadein = atof( szValue );
            }
            if( szKey == "m_fholdtime" )
            {
                m_fholdtime = atof( szValue );
            }
            if( szKey == "m_ffadeout" )
            {
                m_ffadeout = atof( szValue );
            }
            if( szKey == "m_ifaderadius" )
            {
                m_ifaderadius = atoi( szValue );
            }
            if( szKey == "m_iall_players" )
            {
                m_iall_players = atoi( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn()
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            if( !SetBoundaries() )
			{
				m_bis_zone = false;
				self.pev.solid = SOLID_TRIGGER;
				self.pev.effects |= EF_NODRAW;
				self.pev.movetype = MOVETYPE_NONE;
			}
            self.pev.nextthink = g_Engine.time + 0.1f;
            self.pev.effects = EF_NODRAW;
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !master() )
            {
                hActivator = ( pActivator !is null ) ? @pActivator : @self;

				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBaseEntity@ ePlayer = cast<CBaseEntity@>( g_PlayerFuncs.FindPlayerByIndex( iPlayer ) );

                    if( ePlayer is null )
                        continue;

                    if( m_iall_players == 1
                    or m_iall_players == 2 && ( self.pev.origin - ePlayer.pev.origin ).Length() <= m_ifaderadius
                    or m_iall_players == 4 && ( self.pev.origin - ePlayer.pev.origin ).Length() <= m_ifaderadius
                    or m_iall_players == 0 && ePlayer is hActivator.GetEntity()
                    or m_iall_players == 3 && self.Intersects( ePlayer ) 
                    or m_iall_players == 5 && self.Intersects( ePlayer ) )
                    {
                        CFade( ePlayer, useType );
                    }
                }
            }
        }
        
        void CFade( CBaseEntity@ pPlayer, USE_TYPE useType = USE_TOGGLE )
        {
            if( useType == USE_OFF )
            {
                g_PlayerFuncs.ScreenFade( pPlayer, self.pev.rendercolor, 0.0f, 0.0f, 0, 0 );
                return;
            }
            else if( useType == USE_SET && ThinkyTime > 0 )
            {
                return;
            }
            SpawnFlagsOut = ( spawnflag( 1 ) ? self.pev.spawnflags - 1 : self.pev.spawnflags + 1 );

            g_PlayerFuncs.ScreenFade( pPlayer, self.pev.rendercolor, m_ffadein, m_fholdtime, int( self.pev.renderamt ), self.pev.spawnflags );

            if( m_ffadeout > 0.0 )
            {
                g_Scheduler.SetTimeout( this, "CFadeOut", m_ffadein + m_fholdtime - 0.5f, @pPlayer );
            }
            g_Scheduler.SetTimeout( this, "CFadeEnd", m_ffadein + m_fholdtime + m_ffadeout + 0.1f );
            ThinkyTime = m_ffadein + m_fholdtime + m_ffadeout;
        }
        
        void CFadeOut( CBaseEntity@ pPlayer )
        {
            g_PlayerFuncs.ScreenFade( pPlayer, self.pev.rendercolor, m_ffadeout, 0.5f, int( self.pev.renderamt ), SpawnFlagsOut );
        }

        void CFadeEnd()
        {
            g_Util.Trigger( string( self.pev.target ), hActivator.GetEntity(), self, USE_TOGGLE, 0.0f );
        }

        float ThinkyTime;
        void TriggerThink()
        {
			if( !master() )
			{
				if( m_bis_zone && m_iall_players == 5 || m_ifaderadius > 0 && m_iall_players == 4 )
				{
					self.Use( null, self, USE_SET, 0.0f );
				}
			}
            if( ThinkyTime > 0 )
            {
                ThinkyTime -= 0.1f;
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }
	bool Register = g_Util.CustomEntity( 'env_fade_custom::env_fade_custom','env_fade_custom' );
}