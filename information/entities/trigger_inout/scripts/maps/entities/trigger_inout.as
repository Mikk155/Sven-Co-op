/*Original Script by Cubemath*/
/*
	Trigger something when someone enter the zone. trigger again when no one is in the zone.
	useful for making a infinite spawn feeling but when the player is around the squadmaker it is Off.-
*/
enum trigger_once_flag
{
    SF_START_OFF = 1 << 0,
}

class trigger_inout : ScriptBaseEntity
{
	private bool m_blInside = false;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		if( szKey == "minhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} 
		else if( szKey == "maxhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else 
			return BaseClass.KeyValue( szKey, szValue );
	}
	
	void Spawn() 
	{
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;

        if( self.GetClassname() == "trigger_inout" && string( self.pev.model )[0] == "*" && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
        }
		else
		{
			g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );		
		}

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

        BaseClass.Spawn();
		
        if( !self.pev.SpawnFlagBitSet( SF_START_OFF ) )
		{	
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
	}

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if( self.pev.SpawnFlagBitSet( SF_START_OFF ) )
		{	
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
	}
	
	void TriggerThink() 
	{
		float totalPlayers = 0.0f, playersTrigger = 0.0f, currentPercentage = 0.0f;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( !Inside( pPlayer ) ) 
			{
				playersTrigger = playersTrigger + 1.0f;
			}
			else
			{
				if( !m_blInside )
				{
					//g_Game.AlertMessage(at_console, "Jugador " +pPlayer.pev.netname+ " Dentro :D\n"); 
					self.SUB_UseTargets( @self, USE_TOGGLE, 0 );
					m_blInside = true;
				}
			}

			totalPlayers = g_PlayerFuncs.GetNumPlayers();

			if( totalPlayers > 0.0f ) 
			{
				currentPercentage = playersTrigger / totalPlayers + 0.00001f;

				if( currentPercentage >= 1.00 && m_blInside ) 
				{
					//g_Game.AlertMessage(at_console, "Número de jugadores afuera trigereando: " +playersTrigger+ "\n"); 
					//g_Game.AlertMessage(at_console, "Todos los jugadores estan afuera :C\n"); 
					self.SUB_UseTargets( @self, USE_TOGGLE, 0 );
					m_blInside = false;
				}
			}
		}

		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	bool Inside(CBasePlayer@ pPlayer)
	{
		bool a = true;
		a = a && pPlayer.pev.origin.x + pPlayer.pev.maxs.x >= self.pev.origin.x + self.pev.mins.x;
		a = a && pPlayer.pev.origin.y + pPlayer.pev.maxs.y >= self.pev.origin.y + self.pev.mins.y;
		a = a && pPlayer.pev.origin.z + pPlayer.pev.maxs.z >= self.pev.origin.z + self.pev.mins.z;
		a = a && pPlayer.pev.origin.x + pPlayer.pev.mins.x <= self.pev.origin.x + self.pev.maxs.x;
		a = a && pPlayer.pev.origin.y + pPlayer.pev.mins.y <= self.pev.origin.y + self.pev.maxs.y;
		a = a && pPlayer.pev.origin.z + pPlayer.pev.mins.z <= self.pev.origin.z + self.pev.maxs.z;

		if(a)
			return true;
		else
			return false;
	}
}

void RegisterTriggerInOut() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_inout", "trigger_inout" );
}