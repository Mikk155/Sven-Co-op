/*
*	Original Script by Cubemath
*	Modified a bit by mikk & gaftherman
*/

/*

INSTALL:

#include "mikk/entities/utils"
#include "mikk/entities/trigger_once_mp"

void MapInit()
{
	RegisterAntiRushEntity();
}


	Suggestions:
	-
	
	Place here your suggestions
	-
	- A way to "Watch" for monsters state (alive/dead) then specify in the entity how many should be dead to enable this. alternative for skull without modify maps.
	
	
	If you're moding with this please check the wiki https://github.com/Mikk155/Sven-Co-op/wiki/Anti-Rush---Spanish
*/

// Start of customizable zone

// Percentage of living people to be inside the zone. ( Maps probably has their custom percentage )
float flPercentagePeople = 0.66;

// Choose a channel (1-8) of your preference for this plugin uses messages.
float flChannel = 6;

// true = Disable votes.
bool DisableVotes = false;

// Time to vote
float flVoteTime = 15;

// Percentage required for vote
float flPercentage = 40;

// End of customizable zone

bool IsDisabledByVoted = false;

string g_szPlayerName;

// At MapInit()
void RegisterAntiRushEntity() 
{
	// Register the entity
	g_CustomEntityFuncs.RegisterCustomEntity( "trigger_once_mp", "trigger_once_mp" );
	// Hook and vote things.
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	// Load files
	const string JsFileLoad = "mikk/antirush/" + string( g_Engine.mapname ) + ".txt";
	// Debug
	if(!g_EntityLoader.LoadFromFile(JsFileLoad)){g_EngineFuncs.ServerPrint("Can't open antirush script file "+JsFileLoad+"\n" );}
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

			if( DisableVotes )
			{
				ANTIRUSH::Messager( pPlayer, 0, 0, 0 );
				return HOOK_CONTINUE;
			}

			ExecVote();

			if( g_szPlayerName.IsEmpty() )
				g_szPlayerName = "*Empty*";

			g_szPlayerName = pPlayer.pev.netname;

			ANTIRUSH::GlobalMessager( 0 );
		}
	}
	return HOOK_CONTINUE;
}

void ExecVote()
{
	if ( flVoteTime <= 0 )
		flVoteTime = 16;

	if ( flPercentage <= 0 )
		flPercentage = 51;

	Vote vote( "Anti-Rush", "Want to toggle anti-rush state?", flVoteTime, flPercentage );
	vote.SetYesText( "Enable");
	vote.SetNoText( "Disable" );
	vote.SetVoteBlockedCallback( @VoteBlockedTryLater );
	vote.SetVoteEndCallback( @VoteEndCallBack );
	
	vote.Start();
}

//Try again later
void VoteBlockedTryLater( Vote@ pVote, float flTime )
{
	g_Scheduler.SetTimeout( "StartMapRestartVote", flTime );
}

void VoteEndCallBack( Vote@ pVote, bool bResult, int iVoters )
{
	if ( bResult )
	{
		ANTIRUSH::GlobalMessager( 2 );
		IsDisabledByVoted = false;
	}
	else
	{
		ANTIRUSH::GlobalMessager( 1 );
		IsDisabledByVoted = true;
	}
}

enum trigger_once_flag
{
    SF_AR_IS_OFF = 1 << 0,
	SF_AR_NOTEXT = 1 << 1,
	SF_AR_NOSOUN = 1 << 2,
	SF_AR_USEVEC = 1 << 3
}

class trigger_once_mp : ScriptBaseEntity, MLAN::MoreKeyValues
{
	private float m_flPercentage = flPercentagePeople;
	private string killtarget	= "";
	
	bool BlIsEnabled = true;
	
