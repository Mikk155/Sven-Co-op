/*
	Not solidity zone for tram ride like maps. "target" must be the train.
	spawnflag 1 start off
	

INSTALL:

#include "mikk/entities/tram_ride_train"

void MapInit()
{
	RegisterSolidityZone();
}

*/
void RegisterSolidityZone() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "tram_ride_train", "tram_ride_train" );
}

class tram_ride_train : ScriptBaseEntity 
{
	private bool toggle 			= true;
	void Spawn() 
	{
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( !self.pev.SpawnFlagBitSet( 1 ) )
		{
			toggle = false;
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}

        BaseClass.Spawn();
	}
	
    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
		if( toggle )
		{
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		else
		{
			SetThink( null );
			ResetValues();
		}

		toggle = !toggle;
	} // Toggle the entity by target

    void UpdateOnRemove()
    {
		ResetValues();
		
        BaseClass.UpdateOnRemove();
    }

	void ResetValues()
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			pPlayer.pev.rendermode  = kRenderNormal;
			pPlayer.pev.renderamt = 255;
			pPlayer.pev.flags &= ~FL_NOTARGET;
			pPlayer.pev.solid = SOLID_SLIDEBOX;
		}
	}
	
	void TriggerThink() 
	{
        CBaseEntity@ pTrain = null;
		while((@pTrain = g_EntityFuncs.FindEntityByTargetname(pTrain, self.pev.target)) !is null)
			g_EntityFuncs.SetOrigin( self, pTrain.Center());

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( ( self.pev.origin - pPlayer.pev.origin ).Length() <= 200 ) // 200 units aprox.
			{
				pPlayer.pev.solid = SOLID_NOT;
				pPlayer.pev.rendermode = kRenderTransAlpha;
				pPlayer.pev.flags |= FL_NOTARGET; // Not really intended for generic maps. i've just added this for rp_c09_m2. -Mikk
				pPlayer.pev.renderamt = 0;
			}else{ // Respawn players that somehow get out of the train.
				g_PlayerFuncs.RespawnPlayer(pPlayer, true, true);
			}
		}
		
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}