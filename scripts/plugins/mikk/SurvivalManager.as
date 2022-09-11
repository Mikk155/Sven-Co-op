/*
	simple script that makes survival mode (Both disabled and enabled) better.
	
	if survival mode is disabled dead people can join spec mode for some seconds before they can respawn.
	looking from your dead body seems to be boring sometimes x[
	
	ammo dupe or duplication on death is disabled while survival is disabled.
	
	if survival mode is enabled the messages on the screen saying "Survival will start in X seconds" are removed.
	
	"plugin"
	{
		"name" "SurvivalManager"
		"script" "mikk/SurvivalManager"
	}
	
	thanks to Duk0 for vote code
	https://github.com/Duk0
	
Thanks to Outerbeast https://github.com/Outerbeast & Gaftherman https://github.com/Gaftherman
For teach me x[

*/

// Starts of customizable zone.

// 0 = Disable players votes
// 1 = Enable players votes
float flSurvivalVoteEnabled = 1;

// Time ( in seconds ) that the vote will be on cooldown when a vote ends.
float flCooldown = 300;

// Percentage required for vote
float flPercentage = 66;

// 0 = Survival mode depends on map support.
// 1 = Survival mode will starts always on.
// 2 = Survival mode will starts always off.
float flSurvivalStartsMode = 0;

// Time ( OVERRIDES MAPS ) in seconds that survival will take before initiate.
// 0 = get mp_survival_startdelay value.
float flSurvivalStartDelay = 0;

// Time in seconds that player must wait to resurrect.
// 0 = based on mp_respawndelay value.
float flRespawnDelay = 0;

// Choose a channel (1-8) of your preference for this plugin uses messages.
float flChannel = 7;

// Receive debugs if true
bool DebugMode = false;

// Ends of customizable zone.

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );

	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

string g_szPlayerName;

bool blSurvivalIs = false;

float flSurvivalWas = 1;
float flNoMoreVotes = 0;

void MapInit()
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	if( flSurvivalStartDelay == 0 )
		flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );

	// Maps decide.
	if( flSurvivalStartsMode == 0 )
		flSurvivalWas = g_EngineFuncs.CVarGetFloat( "mp_survival_supported" );

	// Add delay based on cvar if not specified.
	if( flRespawnDelay == 0 )
		flRespawnDelay = g_EngineFuncs.CVarGetFloat( "mp_respawndelay" );

	// DO NOT CHANGE INTERVAL TIME
	g_Scheduler.SetInterval( "CheckTime", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
	
}

void MapActivate()
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	// Enable survival mode and use our own mode.
	g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 1 );
	g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
	g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 1 );
	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
	g_SurvivalMode.Activate( true );
	g_SurvivalMode.Enable();
	g_Scheduler.SetTimeout( "InitializeSurvivalIsON", flSurvivalStartDelay );
	flNoMoreVotes = flSurvivalStartDelay;
}

void InitializeSurvivalIsON()
{
	// Starts on
	if( flSurvivalStartsMode == 1 )
	{
		blSurvivalIs = true;
		Sound( 1 );
	}
	
	// Maps decide.
	if( flSurvivalStartsMode == 0 && flSurvivalWas == 1 )
	{
		Sound( 1 );
		blSurvivalIs = true;
	}
}

CClientCommand g_SurvivalCommand( "survival", "Enable/Disable survival mode.", @ManipulateSurvival, ConCommandFlag::AdminOnly);

