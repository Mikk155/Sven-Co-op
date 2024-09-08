/*
	let all players be able to trigger something once. useful for showing messages at the proper time.

INSTALL:

#include "mikk/entities/trigger_once_individual"

void MapInit()
{
	CBaseTriggerIndividual();
}
*/

#include "utils"

void CBaseTriggerIndividual() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CBaseTriggerIndividual", "trigger_once_individual" );
}

class CBaseTriggerIndividual : ScriptBaseEntity
{
	private bool Toggle	= false;
	
	void Spawn() 
	{
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.effects	|= EF_NODRAW;

		UTILS::SetSize( self );

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			Toggle = true;
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
        switch(useType)
        {
            case USE_ON:
            {
                Toggle = false;
            }
            break;

            case USE_OFF:
            {
                Toggle = true;
            }
            break;

            default:
            {
                Toggle = !Toggle;
            }
            break;
        }
	}

	void TriggerThink() 
	{
		if( Toggle )
			return;

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