/*
	simple script that move AFK people to spec mode and also lets you manually join spec mode if want to be afk

	"plugin"
	{
		"name" "AfkManager"
		"script" "mikk/AfkManager"
	}
*/

// Starts of customizable zone

// Choose a channel (1-8) of your preference for this plugin uses messages.
float flChannel = 8;

// Maximun time players can be afk before joining spectator mode. 0 = disable feature
const int AFKMaxTime = 300;

// End of customizable zone

#include "../../maps/mikk/entities/utils"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

bool ExcludedMapList()
{
	string szExcludedMapList = "scripts/plugins/mikk/AfkManager.txt";
	File@ pFile = g_FileSystem.OpenFile( szExcludedMapList, OpenFile::READ );

	if( pFile is null || !pFile.IsOpen() )
	{
		g_EngineFuncs.ServerPrint("WARNING! Failed to open "+szExcludedMapList+"\n");
		return false;
	}

	string strMap = g_Engine.mapname;
	strMap.ToLowercase();

	string line;

	while( !pFile.EOFReached() )
	{
		pFile.ReadLine( line );
		line.Trim();

		if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '#' || line[0] == ';' )
			continue;

		line.ToLowercase();

		if( strMap == line )
		{
			pFile.Close();
			return true;
		}

		if( line.EndsWith("*", String::CaseInsensitive) )
		{
			line = line.SubString(0, line.Length()-1);

			if( strMap.Find(line) != Math.SIZE_MAX )
			{
				pFile.Close();
				return true;
			}
		}
	}

	pFile.Close();

	return false;
}

void MapInit()
{
	g_Scheduler.SetInterval( "AFKThink", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES);
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

dictionary dictSteamsID;
HUDTextParams HuddMessager;

void AFKThink()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if(pPlayer is null or !pPlayer.IsConnected() )
			continue;

		string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		if( dictSteamsID.exists(SteamID) )
		{
			AFKMUTILS::Messager( pPlayer, 4 );
			AFKMUTILS::GetObserver( pPlayer );
            pPlayer.pev.nextthink = ( g_Engine.time + 2.0 );
		}

		if( ExcludedMapList() || AFKMaxTime == 0 )
			return;

		int iafktimer = MLAN::GetCKV(pPlayer, "$i_afktimer");

		if( pPlayer.IsAlive() && !pPlayer.IsMoving() )
		{
			pPlayer.GetCustomKeyvalues().SetKeyvalue("$i_afktimer", iafktimer - 1 );

			if( iafktimer == 1 && !pPlayer.GetObserver().IsObserver() )
			{
				dictSteamsID[SteamID] = @pPlayer;
				AFKMUTILS::Messager( pPlayer, 0 );
			}
		}

		if( pPlayer.IsMoving() || iafktimer <= 0 )
		{
			pPlayer.GetCustomKeyvalues().SetKeyvalue("$i_afktimer", AFKMaxTime );
		}

		if( iafktimer < 11 && iafktimer >= 1 )
		{
			AFKMUTILS::Messager( pPlayer, 5 );
		}
	}
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	if( args.ArgC() == 1 && args.Arg(0) == "/afk" )
		ToggleAfk( pPlayer );
	if( args.ArgC() == 1 && args.Arg(0) == "afk" or args.Arg(0) == "brb" )
		AFKMUTILS::Messager( pPlayer, 3 );

	return HOOK_CONTINUE;
}

void ToggleAfk( CBasePlayer@ pPlayer )
{
	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	if( dictSteamsID.exists(SteamID) )
	{
		dictSteamsID.delete(SteamID);
		AFKMUTILS::Messager( pPlayer, 1 );
	}
	else
	{
		dictSteamsID[SteamID] = @pPlayer;
		AFKMUTILS::Messager( pPlayer, 0 );
	}
}

namespace AFKMUTILS
{
	void GetObserver( CBasePlayer@ pPlayer )
	{
		pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles ,false );
		