void ManipulateSurvival(const CCommand@ pArguments)
{
	if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) )
		return;

	if( pArguments.Arg(0) == ".survival" )
	{
		if( pArguments.Arg(1) == "enable" || pArguments.Arg(1) == "1" )
		{
			Sound( 1 );
			blSurvivalIs = true;
			GlobalMessager( 3 );
		}
		if( pArguments.Arg(1) == "disable" || pArguments.Arg(1) == "0" )
		{
			Sound( 0 );
			blSurvivalIs = false;
			GlobalMessager( 2 );
		}
	}
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	const CCommand@ pArguments = pParams.GetArguments();

	if ( pArguments.ArgC() >= 1 )
	{
		string szArg = pArguments.Arg( 0 );
		szArg.Trim();
		if ( szArg.ICompare( "/survival" ) == 0 )
		{
			CBasePlayer@ pPlayer = pParams.GetPlayer();

			if ( pPlayer is null || !pPlayer.IsConnected() )
				return HOOK_CONTINUE;

			CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
			int iLanguage = int(ckLenguageIs.GetFloat());	
			
			if( flNoMoreVotes > 1 ){
				if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Espera "+flNoMoreVotes+"s antes de iniciar una votacion.\n" );
				else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] esperar "+flNoMoreVotes+"s antes de iniciar uma votacao.\n" );
				else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Warte ab "+flNoMoreVotes+"s bevor Sie eine Abstimmung starten.\n" );
				else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Attendre "+flNoMoreVotes+"s avant de commencer un vote.\n" );
				else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] aspettare "+flNoMoreVotes+"s prima di iniziare una votazione.\n" );
				else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Wait "+flNoMoreVotes+"s before start a vote.\n" );
				return HOOK_CONTINUE;
			}else if( g_CustomEntityFuncs.IsCustomEntity( "survival_manager" ) ){
				if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Este mapa usa una version-de-mapa del script.\n" );
				else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Este mapa usa uma versao de mapa deste script.\n" );
				else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Diese Karte verwendet eine Kartenversion dieses Skripts.\n" );
				else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Cette carte utilise une version cartographique de ce script.\n" );
				else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Questa mappa utilizza una versione mappa di questo script.\n" );
				else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] This map uses a map version of this script.\n" );
				return HOOK_CONTINUE;
			}else if ( flSurvivalVoteEnabled == 0 ){
				if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Este tipo de votacion esta desactivada.\n" );
				else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Este tipo de votacao esta desabilitado.\n" );
				else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Diese Art der Abstimmung ist deaktiviert.\n" );
				else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Ce type de vote est desactive.\n" );
				else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Questo tipo di voto e disabilitato.\n" );
				else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] This type of vote is disabled.\n" );
				return HOOK_CONTINUE;
			}
			if ( g_szPlayerName.IsEmpty() ) g_szPlayerName = "*Empty*";

			g_szPlayerName = pPlayer.pev.netname;

			if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacion iniciada por " + g_szPlayerName + "\n" );
			else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacao iniciada por " + g_szPlayerName + "\n" );
			else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Abstimmung gestartet von " + g_szPlayerName + "\n" );
			else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote commence par " + g_szPlayerName + "\n" );
			else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votazione iniziata da " + g_szPlayerName + "\n" );
			else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote started by " + g_szPlayerName +"\n" );

			StartVoteMenu();
		}
		if ( szArg.ICompare( "survival" ) == 0 || szArg.ICompare( "spawn" ) == 0 || szArg.ICompare( "join" ) == 0 )
		{
			CBasePlayer@ pPlayer = pParams.GetPlayer();

			if ( pPlayer is null || !pPlayer.IsConnected() || flSurvivalVoteEnabled == 0 )
				return HOOK_CONTINUE;

				CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
				CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
				int iLanguage = int(ckLenguageIs.GetFloat());

				if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Escribe /survival para iniciar una votacion.\n" );
				else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] digite /survival para iniciar uma votacao.\n" );
				else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Geben Sie /survival ein, um eine Abstimmung zu starten.\n" );
				else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] dites /survie pour lancer un vote.\n" );
				else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] digita /sopravvivenza per iniziare una votazione.\n" );
				else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] type /survival to start a vote.\n" );
		}
	}
	return HOOK_CONTINUE;
}

void StartVoteMenu()
{
	float flVoteTime = 10;
	
	if ( flVoteTime <= 0 )
		flVoteTime = 16;
	
	if ( flPercentage <= 0 )
		flPercentage = 51;

	Vote vote( "Survival mode vote", "Change Survival-Mode?", flVoteTime, flPercentage );
	vote.SetYesText( "Enable");
	vote.SetNoText( "Disable" );
	
	vote.SetVoteBlockedCallback( @VoteBlockedTryLater );
	vote.SetVoteEndCallback( @VotePassed );
	
	vote.Start();
	
	g_Scheduler.SetTimeout( "VoteEndCallBack", 10.0f );
	g_Scheduler.SetTimeout( "VoteEndCallBackEnd", 15.0f );
	
	// Block votes.
	flNoMoreVotes = int(flCooldown);
}

void VoteBlockedTryLater( Vote@ pVote, float flTime )
{
	//Try again later
	g_Scheduler.SetTimeout( "StartVoteMenu", flTime );
}

void VotePassed( Vote@ pVote, bool bResult, int iVoters )
{
	if ( !bResult )
	{
		Sound( 1 );
		blSurvivalIs = false;
		GlobalMessager( 1 );
		
		if( DebugMode )
			g_Game.AlertMessage( at_console, "Survival Disabled.\n" );
	}
	else
	{
		Sound( 0 );
		blSurvivalIs = true;
		GlobalMessager( 0 );
		
		if( DebugMode )
			g_Game.AlertMessage( at_console, "Survival Enabled.\n" );
	}
	
}

