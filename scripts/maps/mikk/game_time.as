#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace game_time
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_time::game_time", "game_time" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'game_time' ) +
            g_ScriptInfo.Description( 'Allows mapper to do use of the time.' ) +
            g_ScriptInfo.Wiki( 'game_time' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    DateTime g_ServerHostTime;

    enum game_time_spawnflags
    {
        GET_REAL_TIME = 1
    }
    
    string IntToPattern( const int v )
    {
        return
        (
            v == -12 ? 'a' :
            v == -11 ? 'b' :
            v == -10 ? 'c' :
            v == -9 ? 'd' :
            v == -8 ? 'e' :
            v == -7 ? 'f' :
            v == -6 ? 'g' :
            v == -5 ? 'h' :
            v == -4 ? 'i' :
            v == -3 ? 'j' :
            v == -2 ? 'k' :
            v == -1 ? 'l' :
            v == 0 ? 'm' :
            v == 1 ? 'n' :
            v == 2 ? 'o' :
            v == 3 ? 'p' :
            v == 4 ? 'q' :
            v == 5 ? 'r' :
            v == 6 ? 's' :
            v == 7 ? 't' :
            v == 8 ? 'u' :
            v == 9 ? 'v' :
            v == 10 ? 'w' :
            v == 11 ? 'x' :
            v == 12 ? 'y' :
            v == 13 ? 'z' : 'm'
        );
    }

    class game_time : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private array<string> pPatterns();
        private float m_fThinkTime = 1.0f, fMaxtime, fMinTime;
        private string m_iszTriggerPerSecond, m_iszTriggerPerMinute, m_iszTriggerPerHour, m_iszTriggerPerDay, m_iszPatternLight, m_iszPatternFile = 'mikk/config/game_time.mkconfig';
        private int m_iOneMinuteEquals = 60, iszPattern, OldPattern;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_fThinkTime" ) m_fThinkTime = atof( szValue );
            else if( szKey == "m_iOneMinuteEquals" ) m_iOneMinuteEquals = atoi( szValue );
            else if( szKey == "m_iszTriggerPerSecond" ) m_iszTriggerPerSecond = szValue;
            else if( szKey == "m_iszTriggerPerMinute" ) m_iszTriggerPerMinute = szValue;
            else if( szKey == "m_iszTriggerPerHour" ) m_iszTriggerPerHour = szValue;
            else if( szKey == "m_iszTriggerPerDay" ) m_iszTriggerPerDay = szValue;
            else if( szKey == "m_iszPatternLight" ) m_iszPatternLight = szValue;
            else if( szKey == "m_iszPatternFile" ) m_iszPatternFile = szValue;
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

            File@ pFile = g_FileSystem.OpenFile( 'scripts/maps/' + m_iszPatternFile, OpenFile::READ );

            if( pFile !is null && pFile.IsOpen() )
            {
                string line;

                g_Util.Debug( '[game_time] Opened "scripts/maps/' + m_iszPatternFile + '" Patterns have been set.' );

                while( !pFile.EOFReached() )
                {
                    pFile.ReadLine( line );

                    if( line.Length() < 1 or line[0] == '/' and line[1] == '/' )
                    {
                        continue;
                    }

                    pPatterns.insertLast( line );
                }

            }
            else
            {
                g_Util.Debug( '[game_time] Can NOT open "scripts/maps/' + m_iszPatternFile + '" No pattern set' );
            }

            BaseClass.Spawn();
        }

        void TriggerThink()
        {
            // g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, 'Time is: ' + g_GetTime( 'day' ) + 'D ' + g_GetTime( 'hour' ) + 'H '+ g_GetTime( 'minute' ) + 'M '+ g_GetTime( 'second' ) + 'S\n' );

            if( !IsLockedByMaster() )
            {
                g_IncreaseTimer( 'second' );

                if( g_GetTime( 'second' ) >= m_iOneMinuteEquals )
                {
                    if( !m_iszPatternLight.IsEmpty() )
                    {
                        g_ModifyRAD();
                    }

                    g_IncreaseTimer( 'minute', 'second' );
                }

                if( g_GetTime( 'minute' ) >= 60 )
                {
                    g_IncreaseTimer( 'hour', 'minute' );
                }

                if( g_GetTime( 'hour' ) >= 24 )
                {
                    g_IncreaseTimer( 'day', 'hour' );
                }
            }

            self.pev.nextthink = g_Engine.time + m_fThinkTime;
        }

        int g_GetTime( const string isztime )
        {
            return atoi( g_Util.GetCKV( self, '$i_' + isztime ) );
        }

        void g_IncreaseTimer( const string isztime, const string&in iszintime = '' )
        {
            if( iszintime != '' )
            {
                g_Util.SetCKV( self, '$i_' + iszintime, 0 );
            }

            g_Util.SetCKV( self, '$i_' + isztime, g_GetTime( isztime ) + 1 );

            g_Util.Trigger
            (
                ( isztime == 'second' ) ? m_iszTriggerPerSecond :
                ( isztime == 'minute' ) ? m_iszTriggerPerMinute :
                ( isztime == 'hour' ) ? m_iszTriggerPerHour :
                ( isztime == 'day' ) ? m_iszTriggerPerDay :
                '', self, self, USE_TOGGLE, 0.0f
            );
        }

        void UpdateOnRemove()
        {
            g_ModifyRAD( true );
            BaseClass.UpdateOnRemove();
        }

        void g_ModifyRAD( bool Restore = false )
        {
            if( Restore )
            {
                CBaseEntity@ pLight = null;

                while( ( @pLight = g_EntityFuncs.FindEntityByTargetname( pLight, m_iszPatternLight ) ) !is null )
                {
                    g_EntityFuncs.DispatchKeyValue( pLight.edict(), "pattern", 'm' );

                    g_Util.Debug();
                    pLight.Use( self, self, USE_TOGGLE, 0.0f );
                    g_Util.Debug( "[game_time] Killed entity, restored patterns to default. (m)" );
                    pLight.Use( self, self, USE_TOGGLE, 0.0f );
                    g_Util.Debug();
                }
                return;
            }

            string strHour = string( g_GetTime( 'hour' ) );
            if( strHour.Length() == 1 )
            {
                strHour = '0' + strHour;
            }

            string strMinute = string( g_GetTime( 'minute' ) );

            string CurrentTime = ( strHour.Length() == 1 ? '0' : '' ) + strHour + ':' + ( strMinute.Length() == 1 ? '0' : '' ) + strMinute;

            for (uint i = 0; i < pPatterns.length(); i++)
            {
                string strTimex = pPatterns[i].SubString( 0, CurrentTime.Length() );
                iszPattern = atoi( pPatterns[i].SubString( 6, pPatterns[i].Length() ) );

                if( CurrentTime == strTimex && iszPattern != OldPattern )
                {
                    OldPattern = iszPattern;

                    CBaseEntity@ pLight = null;

                    while( ( @pLight = g_EntityFuncs.FindEntityByTargetname( pLight, m_iszPatternLight ) ) !is null )
                    {
                        g_EntityFuncs.DispatchKeyValue( pLight.edict(), "pattern", IntToPattern( iszPattern ) );

                        g_Util.Debug();
                        pLight.Use( self, self, USE_TOGGLE, 0.0f );
                        g_Util.Debug( "[game_time] Light Pattern has been updated to "+ string( iszPattern ) + ' [' + IntToPattern( iszPattern ) + '] at the time of "' + CurrentTime + '"' );
                        pLight.Use( self, self, USE_TOGGLE, 0.0f );
                        g_Util.Debug();
                    }
                    break;
                }
            }
        }
    }
}