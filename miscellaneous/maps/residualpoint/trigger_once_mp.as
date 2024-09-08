/*
*	Original Script by Cubemath
*	Modified a bit by mikk & gaftherman
*/

/*

PLACED HERE CUZ MAY BE OUT OF DATE. im not doing a update for yet in residual point until v2 or something.-
*/

string ReadMap = "scripts/maps/mikk/antirush/" + string( g_Engine.mapname ) + ".txt";

void ReadFile()
{
    File@ pFile = g_FileSystem.OpenFile( ReadMap, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() ) 
        return;

    string line;

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
            
        if( line.Find("model") == String::INVALID_INDEX or line.Find("blipsound") == String::INVALID_INDEX ) 
            continue;

        array<string> SubLines = line.Split("\"");

        g_Game.AlertMessage( at_console, SubLines[3]+"\n" );
        g_Game.PrecacheModel( SubLines[3] );
    }

    pFile.Close();
}

const Cvar@ g_pCvarVoteAllow, g_pCvarVoteTimeCheck, g_pCvarVoteMapRequired;
string g_szPlayerName;
bool IsDisabledByVoted = false;

// At MapInit()
void RegisterAntiRushEntity() 
{
	// Register the entity
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_once_mp", "trigger_once_mp" );
	
	// Create/modify language support.
	CBaseEntity@ pFindTarget = null;
	while((@pFindTarget = g_EntityFuncs.FindEntityByClassname(pFindTarget, "info_target")) !is null)
	{
		if( pFindTarget.pev.targetname == "language" )
		{
			edict_t@ pEdict = pFindTarget.edict();
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_spanish", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_portuguese", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_portuguese", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_german", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_french", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_italian", "1" );
			g_EntityFuncs.DispatchKeyValue( pEdict, "$i_message_esperanto", "1" );
		}
		else
		{
			dictionary language;
			language ["$i_message"] = "1";
			language ["$i_message_spanish"] = "1";
			language ["$i_message_portuguese"] = "1";
			language ["$i_message_german"] = "1";
			language ["$i_message_french"] = "1";
			language ["$i_message_italian"] = "1";
			language ["$i_message_esperanto"] = "1";
			language ["targetname"] = "language";
			g_EntityFuncs.CreateEntity( "info_target", language, true );
		}
	}
	
	// Pre-Precache cuz spawned via MapStart x[
	g_SoundSystem.PrecacheSound( "buttons/bell1.wav" );
	g_Game.PrecacheGeneric( "sound/buttons/bell1.wav" );
	
	// Hook and vote things.
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	@g_pCvarVoteAllow = g_EngineFuncs.CVarGetPointer( "mp_voteallow" );
	@g_pCvarVoteTimeCheck = g_EngineFuncs.CVarGetPointer( "mp_votetimecheck" );
	@g_pCvarVoteMapRequired = g_EngineFuncs.CVarGetPointer( "mp_votemaprequired" );

	if ( g_pCvarVoteAllow !is null && g_pCvarVoteAllow.value < 1 or g_pCvarVoteMapRequired.value < 0 )
		return;

	// Tell people that antirush vote exist.
	dictionary keyvalues;
	keyvalues =	
	{
		{ "message", ""},
		{ "message_spanish", ""},
		{ "message_portuguese", ""},
		{ "message_german", ""},
		{ "message_french", ""},
		{ "message_italian", ""},
		{ "message_esperanto", ""},
		{ "x", "-1"},
		{ "y", "0.90"},
		{ "effect", "0"},
		{ "holdtime", "1"},
		{ "fadeout", "0"},
		{ "fadein", "0"},
		{ "channel", "8"},
		{ "fxtime", "0"},
		{ "color", "255 0 0"},
		{ "spawnflags", "2"}, // No echo console + activator only
		{ "targetname", "TellAboutVote" }
	};
	if( g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) ) 
	{ g_EntityFuncs.CreateEntity( "game_text_custom", keyvalues, true ); }
	else{ g_EntityFuncs.CreateEntity( "game_text", keyvalues, true ); }

	dictionary keyvalues2;
	keyvalues2 =	{ { "delay", "5"}, { "spawnflags", "64"}, { "target", "TellAboutVote"}, { "targetname", "game_playerspawn" } };
	g_EntityFuncs.CreateEntity( "trigger_relay", keyvalues2, true );
}

