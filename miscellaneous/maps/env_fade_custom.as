#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_fade_custom
{
    void Register()
    {
        g_Util.CustomEntity( 'env_fade_custom' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_fade_custom' ) +
            g_ScriptInfo.Description( 'Expands env_fade entity' ) +
            g_ScriptInfo.Wiki( 'env_fade_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum env_fade_custom_spawnflags
    {
        REVERSE_FADING = 1,
        MODULATE_FILTERING = 2,
        STAY_FADE = 4
    }

    enum env_fade_custom_affected
    {
        ACTIVATOR_ONLY = 0,
        ALL_PLAYERS = 1,
        IN_RADIUS = 2,
        TOUCHING = 3,
        IN_RADIUS_AUTO = 4,
        TOUCHING_AUTO = 5
    }

    class env_fade_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle hActivator = null;
        private float m_ffadein, m_fholdtime, m_ffadeout;
        private int m_ifaderadius, m_iall_players, m_iuse_set;
        private bool m_bis_zone = true;
        private int SpawnFlags, SpawnFlagsOut;
        private USE_TYPE LastUseType;

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
                self.pev.effects |= EF_NODRAW;
                self.pev.movetype = MOVETYPE_NONE;
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
            self.pev.effects = EF_NODRAW;
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            LastUseType = useType;

            if( !IsLockedByMaster() )
            {
                hActivator = ( pActivator !is null ) ? @pActivator : @self;

                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBaseEntity@ ePlayer = cast<CBaseEntity@>( g_PlayerFuncs.FindPlayerByIndex( iPlayer ) );

                    if( ePlayer is null )
                        continue;

                    if( m_iall_players == ALL_PLAYERS
                    or m_iall_players == IN_RADIUS && ( self.pev.origin - ePlayer.pev.origin ).Length() <= m_ifaderadius
                    or m_iall_players == ACTIVATOR_ONLY && ePlayer is hActivator.GetEntity()
                    or m_iall_players == TOUCHING && self.Intersects( ePlayer ) )
                    {
                        CFade( ePlayer, useType );
                    }

                    if( m_iall_players == IN_RADIUS_AUTO )
                    {
                        if( ( self.pev.origin - ePlayer.pev.origin ).Length() <= m_ifaderadius )
                            CFadeSector( ePlayer );
                        else
                            SetValue( ePlayer );
                    }

                    if( m_iall_players == TOUCHING_AUTO )
                    {
                        if( self.Intersects( ePlayer ) )
                            CFadeSector( ePlayer );
                        else
                            SetValue( ePlayer );
                    }
                }
            }
        }
        
        void SetValue( CBaseEntity@ ePlayer )
        {
            if( atoi( g_Util.CKV( ePlayer, '$i_insidefadecustom_' + self.entindex() ) ) == 1 )
                g_Util.CKV( ePlayer, '$i_insidefadecustom_' + self.entindex(), 0 );
        }
        
        void CFade( CBaseEntity@ pPlayer, USE_TYPE useType = USE_TOGGLE )
        {
            if( useType == USE_OFF )
            {
                bFade( pPlayer, 0.0f, 0.0f, 0 );
                return;
            }
            else if( useType == USE_SET && ThinkyTime > 0 )
            {
                return;
            }
            SpawnFlagsOut = ( spawnflag( REVERSE_FADING ) ? self.pev.spawnflags - 1 : self.pev.spawnflags + 1 );

            bFade( pPlayer, m_ffadein, m_fholdtime, self.pev.spawnflags );

            if( m_ffadeout > 0.0 )
            {
                g_Scheduler.SetTimeout( this, "CFadeOut", m_ffadein + m_fholdtime - 0.5f, @pPlayer );
            }
            g_Scheduler.SetTimeout( this, "CFadeEnd", m_ffadein + m_fholdtime + m_ffadeout + 0.1f );
            ThinkyTime = m_ffadein + m_fholdtime + m_ffadeout;
        }
        
        void CFadeOut( CBaseEntity@ pPlayer )
        {
            bFade( pPlayer, m_ffadeout, 0.5f, SpawnFlagsOut );
        }

        void CFadeEnd()
        {
            g_Util.Trigger( self.pev.target, hActivator.GetEntity(), self, g_Util.itout( m_iUseType, LastUseType ), m_fDelay );
        }

        float ThinkyTime;
        void TriggerThink()
        {
            if( !IsLockedByMaster() )
            {
                if( m_bis_zone && m_iall_players == TOUCHING_AUTO || m_ifaderadius > 0 && m_iall_players == IN_RADIUS_AUTO )
                {
                    self.Use( self, self, USE_TOGGLE, 0.0f );
                }
            }
            if( ThinkyTime > 0 )
            {
                ThinkyTime -= 0.1f;
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
        
        void CFadeSector( CBaseEntity@ ePlayer )
        {
            if( atoi( g_Util.CKV( ePlayer, '$i_insidefadecustom_' + self.entindex() ) ) == 0 )
            {
                bFade( ePlayer, m_ffadein + 0.1f, 0.0f, ( spawnflag( MODULATE_FILTERING ) ) ? 2 + 1 : 0 + 1 );
                g_Scheduler.SetTimeout( this, "CFadeSectorInside", m_ffadein, @ePlayer );
                g_Util.CKV( ePlayer, '$i_insidefadecustom_' + self.entindex(), 1 );
            }
        }
        
        void CFadeSectorInside( CBaseEntity@ ePlayer )
        {
            if( atoi( g_Util.CKV( ePlayer, '$i_insidefadecustom_' + self.entindex() ) ) == 1 )
            {
                bFade( ePlayer, 0.01f, 1.5f, ( spawnflag( MODULATE_FILTERING ) ) ? 2 : 0 );
                g_Scheduler.SetTimeout( this, "CFadeSectorInside", 1.0f, @ePlayer );
            }
            else
            {
                g_Scheduler.SetTimeout( this, "CFadeSectorOut", 0.0f, @ePlayer );
            }
        }
        
        void CFadeSectorOut( CBaseEntity@ ePlayer )
        {
            bFade( ePlayer, m_ffadeout, 0.0f, ( spawnflag( MODULATE_FILTERING ) ) ? 2 : 0 );
        }

        void bFade( CBaseEntity@ ePlayer, float fadein, float fadehold, int iflags )
        {
            g_PlayerFuncs.ScreenFade( ePlayer, self.pev.rendercolor, fadein, fadehold, int( self.pev.renderamt ), iflags );
        }
    }
}
