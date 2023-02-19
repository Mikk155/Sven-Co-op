#include "../maps/mikk/game_text_custom"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nGithub: github.com/Mikk155"
        "\nAuthor: Gaftherman"
        "\nGithub: github.com/Gaftherman"
        "\nAuthor: Kmkz"
        "\nGithub: github.com/kmkz27"
        "\nDescription: Allow players to see messages in multiple languages if the mapper/scripter uses this feature."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\nDiscord: discord.gg/VsNnE3A7j8"
    );
    g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

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
    "Dutch",
    "Indonesian",
    "Romanian",
    "Turkish",
    "Albanian"
};

array<string> arstrHook =
{
    "idioma",
    "lenguaje",
    "lenguage",
    "language",
    "lingvo",
    "langue",
    "sprache",
    "linguaggio",
    "taal",
    "gjuhe",
    "dil",
    "limba",
    "jazyk",
    "bahasa"
};

void MapInit()
{
    game_text_custom::InitialiseAsPlugin();
}

void MapStart()
{
    string line, key, value, szPath = 'scripts/plugins/multi_language/' + string( g_Engine.mapname ) + '.txt';

    dictionary g_KeyValues;

    File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::READ );

    if( pFile is null or !pFile.IsOpen() )
    {
        g_Util.DebugMessage( 'Can not open ' + szPath );
        return;
    }
    g_Util.DebugMessage( 'Loaded ' + szPath );

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );

        if( line.Length() < 1 )
        {
            continue;
        }

        if( line[0] == '/' and line[1] == '/' )
        {
            g_Util.DebugMessage( 'Comment:' + line.Replace( '//', '' ) );
            continue;
        }

        if( line[0] == '{' or line[0] == '}' )
        {
            g_Util.DebugMessage( line );

            if( line[0] == '}' )
            {
                g_EntityFuncs.CreateEntity( 'multi_language', g_KeyValues, true );
                g_KeyValues.deleteAll();
            }
            continue;
        }

        key = line.SubString( 0, line.Find( '" "') );
        key.Replace( '"', '' );

        value = line.SubString( line.Find( '" "'), line.Length() );
        value.Replace( '" "', '' );
        value.Replace( '"', '' );

        g_KeyValues[ key ] = value;
        g_Util.DebugMessage( '"' + key + '" -> "' + value + '"' );
    }
    pFile.Close();
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
    CBasePlayer@ pPlayer = pParams.GetPlayer();
    const CCommand@ args = pParams.GetArguments();
    
    if( args.ArgC() >= 1 )
    {
        string A = args.Arg(0);

        for( uint ui = 0; ui < arstrHook.length(); ++ui )
        {
            if( A.ToLowercase() == arstrHook[ui] )
            {
                CreateMenu( pPlayer );
                break;
            }
        }
    }
    return HOOK_CONTINUE;
}

CTextMenu@ g_VoteMenu;

void CreateMenu( CBasePlayer@ pPlayer )
{
    @g_VoteMenu = CTextMenu( @MainCallback );

    g_VoteMenu.SetTitle( Title( g_Util.GetCKV( cast<CBaseEntity@>(pPlayer), "$s_language" ) ) );

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
        g_Util.SetCKV( cast<CBaseEntity@>(pPlayer), "$s_language", Choice.ToLowercase() );
        StoreLanguage( pPlayer, Choice.ToLowercase() );
        g_Util.Trigger( 'mlang_credits', pPlayer, pPlayer, USE_ON, 0.0f );
    }
}

void StoreLanguage( CBaseEntity@ pPlayer, const string& in Language = 'english' )
{
    // verify that its steamid doesn't exist in the file and write,  otherwhise RE write
    // Syntax:
    // STEAMID language
}

string GetLanguage( CBaseEntity@ pPlayer )
{
    // Verify that its steamid exist in the file and set its language as a custom keyvalue
    // "$s_" + language in line.
    return '';
}

string Title( string L )
{
    if( L == 'spanish' )return "Selecciona un lenguaje ";
    else if( L == 'spanish spain' )return "Selecciona un lenguaje ";
    else if( L == 'portuguese' )return "Selecione um idioma ";
    else if( L == 'german' )return "Wahle eine Sprache ";
    else if( L == 'french' )return "Selectionnez une langue ";
    else if( L == 'italian' )return "Seleziona una lingua ";
    else if( L == 'esperanto' )return "Elektu lingvon ";
    else if( L == 'czech' )return "Vyberte jazyk ";
    else if( L == 'dutch' )return "Selecteer een taal ";
    else if( L == 'indonesian' )return "Pilih bahasa ";
    else if( L == 'romanian' )return "Selectati o limba ";
    else if( L == 'turkish' )return "Bir dil sec ";
    else if( L == 'albanian' )return "Zgjidhni nje gjuhe ";
    return "Select a language ";
}