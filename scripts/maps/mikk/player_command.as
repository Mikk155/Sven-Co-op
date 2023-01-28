#include "utils"
namespace player_command
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_command::entity", "player_command" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: player_command\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mappers to force players to execute a cmd onto their consoles.\n"
        );
    }

    enum spawnflags
    {
        SF_CMD_ALL_PLAYERS = 1 << 0
    }

    class entity : ScriptBaseEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( self.pev.SpawnFlagBitSet( SF_CMD_ALL_PLAYERS ) )
            {
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
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
    }
    
    void ExecCommand( CBaseEntity@ pPlayer, const string command )
    {
        NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
            msg.WriteString( command );
        msg.End();
    }
}
// End of namespace