// At MapStart()
void LoadFileFromAntiRush()
{
// If you're using this method you'll wan't to precache your things at MapInit()
	const string JsFileLoad = "mikk/antirush/" + string( g_Engine.mapname ) + ".txt";
	
	if(!g_EntityLoader.LoadFromFile(JsFileLoad)){g_EngineFuncs.ServerPrint("Can't open antirush script file "+JsFileLoad+"\n" );}
}

// Code taked from Duk0
HookReturnCode MapChange()
{
	g_Scheduler.ClearTimerList();

	return HOOK_CONTINUE;
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();

	if ( pArguments.ArgC() >= 1 )
	{
		string szArg = pArguments.Arg( 0 );
		szArg.Trim();
		if ( szArg.ICompare( "/antirush" ) == 0 )
		{
			CBasePlayer@ pPlayer = pParams.GetPlayer();

			if ( pPlayer is null || !pPlayer.IsConnected() )
				return HOOK_CONTINUE;

			RestartVote( pPlayer );
		}
	}
	return HOOK_CONTINUE;
}

void RestartVote( CBasePlayer@ pPlayer )
{
	if ( g_pCvarVoteAllow !is null && g_pCvarVoteAllow.value < 1 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "Voting not allowed on server.\n" );
		return;
	}

	if ( g_pCvarVoteMapRequired.value < 0 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "This type of vote is disabled.\n" );
		return;
	}

	if ( g_Utility.VoteActive() )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, "Can't start vote. Other vote in progress.\n" );
		return;
	}
	
	g_szPlayerName = pPlayer.pev.netname;
	
	StartMapRestartVote();
}

void StartMapRestartVote()
{
	string AntiRushState = "Disable";
	
	float flVoteTime = g_pCvarVoteTimeCheck.value;
	
	if ( flVoteTime <= 0 )
		flVoteTime = 16;
		
	float flPercentage = g_pCvarVoteMapRequired.value;
	
	if ( flPercentage <= 0 )
		flPercentage = 66;

	if( IsDisabledByVoted == true )
	{
		AntiRushState = "Enable";
	}
	else if( IsDisabledByVoted == false )
	{
		AntiRushState = "Disable";
	}
	
	Vote vote( ""+AntiRushState+" Anti-Rush vote", ""+AntiRushState+" Anti-Rush?", flVoteTime, flPercentage );
	
	vote.SetVoteBlockedCallback( @RestartMapVoteBlocked );
	vote.SetVoteEndCallback( @RestartMapVoteEnd );
	
	vote.Start();

	if ( g_szPlayerName.IsEmpty() )
		g_szPlayerName = "*Empty*";

	g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, vote.GetName() + " started by " + g_szPlayerName + "\n" );
}

void RestartMapVoteBlocked( Vote@ pVote, float flTime )
{
	//Try again later
	g_Scheduler.SetTimeout( "StartMapRestartVote", flTime );
}

void RestartMapVoteEnd( Vote@ pVote, bool bResult, int iVoters )
{
	if ( !bResult )
	{
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "Vote for Toggle anti-rush failed\n" );
		return;
	}
	
	
	if( IsDisabledByVoted == true )
	{
		IsDisabledByVoted = false;
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "Vote for Disable Anti-Rush passed\n" );
	}
	else if( IsDisabledByVoted == false )
	{
		IsDisabledByVoted = true;
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTNOTIFY, "Vote for Enable Anti-Rush passed\n" );
	}
}

enum trigger_once_flag
{
    SF_AR_IS_OFF = 1 << 0,
	SF_AR_NOTEXT = 1 << 1,
	SF_AR_NOSOUN = 1 << 2
}
// No dejar mensajes subliminales que inciten al sexo -Gaf el hombre turkey
class trigger_once_mp : ScriptBaseEntity 
{
	private float m_flPercentage = 0.66; //Percentage of living people to be inside trigger to trigger
	private string killtarget	= "";
	private string strSound = "buttons/bell1.wav";
	
	bool BlIsEnabled = true;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		if( szKey == "percent" || szKey == "m_flPercentage" ) // Second one is only for legacy.
		{
			m_flPercentage = atof( szValue );
			return true;
		} 
		else if( szKey == "minhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser1, szValue );
			return true;
		} 
		else if( szKey == "maxhullsize" ) 
		{
			g_Utility.StringToVector( self.pev.vuser2, szValue );
			return true;
		}
		else if( szKey == "killtarget" )
		{
            killtarget = szValue;
			return true;
		}
		else if( szKey == "blipsound" )
		{
			strSound = szValue;
			return true;
		}
		else 
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		g_SoundSystem.PrecacheSound( strSound );

