/*Original Script by Cubemath*/
/*
	Trigger something when someone enter the zone. trigger again when no one is in the zone.
	useful for making a infinite spawn feeling but when the player is around the squadmaker it is Off.-

INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/trigger_inout"

void MapInit()
{
	RegisterTriggerInOut();
}

- Suggestions:
	- monsters?
	- toggleable via trigger
*/

void RegisterTriggerInOut() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_inout", "trigger_inout" );
}

class trigger_inout : ScriptBaseEntity
{
	private bool m_blInside = false;
	private bool toggle	= false;
	
	void Spawn() 
	{
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.effects	|= EF_NODRAW;

		UTILS::SetSize( self );

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			toggle = true;
		}
		else
		{
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
		}
		toggle = !toggle;
	}
	
	void TriggerThink() 
	{
		float totalPlayers = 0.0f, playersTrigger = 0.0f, currentPercentage = 0.0f;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( !UTILS::InsideZone( pPlayer, self ) )
			{
				playersTrigger = playersTrigger + 1.0f;
			}
			else
			{
				if( !m_blInside )
				{
					// need simplify shit
					if( self.pev.frags == 0 )
						g_EntityFuncs.FireTargets( ""+self.pev.target+"", pPlayer, pPlayer, USE_TOGGLE );
					if( self.pev.frags == 1 )
						g_EntityFuncs.FireTargets( ""+self.pev.target+"", pPlayer, pPlayer, USE_ON );
					if( self.pev.frags == 2 )
						g_EntityFuncs.FireTargets( ""+self.pev.target+"", pPlayer, pPlayer, USE_OFF );
					m_blInside = true;
				}
			}

			totalPlayers = g_PlayerFuncs.GetNumPlayers();

			if( totalPlayers > 0.0f ) 
			{
				currentPercentage = playersTrigger / totalPlayers + 0.00001f;

				if( currentPercentage >= 1.00 && m_blInside ) 
				{
					if( self.pev.health == 0 )
						g_EntityFuncs.FireTargets( ""+self.pev.netname+"", pPlayer, pPlayer, USE_TOGGLE );
					if( self.pev.health == 1 )
						g_EntityFuncs.FireTargets( ""+self.pev.netname+"", pPlayer, pPlayer, USE_ON );
					if( self.pev.health == 2 )
						g_EntityFuncs.FireTargets( ""+self.pev.netname+"", pPlayer, pPlayer, USE_OFF );

					if( self.pev.SpawnFlagBitSet( 2 ) )
						g_EntityFuncs.Remove( self );
					else
					m_blInside = false;
				}
			}
		}
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
}