void GlobalMessager( int mode )
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(pPlayer is null )
			continue;

		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
		CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
		int iLanguage = int(ckLenguageIs.GetFloat());

		if( mode == 0){
			if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacion exitosa para habilitar el modo de supervivencia.\n" );
			else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacao aprovada para Ativar modo de sobrevivencia.\n" );
			else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Abstimmung fur uberlebensmodus aktivieren bestanden.\n" );
			else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote passe pour Activer le mode de survie.\n" );
			else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Voto superato per Abilita modalita sopravvivenza.\n" );
			else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote passed for Enable survival mode.\n" );
		}
		else if( mode == 1){
			if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacion Fallida para habilitar el modo de supervivencia.\n" );
			else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Votacao aprovada para desativar o modo de sobrevivencia.\n" );
			else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Abstimmung für uberlebensmodus deaktivieren bestanden.\n" );
			else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote passe pour Desactiver le mode de survie.\n" );
			else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Voto superato per Disattiva modalita sopravvivenza.\n" );
			else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Vote passed for Disable survival mode.\n" );
		}
		else if( mode == 2){
			if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] El modo de supervivencia fue desactivado por un administrador.\n" );
			else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] O modo de sobrevivencia foi desativado por um administrador.\n" );
			else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Der uberlebensmodus wurde von einem Administrator deaktiviert.\n" );
			else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Le mode de survie a ete desactive par un administrateur.\n" );
			else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] La modalita Sopravvivenza a stata disabilitata da un amministratore.\n" );
			else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Survival mode has been Disabled by an admin.\n" );
		}
		else if( mode == 3){
			if(iLanguage == 1 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] El modo de supervivencia fue activado por un administrador.\n" );
			else if(iLanguage == 2 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Modo de sobrevivencia ativado por um administrador.\n" );
			else if(iLanguage == 3 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Uberlebensmodus von einem Administrator aktiviert.\n" );
			else if(iLanguage == 4 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Mode survie active par un administrateur.\n" );
			else if(iLanguage == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Modalita sopravvivenza abilitata da un amministratore.\n" );
			else g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Survival Manager] Survival mode enabled by an admin.\n" );
		}
	}
}

void Sound( int dropmode )
{
	// Anti-Ammo duplication
	g_EngineFuncs.CVarSetFloat( "mp_dropweapons", int( dropmode ) );

	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
	message.WriteString( "spk buttons/bell1" );
	message.End();
}

HUDTextParams SpawnCountHudText;

void CheckTime()
{
	if( flNoMoreVotes >= 1 )
		flNoMoreVotes = flNoMoreVotes - 1;
	
	if( blSurvivalIs )
		return;

	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(pPlayer is null )
			continue;

		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
		CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
		int iLanguage = int(ckLenguageIs.GetFloat());
		
		CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
		int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_survivaln_t").GetInteger();

		if( kvSpawnIs >= 0 )
		{
			if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
			{
				SpawnCountHudText.x = -1;
				SpawnCountHudText.y = -1;
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
				SpawnCountHudText.holdTime = 2;
				SpawnCountHudText.fxTime = 0;
				SpawnCountHudText.channel = int(flChannel);

				if(iLanguage == 1 ) g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "Reviviras en " + kvSpawnIs +" segundos\n" );
				else if(iLanguage == 2 ) g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "reviver em " + kvSpawnIs +" segundos\n" );
				else if(iLanguage == 3 ) g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "wiederbeleben " + kvSpawnIs +" Sekunden\n" );
				else if(iLanguage == 4 ) g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "revivre dans " + kvSpawnIs +" secondes\n" );
				else if(iLanguage == 5 ) g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "rivivere " + kvSpawnIs +" secondi\n" );
				else g_PlayerFuncs.HudMessage( pPlayer, SpawnCountHudText, "Respawn in " + kvSpawnIs +" seconds\n" );

				ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs - 1 );
				if( DebugMode )
					g_Game.AlertMessage( at_console, ""+pPlayer.pev.netname+" time "+kvSpawnIs+"\n" );
			}
			if( pPlayer.IsAlive() && kvSpawnIs != flRespawnDelay )
				ckvSpawns.SetKeyvalue("$i_survivaln_t", int( flRespawnDelay ) );
		}else if( kvSpawnIs <= 0 ){
			g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
			ckvSpawns.SetKeyvalue("$i_survivaln_t", int( flRespawnDelay ) );
		}
	}
}