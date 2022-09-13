void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk & Gaftherman" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155 | https://github.com/Gaftherman" );

	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary keyvalues;

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
	int lenguage;
}

HookReturnCode MapChange()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer is null or !pPlayer.IsConnected() )
			continue;

		string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

		CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
        int iLanguage = int(ckLenguageIs.GetFloat());

		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
	}

	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

	string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
	int iLanguage = int(ckLenguageIs.GetFloat());
		
	if( g_PlayerKeepLenguage.exists(SteamID) )
	{
        PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict(pPlayer.edict()), SteamID );
	}
    else
    {
		PlayerKeepLenguageData pData;
		pData.lenguage = iLanguage;
		g_PlayerKeepLenguage[SteamID] = pData;
    }
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	if(pPlayer is null)
		return HOOK_CONTINUE;

    string SteamID = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
    CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
    int iLanguage = int(ckLenguageIs.GetFloat());

    PlayerKeepLenguageData pData;
	pData.lenguage = iLanguage;
	g_PlayerKeepLenguage[SteamID] = pData;   

    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

	if( pPlayer is null )
		return;

	PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);

	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	ckLenguage.SetKeyvalue("$f_lenguage", int(pData.lenguage));
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if( args.ArgC() == 1 && args.Arg(0) == "language" or args.Arg(0) == "idioma" or args.Arg(0) == "trans" )
	{
		CreateMenu( pPlayer );
	}
	
	return HOOK_CONTINUE;
}

// vote taked from Duk0
// https://github.com/Duk0/AngelScript-SvenCoop/blob/master/plugins/AdminVote.as

CTextMenu@ g_VoteMenu;

void CreateMenu(CBasePlayer@ pPlayer)
{
	@g_VoteMenu = CTextMenu( @MainCallback );
	g_VoteMenu.SetTitle( "Choose Language\n" );
	g_VoteMenu.AddItem( "English" );
	g_VoteMenu.AddItem( "Spanish" );
	g_VoteMenu.AddItem( "Portuguese" );
	g_VoteMenu.AddItem( "German" );
	g_VoteMenu.AddItem( "French" );
	g_VoteMenu.AddItem( "Italian" );
	g_VoteMenu.AddItem( "Esperanto" );
	g_VoteMenu.Register();
	g_VoteMenu.Open( 15, 0, pPlayer );
}

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
	int iLanguage = int(ckLenguageIs.GetFloat());
	
	if( pItem !is null )
	{
		string sChoice = pItem.m_szName;
		if( sChoice == "English" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 0 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multi-Language] Now will show maps messages in english.\n" );
		}
		else if( sChoice == "Spanish" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 1 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multiples idiomas] Ahora mostrara mensajes de mapas en espaniol." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Algunos caracteres no se mostraran por limitaciones." );
		}
		else if( sChoice == "Portuguese" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 2 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multi-Language] Agora mostrara mensagens de mapas em Portugues." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Alguns caracteres nao serao mostrados por limitacoes." );
		}
		else if( sChoice == "German" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 3 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multi-Language] Zeigt Kartennachrichten jetzt auf Deutsch an." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Einige Zeichen werden aufgrund von Einschrankungen nicht angezeigt." );
		}
		else if( sChoice == "French" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 4 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multilingue] Affichera desormais les messages cartographiques en francaise." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Certains caracteres ne seront pas affiches en raison des limitations." );
		}
		else if( sChoice == "Italian" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 5 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multilingua] Ora mostrera i messaggi delle mappe in italiano." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Alcuni caratteri non verranno mostrati per limitazioni." );
		}
		else if( sChoice == "Esperanto" )
		{
			ckLenguage.SetKeyvalue("$f_lenguage", 6 );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "[Multlingva] Nuud kuvab kaarditeateid esperanto keeles." );
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Monda tahemarki piirangute tottu ei kuvata." );
		}
	}
}