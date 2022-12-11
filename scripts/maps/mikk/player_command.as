/*
DOWNLOAD:

scripts/maps/mikk/player_command.as
scripts/maps/mikk/utils.as


INSTALL:


#include "mikk/player_command"

void MapInit()
{
    player_command::Register();
}

BLACKLISTED COMMANDS:
- say
-
-
-
-
-

*/

namespace player_command
{
    enum player_command_flags
    {
        SF_CMD_ALL_PLAYERS = 1 << 0
    }

    class player_command : ScriptBaseEntity
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
                ExecCommand( cast<CBasePlayer@>(pActivator), self.pev.message );
            }
        }
    }
    
    void ExecCommand( CBaseEntity@ pPlayer, const string command )
    {
        NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
            msg.WriteString( command );
        msg.End();
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_command::player_command", "player_command" );
    }
}// end namespace