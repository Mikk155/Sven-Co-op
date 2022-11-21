/*
    DOWNLOAD:
    https://github.com/Mikk155/Multi-Language-Plugin

    INSTALL:

    "plugin"
    {
        "name" "multi_language"
        "script" "mikk/multi_language"
    }
*/

#include "../../maps/mikk/utils"
#include "../../maps/mikk/game_text_custom"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk, Gaftherman, Kmkz" );
    g_Module.ScriptInfo.SetContactInfo
    (
        "Mikk: https://github.com/Mikk155
        Gaftherman: https://github.com/Gaftherman
        Kmkz: https://github.com/kmkz27
        Discord: https://discord.gg/VsNnE3A7j8 \n"
    );

    // Used to let players choose their language choice and store them.
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

dictionary g_PlayerKeepLenguage;

class PlayerKeepLenguageData
{
    int lenguage;
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
        UTILS::TriggerMode( "MLANGUAGE_CREDITS", pPlayer, 5.1f );
    }
    return HOOK_CONTINUE;
}

void StoreLanguage( CBasePlayer@ pPlayer )
{
    string SteamID = g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() );
    PlayerKeepLenguageData pData;
    pData.lenguage = UTILS::GetCKV( pPlayer, "$f_lenguage" );
    g_PlayerKeepLenguage[SteamID] = pData;
}

void PlayerLoadLenguage( int &in iIndex, string &in SteamID )
{
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(iIndex);

    if( pPlayer !is null )
    {
        PlayerKeepLenguageData@ pData = cast<PlayerKeepLenguageData@>(g_PlayerKeepLenguage[SteamID]);
        pPlayer.GetCustomKeyvalues().SetKeyvalue( "$f_lenguage", int(pData.lenguage) );
    }
}

void MapInit()
{
    // Register the entity before creating them.
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseGameTextCustom", "multi_language" );

	if( g_CustomEntityFuncs.IsCustomEntity( "multi_language" ) )
	{
		// Create the localizated texts
		UTILS::LoadRipentFile( "scripts/plugins/ripent/translations/" + string( g_Engine.mapname ) + ".ent" );
		// Create the text that this plugin uses to tell messages.
		UTILS::LoadRipentFile( "scripts/plugins/mikk/multi_language.ent" );
	}
}

// Array of ClientSay arguments to open the menu
const array<string> AStrLangmenu =
{
    "language",
    "lenguage",
    "translate",
    "idioma",
    "lenguaje",
    "linga",
    "lingvo",
    "sprache",
    "langue",
    "linguaggio"
};

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();

    for(uint i = 0; i < AStrLangmenu.length(); i++)
    {
        if( args.ArgC() == 1 && args.Arg(0) == AStrLangmenu[i] )
        {
            CreateMenu( pPlayer );
            break;
        }
    }
    return HOOK_CONTINUE;
}

CTextMenu@ g_VoteMenu;

void CreateMenu( CBasePlayer@ pPlayer )
{
    // Get the players language choice as a int
    int i = UTILS::GetCKV( pPlayer, "$f_lenguage" );

    @g_VoteMenu = CTextMenu( @MainCallback );

    // Show the proper tittle depending its language choice
    g_VoteMenu.SetTitle(
        ( i == 1 ) ? "Elige un lenguaje" :
        ( i == 2 ) ? "Selecione um idioma" :
        ( i == 3 ) ? "Wahle eine Sprache" :
        ( i == 4 ) ? "Selectionnez une langue" :
        ( i == 5 ) ? "Seleziona una lingua" :
        ( i == 6 ) ? "Elektu lingvon" : "Select a language"
    );

    // can change colors in the menu? im pretty sure i have seen that. so the languages that are not initialized appear in red -TODO
    g_VoteMenu.AddItem( "English" );
    g_VoteMenu.AddItem( "Spanish" );
    g_VoteMenu.AddItem( "Portuguese" );
    g_VoteMenu.AddItem( "German" );
    g_VoteMenu.AddItem( "French" );
    g_VoteMenu.AddItem( "Italian" );
    g_VoteMenu.AddItem( "Esperanto" );
    g_VoteMenu.Register();
    g_VoteMenu.Open( 25, 0, pPlayer );
}

void MainCallback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
{
    if( pItem !is null )
    {
        int i = 0;
        string sChoice = pItem.m_szName;
        if( sChoice == "English" ) i = 0;
        else if( sChoice == "Spanish" ) i = 1;
        else if( sChoice == "Portuguese" ) i = 2;
        else if( sChoice == "German" ) i = 3;
        else if( sChoice == "French" ) i = 4;
        else if( sChoice == "Italian" ) i = 5;
        else if( sChoice == "Esperanto" ) i = 6;

        pPlayer.GetCustomKeyvalues().SetKeyvalue( "$f_lenguage", i );
        UTILS::TriggerMode( "MLANGUAGE_SET_LANGUAGE#1", pPlayer, 0.1f );
        StoreLanguage( pPlayer );
    }
}