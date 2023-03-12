#include "utils"
namespace player_command
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_command::entity", "player_command" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#player_command\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Allow mappers to force players to execute a cmd onto their consoles.\n"
        );
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
			if( master() )
				return;

            if( spawnflag( 1 ) )
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

		void ExecCommand( CBaseEntity@ pPlayer, const string command )
		{
			NetworkMessage msg( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
				msg.WriteString( command );
			msg.End();

			g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
		}
    }
}
// End of namespace