		if( g_PlayerFuncs.GetNumPlayers() == g_Engine.maxClients )
		{
			Messager( pPlayer, 2 );

			NetworkMessage msg(MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict());
				msg.WriteString( "disconnect" );
			msg.End();
		}
	}
	
	void Messager( CBasePlayer@ pActivator, int mode )
	{
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if(pPlayer is null or !pPlayer.IsConnected() )
				continue;

			int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

			/*
				Languages?
				0 = English
				1 = Spanish
				2 = PT/BR
				3 = German
				4 = French
				5 = Italian
				6 = Esperanto
			*/

			if( mode == 0 )
			{
				if(iLanguage == 1 ){ Messager2("Esta en modo AFK.", pActivator, pPlayer );}
				else if(iLanguage == 2 ){ Messager2("Esta no modo AFK.", pActivator, pPlayer );}
				else if(iLanguage == 3 ){ Messager2("Ist im AFK-Modus.", pActivator, pPlayer );}
				else if(iLanguage == 4 ){ Messager2("Est en mode AFK.", pActivator, pPlayer );}
				else if(iLanguage == 5 ){ Messager2("E in modalita AFK.", pActivator, pPlayer );}
				else if(iLanguage == 6 ){ Messager2("Estas en AFK-regimo.", pActivator, pPlayer );}
				else{ Messager2("Is in AFK mode.", pActivator, pPlayer );}
			}
			else if( mode == 1)
			{
				if(iLanguage == 1 ){ Messager2("Salio del modo AFK.", pActivator, pPlayer );}
				else if(iLanguage == 2 ){ Messager2("Saiu do modo AFK.", pActivator, pPlayer );}
				else if(iLanguage == 3 ){ Messager2("Verlassen Sie den AFK-Modus.", pActivator, pPlayer );}
				else if(iLanguage == 4 ){ Messager2("A quitte le mode AFK.", pActivator, pPlayer );}
				else if(iLanguage == 5 ){ Messager2("Ha lasciato la modalità AFK.", pActivator, pPlayer );}
				else if(iLanguage == 6 ){ Messager2("Forlasis la AFK-regimon.", pActivator, pPlayer );}
				else{ Messager2("Left AFK mode.", pActivator, pPlayer );}
			}
			else if( mode == 2)
			{
				if(iLanguage == 1 ){ Messager2("Fue expulsado por estar AFK en servidor lleno.", pActivator, pPlayer );}
				else if(iLanguage == 2 ){ Messager2("foi expulso por ser AFK em servidor completo.", pActivator, pPlayer );}
				else if(iLanguage == 3 ){ Messager2("wurde gekickt, weil er AFK auf einem vollen Server war.", pActivator, pPlayer );}
				else if(iLanguage == 4 ){ Messager2("a ete expulse pour avoir ete AFK sur un serveur complet.", pActivator, pPlayer );}
				else if(iLanguage == 5 ){ Messager2("e stato espulso perche AFK su un server completo.", pActivator, pPlayer );}
				else if(iLanguage == 6 ){ Messager2("estis piedbatita por esti AFK sur plena servilo.", pActivator, pPlayer );}
				else{ Messager2("was kicked for being AFK on a full server.", pActivator, pPlayer );}
			}
			else if( mode == 3)
			{
				if(iLanguage == 1 ){ Messager3("Escribe /afk para unirte al modo espectador", pActivator );}
				else if(iLanguage == 2 ){ Messager3("Digite /afk para entrar no modo espectador", pActivator );}
				else if(iLanguage == 3 ){ Messager3("Geben Sie /afk ein, um dem Zuschauermodus beizutreten", pActivator );}
				else if(iLanguage == 4 ){ Messager3("Tapez /afk pour rejoindre le mode spectateur", pActivator );}
				else if(iLanguage == 5 ){ Messager3("Digita /afk per entrare in modalita spettatore", pActivator );}
				else if(iLanguage == 6 ){ Messager3("Tajpu /afk por aligi al spektantregimo", pActivator );}
				else{ Messager3("say /afk to join spectator mode", pActivator );}
			}
			else if( mode == 4)
			{
				if(iLanguage == 1 ){ Messager4("Escriba '/afk' para salir del modo 'Lejos del teclado'", pActivator );}
				else if(iLanguage == 2 ){ Messager4("Digite '/afk' para sair do modo 'Longe do teclado'", pActivator );}
				else if(iLanguage == 3 ){ Messager4("Geben Sie '/afk' ein, um den Modus zu verlassen 'Nicht am Computer'", pActivator );}
				else if(iLanguage == 4 ){ Messager4("Tapez '/afk' pour quitter le mode 'loin du clavier'", pActivator );}
				else if(iLanguage == 5 ){ Messager4("Pronuncia '/afk' per uscire dalla modalita 'Lontano dalla tastiera'", pActivator );}
				else if(iLanguage == 6 ){ Messager4("Tajpu '/afk' por eliri regimon 'For de Klavaro'", pActivator );}
				else{ Messager4("Say '/afk' for exiting 'Away From Keyboard' mode.", pActivator );}
			}
			else if( mode == 5)
			{
				int iafktimer = MLAN::GetCKV(pPlayer, "$i_afktimer");
				
				if(iLanguage == 1 ){ Messager4("Vas a entrar al modo-AFK en "+iafktimer+" segundos.\n", pPlayer );}
				else if(iLanguage == 2 ){ Messager4("Voce ingressara no AFK-Mode em "+iafktimer+" segundos.\n", pPlayer );}
				else if(iLanguage == 3 ){ Messager4("Sie treten dem AFK-Modus bei "+iafktimer+" sekunden.\n", pPlayer );}
				else if(iLanguage == 4 ){ Messager4("Vous rejoindrez AFK-Mode dans "+iafktimer+" secondes.\n", pPlayer );}
				else if(iLanguage == 5 ){ Messager4("Entrerai in modalita AFK in "+iafktimer+" secondi.\n", pPlayer );}
				else if(iLanguage == 6 ){ Messager4("Vi aligos al AFK-Mode "+iafktimer+" sekundoj.\n", pPlayer );}
				else{ Messager4("You will join AFK-Mode in "+iafktimer+" seconds.\n", pPlayer );}
			}
		}
	}
	
	void Messager2( const string Message, CBasePlayer@ pActivator, CBasePlayer@ pPlayer )
	{
		string SteamID = g_EngineFuncs.GetPlayerAuthId(pActivator.edict());
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AFK-Manager] ( "+SteamID+ " ) " + pActivator.pev.netname +" "+ Message +"\n" );
	}
	
	void Messager3( const string Message, CBasePlayer@ pPlayer )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[AFK-Manager] "+ Message +".\n" );
	}
	
	void Messager4( const string Message, CBasePlayer@ pPlayer )
	{
		HuddMessager.x = -1;
		HuddMessager.y = 0.80;
		HuddMessager.effect = 0;
		HuddMessager.r1 = RGBA_SVENCOOP.r;
		HuddMessager.g1 = RGBA_SVENCOOP.g;
		HuddMessager.b1 = RGBA_SVENCOOP.b;
		HuddMessager.a1 = 0;
		HuddMessager.r2 = RGBA_SVENCOOP.r;
		HuddMessager.g2 = RGBA_SVENCOOP.g;
		HuddMessager.b2 = RGBA_SVENCOOP.b;
		HuddMessager.a2 = 0;
		HuddMessager.fadeinTime = 0; 
		HuddMessager.fadeoutTime = 0.25;
		HuddMessager.holdTime = 1;
		HuddMessager.fxTime = 0;
		HuddMessager.channel = int(flChannel);
		g_PlayerFuncs.HudMessage(pPlayer, HuddMessager, "[AFK-Manager] "+ Message +"\n" );
	}
}