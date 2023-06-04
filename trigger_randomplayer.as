#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_randomplayer
{
    void Register()
    {
        g_Util.CustomEntity( 'trigger_randomplayer' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_randomplayer' ) +
            g_ScriptInfo.Description( 'When fired, Triggers its target with a random player as activator' ) +
            g_ScriptInfo.Wiki( 'trigger_randomplayer' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class trigger_randomplayer : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !IsLockedByMaster() )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( Math.RandomLong( 1, g_PlayerFuncs.GetNumPlayers() ) );

                g_Util.Trigger( string( self.pev.target ), pPlayer, self, g_Util.itout( m_iUseType, useType ), m_fDelay );
            }
        }
    }
}
