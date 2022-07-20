void RegisterTriggerAutoSave() 
{
	g_CustomEntityFuncs.RegisterCustomEntity( "game_save", "game_save" );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary g_WhoSpawn;

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ) 
{
	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	//g_Game.AlertMessage( at_console, 'El client se connecto correctamente.\n');

	if( g_SurvivalMode.IsActive() && !g_WhoSpawn.exists(SteamID) )
	{
		//g_Game.AlertMessage( at_console, 'El surivival esta activado.\n');
		g_WhoSpawn[SteamID] = @pPlayer;

		//g_Game.AlertMessage( at_console, 'Guardando el SteamID... \n');

		g_PlayerFuncs.RespawnPlayer(pPlayer, true, true);
	}

	return HOOK_CONTINUE;
}

enum GameSaveSaveFlags
{
	SF_GAMESAVE_OFF	= 1 << 0 // Iniciar apagado
}

class PlayerKeepData
{
	float health, max_health; //Health - Max Health
	float armor, max_armor; //Armor - Max Armor
	int touched; //How many game_save we took
	int spawned = 1; //How many spawns we activated
}

dictionary g_SpawnNumber;
HUDTextParams SpawnCountHudText, SpawnHudText;

class game_save : ScriptBaseEntity  
{
    private dictionary g_IDPlayers, g_IDPlayersAlt, g_Data;

    void Spawn()
    {
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.solid = SOLID_TRIGGER;

		g_EntityFuncs.SetModel( self, self.pev.model );
		g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( !self.pev.SpawnFlagBitSet( SF_GAMESAVE_OFF ) )
		{
			SetThink( ThinkFunction( this.SpawnThink ) );
			SetTouch( TouchFunction( this.SpawnTouch ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}

	    BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f)
    {
		SetThink( ThinkFunction( this.SpawnThink ) );
		SetTouch( TouchFunction( this.SpawnTouch ) );

		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void SpawnTouch( CBaseEntity@ pOther )
	{
		if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther ); //Cast the CBaseEntity to CBasePlayer
			string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()); //Getting the SteamID of the player

			if( pPlayer is null || g_IDPlayers.exists(SteamID) || g_IDPlayersAlt.exists(SteamID)  )
				return;

			PlayerKeepData@ pData = GetPlayerSpawn(pPlayer);
			g_Data[SteamID] = ++pData.touched; //What number of spawn is this for the player
			pData.health = pPlayer.pev.health; //Save health at the moment
			pData.max_health = pPlayer.pev.max_health; //Save Max Health at the moment
			pData.armor = pPlayer.pev.armorvalue; //Save Armor at the moment
			pData.max_armor = pPlayer.pev.armortype; //Save Max Armor at the moment

			g_IDPlayers[SteamID] = @pPlayer; //Save SteamID and player entity
		}
	}

	void SpawnThink()
	{	
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			PlayerKeepData@ pData = GetPlayerSpawn(pPlayer); //Getting the data saved of the player
            string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()); //Getting the SteamID of the player

			SpawnCountHUDText(pPlayer, pData); //Message of how many spawns he has

			if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() && g_IDPlayers.exists(SteamID) )
			{
				SpawnHUDText(pPlayer, pData); //Message of what he need to do to spawn
				if( int(g_Data[SteamID]) == pData.spawned && pPlayer.pev.button & (IN_USE | IN_ATTACK) != 0 )
				{
					pPlayer.GetObserver().RemoveDeadBody(); //Remove the dead player body
					pPlayer.SetOrigin( self.Center() ); //Move the player to the center of the brush
					pPlayer.Revive(); //Revive the player

					++pData.spawned;

					pPlayer.pev.health = Math.max( 1, pData.health ); //Set Health saved to the player
					pPlayer.pev.max_health = Math.max( 100, pData.max_health ); //Set Max Health saved to the player
					pPlayer.pev.armorvalue = Math.max( 0, pData.armor ); //Set Armor saved to the player
					pPlayer.pev.armortype = Math.max( 100, pData.max_armor ); //Set Max Armor saved to the player

					g_IDPlayers.delete(SteamID); //Delete the old SteamID in the g_IDPlayers dictionary
					g_IDPlayersAlt[SteamID] = @pPlayer; //Save the SteamID in the g_IDPlayersAlt dictionary

					//Why we do that?
					//Because that's the easier way to prevent an infinitive spawn cycle
				}
			}
        }
        
        self.pev.nextthink = g_Engine.time + 0.1f; //per frame
    }

	void SpawnCountHUDText( CBasePlayer@ pPlayer, PlayerKeepData@ pData )
	{
		SpawnCountHudText.x = 0.05;
		SpawnCountHudText.y = 0.05;
		SpawnCountHudText.effect = 0;
		SpawnCountHudText.r1 = RGBA_SVENCOOP.r;
		SpawnCountHudText.g1 = RGBA_SVENCOOP.g;
		SpawnCountHudText.b1 = RGBA_SVENCOOP.b;
		SpawnCountHudText.a1 = 0;
		SpawnCountHudText.r2 = RGBA_SVENCOOP.r;
		SpawnCountHudText.g2 = RGBA_SVENCOOP.g;
		SpawnCountHudText.b2 = RGBA_SVENCOOP.b;
		SpawnCountHudText.a2 = 0;
		SpawnCountHudText.fadeinTime = 0; 
		SpawnCountHudText.fadeoutTime = 0.25;
		SpawnCountHudText.holdTime = 0.2;
		SpawnCountHudText.fxTime = 0;
		SpawnCountHudText.channel = 8;

		g_PlayerFuncs.HudMessage(pPlayer, SpawnCountHudText, "Spawns: " + (pData.touched-(pData.spawned-1)));
	}

	void SpawnHUDText( CBasePlayer@ pPlayer, PlayerKeepData@ pData )
	{
		SpawnHudText.x = -1.0;
		SpawnHudText.y = 0.05;
		SpawnHudText.effect = 0;
		SpawnHudText.r1 = RGBA_SVENCOOP.r;
		SpawnHudText.g1 = RGBA_SVENCOOP.g;
		SpawnHudText.b1 = RGBA_SVENCOOP.b;
		SpawnHudText.a1 = 0;
		SpawnHudText.r2 = RGBA_SVENCOOP.r;
		SpawnHudText.g2 = RGBA_SVENCOOP.g;
		SpawnHudText.b2 = RGBA_SVENCOOP.b;
		SpawnHudText.a2 = 0;
		SpawnHudText.fadeinTime = 0; 
		SpawnHudText.fadeoutTime = 0.25;
		SpawnHudText.holdTime = 0.2;
		SpawnHudText.fxTime = 0;
		SpawnHudText.channel = 7;

		g_PlayerFuncs.HudMessage(pPlayer, SpawnHudText, "Press the 'Use' or 'Primary Attack' key to respawn");
	}

	PlayerKeepData@ GetPlayerSpawn(CBasePlayer@ pPlayer)
	{
		string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( !g_SpawnNumber.exists(SteamID) )
		{
			PlayerKeepData pData;
			g_SpawnNumber[SteamID] = pData;
		}

		return cast<PlayerKeepData@>( g_SpawnNumber[SteamID] );
	}
}