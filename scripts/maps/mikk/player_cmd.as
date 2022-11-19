/*
	Script by -Mikk
	https://github.com/Mikk155
	Thanks to Gaftherman
	https://github.com/Gaftherman
	
	"message" is the cvar to execute on the player activator or everyone if flag 1 is set.

INSTALL:

#include "mikk/player_cmd"

void MapInit()
{
	RegisterClientCvar();
}


NOTES:
- using strings aka "space" works.
- some commands that requires sv_cheats works but that's it. they need sv_cheats...
- If using "+" commands. make sure to return the same command with "-" a second later or so.

BLACKLISTED COMMANDS:
- say
- Sexo?
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-
-need more testing

*/
void RegisterClientCvar() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "player_cmd", "player_cmd" );
}

class player_cmd : ScriptBaseEntity
{
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
					msg.WriteString( self.pev.message );
				msg.End();
			}
		}
		else if( pActivator !is null && pActivator.IsPlayer() )
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);

			NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
				msg.WriteString( self.pev.message );
			msg.End();
		}
	}
}