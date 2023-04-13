#include "utils"

bool player_command_register = g_Util.CustomEntity( 'player_command::player_command','player_command' );

namespace player_command
{
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

        void ExecCommand( CBaseEntity@ pPlayer, const string command )
        {
            NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
                msg.WriteString( command );
            msg.End();

            g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
        }
    }
}