	bool KeyValue( const string& in szKey, const string& in szValue ) 
	{
		SexKeyValues(szKey, szValue);

		if( szKey == "percent" || szKey == "m_flPercentage" )
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
		else 
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Spawn() 
	{
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.effects |= EF_NODRAW;
		self.pev.dmg = 9;

		if( self.GetClassname() == "trigger_once_mp" && string( self.pev.model )[0] == "*" && self.IsBSPModel() )
        {
            g_EntityFuncs.SetModel( self, self.pev.model );
            g_EntityFuncs.SetSize( self.pev, self.pev.mins, self.pev.maxs );
			g_EntityFuncs.SetOrigin( self, self.pev.origin );
        }
		else
		{
			g_EntityFuncs.SetSize( self.pev, self.pev.vuser1, self.pev.vuser2 );	

			if( self.pev.SpawnFlagBitSet( SF_AR_USEVEC ) )
			{
				g_EntityFuncs.SetOrigin( self, self.pev.origin );
			}	
		}

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

		if( self.pev.health >= 1 )
		{
			self.pev.health -= 1;
		}
		
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
						FireAfterConditions();
					}

					if( !self.pev.SpawnFlagBitSet( SF_AR_NOTEXT ))
					{
						if( BlIsEnabled and CurrentPercentage <= m_flPercentage and self.pev.health <= 0 )
						{
							ANTIRUSH::Messager( pPlayer, m_flPercentage, CurrentPercentage, 2 );
						}

						if( self.pev.health != 0 )
						{
							ANTIRUSH::Messager( pPlayer, self.pev.health, 0, 1 );
						}
					}

					if( BlIsEnabled and CurrentPercentage >= m_flPercentage && self.pev.frags > 0 && !self.pev.SpawnFlagBitSet( SF_AR_NOTEXT ) ) 
					{
						ANTIRUSH::Messager( pPlayer, self.pev.frags, self.pev.dmg, 0 );
					}

				// Don't spoiler outside people
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_ON );
				}else{
					g_EntityFuncs.FireTargets( "FX_" + self.pev.target, pPlayer, pPlayer, USE_OFF );
				}
			}

			if( BlIsEnabled and CurrentPercentage >= m_flPercentage ) 
			{
				if( self.pev.frags > 0 )
				{
					self.pev.dmg = self.pev.dmg - 1;
					if( self.pev.dmg == 0 )
					{
						self.pev.dmg = 9;
						self.pev.frags = self.pev.frags - 1;
					}
				}else{
					FireAfterConditions();
				}
			}

			if( self.pev.health <= 0 )
				BlIsEnabled = true;
		}
	
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void FireAfterConditions()
	{
		if( !self.pev.SpawnFlagBitSet( SF_AR_NOSOUN ) )
		{
			NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
			message.WriteString( "spk buttons/bell1" );
			message.End();
		}
		if( killtarget != "" && killtarget != self.GetTargetname() )
		{
			do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) );
			while( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) !is null );
		}
		self.SUB_UseTargets( @self, USE_TOGGLE, 0 );

		UpdateOnRemove();

		g_EntityFuncs.Remove( self );
	}

	void CreateFXIndividual()
	{
		dictionary myFXs;
		myFXs ["targetname"] = "FX_" + self.pev.target;
		myFXs ["spawnflags"] = "64";
		myFXs ["rendermode"] = self.pev.rendermode;
		myFXs ["renderamt"] = self.pev.renderamt;
		myFXs ["target"] = "" + self.pev.target + "_FX";
		g_EntityFuncs.CreateEntity( "env_render_individual", myFXs, true );
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

HUDTextParams TextHudParams;

namespace ANTIRUSH
{
	void Messager( CBasePlayer@ pPlayer, float flOne, float flTwo, int mode )
	{
		int iLanguage = MLAN::GetCKV( pPlayer, "$f_lenguage");

		TextHudParams.x = -1;
		TextHudParams.y = 0.95;
		TextHudParams.effect = 0;
		TextHudParams.r1 = 255;
		TextHudParams.g1 = 0;
		TextHudParams.b1 = 0;
		TextHudParams.a1 = 0;
		TextHudParams.r2 = 255;
		TextHudParams.g2 = 0;
		TextHudParams.b2 = 0;
		TextHudParams.a2 = 0;
		TextHudParams.fadeinTime = 0; 
		TextHudParams.fadeoutTime = 0.25;
		TextHudParams.holdTime = 2;
		TextHudParams.fxTime = 0;
		TextHudParams.channel = int(flChannel);

		if( mode == 0 )
		{
			if(iLanguage == 1 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Cuenta-regresiva: "+int(flOne)+"."+int(flTwo)+"0" );
			else if(iLanguage == 2 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Contagem-regressiva: "+int(flOne)+"."+int(flTwo)+"0" );
			else if(iLanguage == 3 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Countdown: "+int(flOne)+"."+int(flTwo)+"0" );
			else if(iLanguage == 4 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Compte a rebours: "+int(flOne)+"."+int(flTwo)+"0" );
			else if(iLanguage == 5 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Conto alla rovescia: "+int(flOne)+"."+int(flTwo)+"0" );
			else if(iLanguage == 6 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Retronombrado: "+int(flOne)+"."+int(flTwo)+"0" );
			else
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Count-down: "+int(flOne)+"."+int(flTwo)+"0" );
		}
		else if( mode == 1 )
		{
			if(iLanguage == 1 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Elimina los " + flOne + " enemigos restantes para continuar.\n" );
			else if(iLanguage == 2 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Mate " + flOne + " inimigos restantes para continuar.\n" );
			else if(iLanguage == 3 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Tote die verbleibenden " + flOne + " Feinde, um voranzukommen.\n" );
			else if(iLanguage == 4 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Tuez les " + flOne + " ennemis restants pour progresser.\n" );
			else if(iLanguage == 5 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Uccidi i restanti " + flOne + " nemici per progredire.\n" );
			else if(iLanguage == 6 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Mortigu " + flOne + " ceterajn malamikojn por progreso.\n" );
			else
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: Kill remaining " + flOne + " enemies for progress.\n" );
		}
		else if( mode == 2 )
		{
			if(iLanguage == 1 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% De jugadores necesario para continuar. Actual: "+ int(flTwo*100) + "%\n" );
			else if(iLanguage == 2 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% De jogadores necessarios para continuar. Atual: "+ int(flTwo*100) + "%\n" );
			else if(iLanguage == 3 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% Von Spielern, die benotigt werden, um fortzufahren. Aktuell: "+ int(flTwo*100) + "%\n" );
			else if(iLanguage == 4 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% Des joueurs necessaires pour continuer. Courant: "+ int(flTwo*100) + "%\n" );
			else if(iLanguage == 5 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% Dei giocatori necessari per continuare. Attuale: "+ int(flTwo*100) + "%\n" );
			else if(iLanguage == 6 )
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% De ludantoj bezonis daurigi. Nuna: "+ int(flTwo*100) + "%\n" );
			else
				g_PlayerFuncs.HudMessage( pPlayer, TextHudParams, "ANTI-RUSH: " + int(flOne*100) + "% Of players needed to continue. Current: "+ int(flTwo*100) + "%\n" );
		}
		else if( mode == 3 )
		{
			if(iLanguage == 1 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] La votacion ha sido deshabilitada en este servidor." );
			else if(iLanguage == 2 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] A votacao foi desabilitada neste servidor." );
			else if(iLanguage == 3 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Die Abstimmung wurde auf diesem Server deaktiviert." );
			else if(iLanguage == 4 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Le vote a ete desactive sur ce serveur." );
			else if(iLanguage == 5 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Il voto e stato disabilitato su questo server." );
			else if(iLanguage == 6 )
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdono estis malsaltita en ci tiu servilo." );
			else
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote has been disabled on this server." );
		}
	}
	
	void GlobalMessager( int mode )
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

			if( mode == 0 )
			{
				if(iLanguage == 1 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion iniciada por " + g_szPlayerName + "\n" );
				else if(iLanguage == 2 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacao iniciada por " + g_szPlayerName + "\n" );
				else if(iLanguage == 3 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung gestartet von " + g_szPlayerName + "\n" );
				else if(iLanguage == 4 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote commence par " + g_szPlayerName + "\n" );
				else if(iLanguage == 5 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votazione iniziata da " + g_szPlayerName + "\n" );
				else if(iLanguage == 6 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdono komencita de " + g_szPlayerName + "\n" );
				else
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote started by " + g_szPlayerName +"\n" );
			}
			else if( mode == 1 )
			{
				if(iLanguage == 1 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion para deshabilitar Anti-Rush aprobada." );
				else if(iLanguage == 2 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote para desativar o Anti-Rush aprovado." );
				else if(iLanguage == 3 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung zum Deaktivieren von Anti-Rush bestanden." );
				else if(iLanguage == 4 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votez pour desactiver l'Anti-Rush passe." );
				else if(iLanguage == 5 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Voto per disabilitare Anti-Rush superato." );
				else if(iLanguage == 6 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdoni por malebligi Kontrau-Rush pasis." );
				else
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote for disable Anti-Rush passed." );
			}
			else if( mode == 2 )
			{
				if(iLanguage == 1 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votacion para habilitar Anti-Rush aprobada." );
				else if(iLanguage == 2 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote para ativar o Anti-Rush aprovado." );
				else if(iLanguage == 3 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Abstimmung zum Aktivieren von Anti-Rush bestanden." );
				else if(iLanguage == 4 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Votez pour activer l'Anti-Rush passe." );
				else if(iLanguage == 5 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vota per abilitare Anti-Rush superato." );
				else if(iLanguage == 6 )
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vocdoni por ebligi Anti-Rush pasis." );
				else
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[ANTI-RUSH] Vote for enable Anti-Rush passed." );
			}
		}
	}
}