		g_Game.PrecacheGeneric( "sound/" + strSound );

		BaseClass.Precache();
	}
	
	void Spawn() 
	{
        self.Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.effects |= EF_NODRAW;
		self.pev.dmg = 9;
			
        if( self.GetClassname() == "trigger_once_mp" && string( self.pev.model )[0] == "*" && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
        }
		else
		{
			g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );		
		}

		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( !string( self.pev.targetname ).IsEmpty() )
		{
			BlIsEnabled = false;
		}

        if( !self.pev.SpawnFlagBitSet( SF_AR_IS_OFF ) )
		{
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		
		if( !string( self.pev.netname ).IsEmpty() )
		{
			RemoveBrushModel();
		}
		
		CreateFXIndividual();
		
		if( !self.pev.SpawnFlagBitSet( SF_AR_NOTEXT ))
		{
			CreateGameTextMLan();
		}

        BaseClass.Spawn();
	}

    void UpdateOnRemove()
    {
		do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) );
		while( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) !is null );

        BaseClass.UpdateOnRemove();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
        if( self.pev.SpawnFlagBitSet( SF_AR_IS_OFF ) )
		{	
			SetThink( ThinkFunction( this.TriggerThink ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		
		if( self.pev.health >= 1 ) { self.pev.health -= 1; }
	}
	
	void TriggerThink() 
	{
		float TotalPlayers = 0, PlayersTrigger = 0, CurrentPercentage = 0;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
					
			if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
				continue;

			if( UTILS::InsideZone( pPlayer, self ) )
				PlayersTrigger = PlayersTrigger + 1.0f;

			TotalPlayers = TotalPlayers + 1.0f;	
		}

		if(TotalPlayers > 0) 
		{
			CurrentPercentage = PlayersTrigger / TotalPlayers + 0.00001f;

			CBaseEntity@ pText = null;

			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
					continue;
					
				if( UTILS::InsideZone( pPlayer, self ) )
				{
					if( IsDisabledByVoted )
					{
						do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) );
						while( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) !is null );

						self.SUB_UseTargets( @self, USE_TOGGLE, 0 );

						g_EntityFuncs.Remove( self );
					}
		
					g_EntityFuncs.FireTargets( ""+self.pev.target+"_TEXT", pPlayer, pPlayer, USE_ON ); // Multi language message -mikk
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_ON ); // Don't spoiler outside people

					if( BlIsEnabled and CurrentPercentage <= m_flPercentage and self.pev.health <= 0 )
					{
						while((@pText = g_EntityFuncs.FindEntityByTargetname(pText, ""+self.pev.target+"_TEXT")) !is null)
						{
							edict_t@ pEdict = pText.edict();
							g_EntityFuncs.DispatchKeyValue( pEdict, "message", "ANTI-RUSH: " + int(m_flPercentage*100) + "% Of players needed to continue. Current: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_spanish", "ANTI-RUSH: " + int(m_flPercentage*100) + "% De jugadores necesario para continuar. Actual: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_portuguese", "ANTI-RUSH: " + int(m_flPercentage*100) + "% De jogadores necessarios para continuar. Atual: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_french", "ANTI-RUSH: " + int(m_flPercentage*100) + "% Des joueurs necessaires pour continuer. Courant: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_italian", "ANTI-RUSH: " + int(m_flPercentage*100) + "% Dei giocatori necessari per continuare. Attuale: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_esperanto", "ANTI-RUSH: " + int(m_flPercentage*100) + "% De ludantoj bezonis daurigi. Nuna: "+ int(CurrentPercentage*100) + "%\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_german", "ANTI-RUSH: " + int(m_flPercentage*100) + "% Von Spielern, die benotigt werden, um fortzufahren. Aktuell: "+ int(CurrentPercentage*100) + "%\n" );
						}
					}

					if( self.pev.health != 0 and self.pev.message == "" )
					{
						while((@pText = g_EntityFuncs.FindEntityByTargetname(pText, ""+self.pev.target+"_TEXT")) !is null)
						{
							edict_t@ pEdict = pText.edict();
							g_EntityFuncs.DispatchKeyValue( pEdict, "message", "ANTI-RUSH: Kill remaining " + self.pev.health + " enemies for progress.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_spanish", "ANTI-RUSH: Elimina los " + self.pev.health + " enemigos restantes para continuar.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_portuguese", "ANTI-RUSH: Mate " + self.pev.health + " inimigos restantes para continuar.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_french", "ANTI-RUSH: Tuez les " + self.pev.health + " ennemis restants pour progresser.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_italian", "ANTI-RUSH: Uccidi i restanti " + self.pev.health + " nemici per progredire.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_esperanto", "ANTI-RUSH: Mortigu " + self.pev.health + " ceterajn malamikojn por progreso.\n" );
							g_EntityFuncs.DispatchKeyValue( pEdict, "message_german", "ANTI-RUSH: Tote die verbleibenden " + self.pev.health + " Feinde, um voranzukommen.\n" );
						}
					}
				}
				else{
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_OFF ); // Don't spoiler outside people
				}
			}
				
				
			if( BlIsEnabled and CurrentPercentage >= m_flPercentage ) 
			{
				if( self.pev.frags > 0 )
				{
					while((@pText = g_EntityFuncs.FindEntityByTargetname(pText, ""+self.pev.target+"_TEXT")) !is null)
					{
						edict_t@ pEdict = pText.edict();
						
						g_EntityFuncs.DispatchKeyValue( pEdict, "message", "ANTI-RUSH: Count-down: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_spanish", "ANTI-RUSH: Cuenta-regresiva: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_portuguese", "ANTI-RUSH: Contagem-regressiva: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_french", "ANTI-RUSH: Compte a rebours: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_italian", "ANTI-RUSH: Conto alla rovescia: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_esperanto", "ANTI-RUSH: Retronombrado: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
						g_EntityFuncs.DispatchKeyValue( pEdict, "message_german", "ANTI-RUSH: Countdown: "+int(self.pev.frags)+"."+int(self.pev.dmg)+"0" );
					}
					self.pev.dmg = self.pev.dmg - 1;
					if( self.pev.dmg == 0 )
					{
						self.pev.dmg = 9;
						self.pev.frags = self.pev.frags - 1;
					}
				}
				else
				{
					if( !self.pev.SpawnFlagBitSet( SF_AR_NOSOUN ) )
					{
						g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, strSound, 1.0f, ATTN_NORM );
					}
						
					if( killtarget != "" && killtarget != self.GetTargetname() )
					{
						do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) );
						while( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) !is null );
					}
				
					do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) );
					while( g_EntityFuncs.FindEntityByTargetname( null, "" + self.pev.target + "_FX" ) !is null );

					self.SUB_UseTargets( @self, USE_TOGGLE, 0 );

					g_EntityFuncs.Remove( self );
				}
			}

			if( self.pev.health <= 0 )
				BlIsEnabled = true;
		}
	
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void CreateFXIndividual()
	{
		dictionary myFXs;
		myFXs ["targetname"] = "FX_" + self.pev.target;
		myFXs ["spawnflags"] = "64";
		myFXs ["rendermode"] = "5";
		myFXs ["renderamt"] = "255";
		myFXs ["target"] = "" + self.pev.target + "_FX";
		g_EntityFuncs.CreateEntity( "env_render_individual", myFXs, true );
	}

	void CreateGameTextMLan()
	{
		dictionary keyvalues;
		keyvalues =	
		{
			{ "message", ""},
			{ "message_spanish", ""},
			{ "message_portuguese", ""},
			{ "message_german", ""},
			{ "message_french", ""},
			{ "message_italian", ""},
			{ "message_esperanto", ""},
			{ "x", "-1"},
			{ "y", "0.90"},
			{ "effect", "0"},
			{ "holdtime", "1"},
			{ "fadeout", "0"},
			{ "fadein", "0"},
			{ "channel", "8"},
			{ "fxtime", "0"},
			{ "color", "255 0 0"},
			{ "spawnflags", "2"}, // No echo console + activator only
			{ "targetname", "" + self.pev.target + "_TEXT" }
		};
		if( g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) ) 
			g_EntityFuncs.CreateEntity( "game_text_custom", keyvalues, true );
		else 
			g_EntityFuncs.CreateEntity( "game_text", keyvalues, true );
	}
	
	void RemoveBrushModel()
	{
		CBaseEntity@ pFindLocker = null;
		
		while((@pFindLocker = g_EntityFuncs.FindEntityByClassname(pFindLocker, "*")) !is null)
		{
			if( ""+self.pev.netname+"" == ""+pFindLocker.pev.model+"" )
			{
				if( pFindLocker.GetCustomKeyvalues().HasKeyvalue( "$i_ignore" ) )
					continue;

				g_EntityFuncs.Remove( pFindLocker );
			}
		}
	}
}