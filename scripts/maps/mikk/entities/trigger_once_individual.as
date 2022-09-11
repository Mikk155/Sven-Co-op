/*
	trigger something once per player

INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/trigger_once_individual"

void MapInit()
{
	RegisterTriggerOnceIndividual();
}

*/

void RegisterTriggerOnceIndividual() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_once_individual", "trigger_once_individual" );
}

class trigger_once_individual : ScriptBaseEntity
{
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
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pPlayer.GetCustomKeyvalues().HasKeyvalue( "$i_"+string(self.pev.target) ) )
				continue;

			CustomKeyvalues@ ckvThis = pPlayer.GetCustomKeyvalues();

			if( UTILS::InsideZone( pPlayer, self ) )
			{
				g_EntityFuncs.FireTargets( self.pev.target, pPlayer, pPlayer, USE_TOGGLE );
				ckvThis.SetKeyvalue("$i_"+string(self.pev.target), 1 );
			}
		}
		self.pev.nextthink = g_Engine.time + 0.2f;
	}
}