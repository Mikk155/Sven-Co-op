#include "utils/customentity"
#include "utils"

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
            if( IsLockedByMaster() )
                return;

            if( spawnflag( 1 ) )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    ExecCommand( pPlayer, self.pev.message );
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                ExecCommand( cast<CBasePlayer@>( pActivator ), self.pev.message );
            }
        }

        void ExecCommand( CBasePlayer@ pPlayer, string command )
        {
            g_Util.ExecPlayerCommand( pPlayer, command );

            g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
        }
    }
}