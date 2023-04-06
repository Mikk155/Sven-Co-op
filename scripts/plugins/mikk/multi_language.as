#include "../../maps/mikk/game_text_custom"

array<string> LanguageSupport =
{
	"English",
	"Spanish",
	"Spanish Spain",
	"Portuguese",
	"German",
	"French",
	"Italian",
	"Esperanto",
	"Czech",
	"Dutch","
	Indonesian",
	"Romanian",
	"Turkish",
	"Albanian"
};
	
CTextMenu@ g_VoteMenu;

array<string> arstrHook = {"trans","localization","lang","idioma","lenguaje","lenguage","language","lingvo","langue","sprache","linguaggio","taal","gjuhe","dil","limba","jazyk","bahasa"};

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk & Gaftherman" );
	g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Module.ScriptInfo.SetContactInfo( "discord.gg/VsNnE3A7j8" );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

void MapInit()
{
    game_text_custom::MapInit();
}

void MapStart()
{
	g_Util.LoadEntities( 'scripts/plugins/multi_language/' + string( g_Engine.mapname ) + '.txt', 'multi_language' );
	g_Util.LoadEntities( 'scripts/plugins/multi_language/multi_language.txt', 'multi_language' );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();
    
    if( args.ArgC() >= 1 )
    {
		string Arg0 = args.Arg(0);

        for( uint ui = 0; ui < arstrHook.length(); ++ui )
        {
            if( Arg0.ToLowercase().EndsWith( arstrHook[ui] ) )
            {
                CreateMenu( pPlayer );
                break;
            }
        }
    }
    return HOOK_CONTINUE;
}

void CreateMenu( CBasePlayer@ pPlayer )
{
    @g_VoteMenu = CTextMenu( @MainCallback );

    g_VoteMenu.SetTitle( Title( g_Util.GetCKV( pPlayer, "$s_language" ) ) + ' ' );

	for( uint ui = 0; ui < LanguageSupport.length(); ++ui )
	{
		g_VoteMenu.AddItem( LanguageSupport[ui] );
	}
    g_VoteMenu.Register();
    g_VoteMenu.Open( 25, 0, pPlayer );
}

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
    if( pItem !is null )
    {
        string Choice = pItem.m_szName;
        g_Util.SetCKV( pPlayer, "$s_language", Choice.ToLowercase() );
        g_Util.Trigger( 'mlang_credits', pPlayer, pPlayer, USE_ON, 0.0f );
    }
}

string Title( string L )
{
	if( L == 'spanish' )
	{
		return 'Selecciona un lenguaje';
	}
    else if( L == 'spanish spain' )
	{
		return 'Selecciona un lenguaje';
	}
    else if( L == 'portuguese' )
	{
		return 'Selecione um idioma';
	}
    else if( L == 'german' )
	{
		return 'Wahle eine Sprache';
	}
    else if( L == 'french' )
	{
		return 'Selectionnez une langue';
	}
    else if( L == 'italian' )
	{
		return 'Seleziona una lingua';
	}
    else if( L == 'esperanto' )
	{
		return 'Elektu lingvon';
	}
    else if( L == 'czech' )
	{
		return 'Vyberte jazyk';
	}
    else if( L == 'dutch' )
	{
		return 'Selecteer een taal';
	}
    else if( L == 'indonesian' )
	{
		return 'Pilih bahasa';
	}
    else if( L == 'romanian' )
	{
		return 'Selectati o limba';
	}
    else if( L == 'turkish' )
	{
		return 'Bir dil sec';
	}
    else if( L == 'albanian' )
	{
		return 'Zgjidhni nje gjuhe';
	}
    return 'Select a language';
}

dictionary keyvalues;

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
	string lenguage;
}

HookReturnCode MapChange()
{
	for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

		if( pPlayer !is null )
		{
			PlayerKeepLenguageData pData;
			pData.lenguage = g_Util.GetCKV( pPlayer, '$s_language' );
			g_PlayerKeepLenguage[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] = pData;
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
{
	if( pPlayer !is null )
	{
		string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );

		if( g_PlayerKeepLenguage.exists(SteamID) )
		{
			PlayerLoadLenguage( g_EngineFuncs.IndexOfEdict( pPlayer.edict() ), SteamID );
		}
		else
		{
			PlayerKeepLenguageData pData;
			pData.lenguage = g_Util.GetCKV( pPlayer, '$s_language' );
			g_PlayerKeepLenguage[SteamID] = pData;
		}
        g_Util.Trigger( 'mlang_information', pPlayer, pPlayer, USE_ON, 5.0f );
	}
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
{
	if (pPlayer !is null )
	{
		PlayerKeepLenguageData pData;
		pData.lenguage = g_Util.GetCKV( pPlayer, '$s_language' );
		g_PlayerKeepLenguage[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] = pData;   
	}
    return HOOK_CONTINUE;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
	CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

	if( pPlayer !is null )
	{
		PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);
		g_Util.SetCKV( pPlayer, '$s_language', pData.lenguage );
	}
}