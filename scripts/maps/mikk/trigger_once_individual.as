/*
	trigger something once per player

INSTALL:

#include "mikk/trigger_once_individual"

void MapInit()
{
	RegisterTriggerOnceIndividual();
}

*/
#include "utils"

void RegisterTriggerOnceIndividual() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CBaseTriggerIndividually", "trigger_once_individual" );
}

class CBaseTriggerIndividually : ScriptBaseEntity, UTILS::MoreKeyValues
{
    private bool Toggle	= true;

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        ExtraKeyValues(szKey, szValue);

        return true;
    }
	
	void Spawn() 
	{
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.effects	|= EF_NODRAW;

		UTILS::SetSize( self, false );

        if( self.pev.SpawnFlagBitSet( 1 ) )
        {
            Toggle = false;
        }

        SetThink( ThinkFunction( this.TriggerThink ) );
        self.pev.nextthink = g_Engine.time + 0.1f;
		
        BaseClass.Spawn();
	}
	
    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        switch(useType)
        {
            case USE_ON:
            {
                Toggle = true;
            }
            break;

            case USE_OFF:
            {
                Toggle = false;
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
        if( !Toggle || multisource() )
        {
            self.pev.nextthink = g_Engine.time + 0.5f;
            return;
        }

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pPlayer.GetCustomKeyvalues().HasKeyvalue( "$i_"+string(self.pev.target) ) )
				continue;

			CustomKeyvalues@ ckvThis = pPlayer.GetCustomKeyvalues();

			if( UTILS::InsideZone( pPlayer, self ) )
			{
                UTILS::TriggerMode( self.pev.target, pPlayer );
				ckvThis.SetKeyvalue("$i_"+string(self.pev.target), 1 );
			}
		}
		self.pev.nextthink = g_Engine.time + 0.2f;
	}
}