#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_percent
{
    void Register()
    {
        g_Util.CustomEntity( 'trigger_percent' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_percent' ) +
            g_ScriptInfo.Description( 'Trigger its target if specified ammount of players fired the entity first.' ) +
            g_ScriptInfo.Wiki( 'trigger_percent' ) +
            g_ScriptInfo.Author( 'CubeMath' ) +
            g_ScriptInfo.GetGithub( 'CubeMath' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum trigger_percent_spawnflags
    {
        REUSABLE = 1
    }

    class trigger_percent : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private float fPlayersTriggered;
        private int m_iPercentage = 66;
        private string m_iszTriggerOnPercent, m_iszTriggerOnAction;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_iPercentage" )
            {
                m_iPercentage = atoi( szValue );
            }
            else if( szKey == "m_iszTriggerOnAction" )
            {
                m_iszTriggerOnAction = szValue;
            }
            else if( szKey == "m_iszTriggerOnPercent" )
            {
                m_iszTriggerOnPercent = szValue;
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
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            m_UTLatest = useType;

            if( pActivator !is null && pActivator.IsPlayer() && g_Util.CKV( pActivator, '$i_triggerpercent_' + self.entindex() ).IsEmpty() && !IsLockedByMaster() )
            {
                ++fPlayersTriggered;
                g_Util.CKV( pActivator, '$i_triggerpercent_' + self.entindex(), 1 );
                g_Util.Trigger( m_iszTriggerOnAction, pActivator, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
            }
        }

        void TriggerThink() 
        {
            int iPlayers = g_PlayerFuncs.GetNumPlayers();

            if( iPlayers > 0 )
            {
                float CurrentPercentage = (fPlayersTriggered/iPlayers) *100;
                
                if( CurrentPercentage >= m_iPercentage )
                {
                    g_Util.Trigger( m_iszTriggerOnPercent, self, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
                    
                    if( spawnflag( REUSABLE ) )
                    {
                        fPlayersTriggered = 0;
                    }
                    else
                    {
                        g_EntityFuncs.Remove( self );
                    }
                }
                
                g_Util.Debug( 'Porcentaje actual: ' + string( CurrentPercentage ) );
            }

            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }
}
