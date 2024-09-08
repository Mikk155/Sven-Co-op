#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace player_command
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_command::player_command", "player_command" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_command' ) +
            g_ScriptInfo.Description( 'Executes a ClientCVAR on the client target' ) +
            g_ScriptInfo.Wiki( 'player_command' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    class player_command : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !IsLockedByMaster() )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( g_Util.WhoAffected( pPlayer, m_iAffectedPlayer, pPlayer ) )
                    {
                        g_Util.ExecPlayerCommand( pPlayer, self.pev.message );

                        g_Util.Trigger( self.pev.target, pPlayer, self, g_Util.itout( m_iUseType, useType ), m_fDelay );
                    }
                }
            }
        }
    }
}