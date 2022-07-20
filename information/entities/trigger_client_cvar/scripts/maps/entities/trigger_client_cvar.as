/*
	Script by -Mikk
	https://github.com/Mikk155
	Thaks to Gaftherman
	https://github.com/Gaftherman
*/	
enum trigger_client_cvar_flag
{
	SF_CVAR_ALL_PLAYERS = 1 << 0
}

class trigger_client_cvar : ScriptBaseEntity
{
	void Spawn() 
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NONE;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		BaseClass.Spawn();    
	}

	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		if( self.pev.SpawnFlagBitSet(SF_CVAR_ALL_PLAYERS) )
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

void RegisterClientCvar() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_client_cvar", "trigger_client_cvar" );
}