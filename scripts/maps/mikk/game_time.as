#include "utils"

bool game_time_register = g_Util.CustomEntity( 'game_time::game_time','game_time' );

namespace game_time
{
    DateTime g_ServerHostTime;

    enum game_time_spawnflags
    {
        GET_REAL_TIME = 1
    }

    class game_time : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private float m_fThinkTime = 1.0f;

        private string
        m_iszTriggerPerSecond,
        m_iszTriggerPerMinute,
        m_iszTriggerPerHour,
        m_iszTriggerPerDay,
        m_iszPatternLight;
        
        private int m_iOneSecondIsEqualTo = 60;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_fThinkTime" ) m_fThinkTime = atof( szValue );
            else if( szKey == "m_iOneSecondIsEqualTo" ) m_iOneSecondIsEqualTo = atoi( szValue );
            else if( szKey == "m_iszTriggerPerSecond" ) m_iszTriggerPerSecond = szValue;
            else if( szKey == "m_iszTriggerPerMinute" ) m_iszTriggerPerMinute = szValue;
            else if( szKey == "m_iszTriggerPerHour" ) m_iszTriggerPerHour = szValue;
            else if( szKey == "m_iszTriggerPerDay" ) m_iszTriggerPerDay = szValue;
            else if( szKey == "m_iszPatternLight" ) m_iszPatternLight = szValue;
            return true;
        }

        void Spawn()
        {
            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 1.0f;

            if( spawnflag( GET_REAL_TIME ) )
            {
                g_Util.SetCKV( self, '$i_second', int( g_ServerHostTime.GetSeconds() ) );
                g_Util.SetCKV( self, '$i_minute', int( g_ServerHostTime.GetMinutes() ) );
                g_Util.SetCKV( self, '$i_hour', int( g_ServerHostTime.GetHour() ) );
            }

            BaseClass.Spawn();
        }

        void TriggerThink()
        {
            if( !IsLockedByMaster() )
            {
                g_IncreaseTimer( 'second' );

                if( g_GetTimer( 'second' ) >= m_iOneSecondIsEqualTo )
                {
                    g_IncreaseTimer( 'minute', 'second' );
                }

                if( g_GetTimer( 'minute' ) >= 60 )
                {
                    g_IncreaseTimer( 'hour', 'minute' );
                }

                if( g_GetTimer( 'hour' ) >= 24 )
                {
                    g_IncreaseTimer( 'day', 'hour' );
                }

                if( !m_iszPatternLight.IsEmpty() )
                {
                    // -TODO CReflection stuff so people do their own logics
                    g_ModifyRad();
                }
            }
            
            // g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, 'Time is: ' + g_GetTimer( 'day' ) + 'D ' + g_GetTimer( 'hour' ) + 'H '+ g_GetTimer( 'minute' ) + 'M '+ g_GetTimer( 'second' ) + 'S\n' );
            self.pev.nextthink = g_Engine.time + m_fThinkTime;
        }

        int g_GetTimer( const string isztime )
        {
            return atoi( g_Util.GetCKV( self, '$i_' + isztime ) );
        }

        void g_IncreaseTimer( const string isztime, const string&in iszintime = '' )
        {
            if( iszintime != '' )
            {
                g_Util.SetCKV( self, '$i_' + iszintime, 0 );
            }

            g_Util.SetCKV( self, '$i_' + isztime, g_GetTimer( isztime ) + 1 );

            g_Util.Trigger
            (
                ( isztime == 'second' ) ? m_iszTriggerPerSecond :
                ( isztime == 'minute' ) ? m_iszTriggerPerMinute :
                ( isztime == 'hour' ) ? m_iszTriggerPerHour :
                ( isztime == 'day' ) ? m_iszTriggerPerDay :
                '', self, self, USE_TOGGLE, 0.0f
            );
        }

        void g_ModifyRad()
        {
            if( Pattern() != '' )
            {
                // g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Pattern is " + Pattern() + "\n" );

                if( m_iszPatternLight == "!world" )
                {
                    g_EngineFuncs.LightStyle( 0, Pattern() );
                }
                else
                {
                    CBaseEntity@ pLight = null;

                    while( ( @pLight = g_EntityFuncs.FindEntityByTargetname( pLight, m_iszPatternLight ) ) !is null )
                    {
                        g_EntityFuncs.DispatchKeyValue( pLight.edict(), "pattern", Pattern() );

                        g_Util.Debug();
                        pLight.Use( self, self, USE_TOGGLE, 0.0f );
                        g_Util.Debug( "[game_time] Light Pattern has been updated to "+ Pattern() );
                        pLight.Use( self, self, USE_TOGGLE, 0.0f );
                        g_Util.Debug();
                    }
                }
            }
        }

        // Probably is completelly wrong, i've tried my best :)
        string Pattern()
        {
            int m = g_GetTimer( 'minute' );
            int h = g_GetTimer( 'hour' );
            string p;
            
            if( h == 5 && m == 10 || h == 22 && m == 50 ) return 'b'; else
            if( h == 5 && m == 20 || h == 22 && m == 10 ) return 'c'; else
            if( h == 5 && m == 30 || h == 21 && m == 50 ) return 'd'; else
            if( h == 5 && m == 40 || h == 21 && m == 10 ) return 'e'; else
            if( h == 5 && m == 50 || h == 20 && m == 50 ) return 'f'; else
            if( h == 6 && m == 10 || h == 20 && m == 10 ) return 'g'; else
            if( h == 6 && m == 20 || h == 19 && m == 50 ) return 'h'; else
            if( h == 6 && m == 30 || h == 19 && m == 10 ) return 'i'; else
            if( h == 6 && m == 40 || h == 18 && m == 50 ) return 'j'; else
            if( h == 6 && m == 50 || h == 18 && m == 20 ) return 'k'; else
            if( h == 7 && m == 10 || h == 17 && m == 50 ) return 'l'; else
            if( h == 7 && m == 50 || h == 17 && m == 30 ) return 'm'; else
            if( h == 8 && m == 10 || h == 17 && m == 10 ) return 'n'; else
            if( h == 8 && m == 30 || h == 16 && m == 50 ) return 'o'; else
            if( h == 8 && m == 50 || h == 16 && m == 30 ) return 'p'; else
            if( h == 9 && m == 10 || h == 16 && m == 10 ) return 'q'; else
            if( h == 9 && m == 30 || h == 15 && m == 50 ) return 'r'; else
            if( h == 9 && m == 50 || h == 15 && m == 30 ) return 's'; else
            if( h == 10 && m == 10 || h == 15 && m == 10 ) return 't'; else
            if( h == 10 && m == 30 || h == 14 && m == 50 ) return 'u'; else
            if( h == 10 && m == 50 || h == 14 && m == 30 ) return 'v'; else
            if( h == 11 && m == 10 || h == 14 && m == 10 ) return 'w'; else
            if( h == 11 && m == 30 || h == 13 && m == 50 ) return 'x'; else
            if( h == 11 && m == 50 || h == 13 && m == 40 ) return 'y'; else
            if( h == 12 && m == 10 ) return 'z'; else
            if( h >= 23 || h <= 5 && m < 10 ) return 'a';
            return '';
        }
    }
}