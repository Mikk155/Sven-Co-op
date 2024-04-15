//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

enum MKLANG
{
    /*
        ClientPrint -> HUD_PRINTTALK
    */
    CHAT = 0,
    /*
        PrintKeyBindingString
    */
    BIND,
    /*
        ClientPrint -> HUD_PRINTCENTER
    */
    CENTER,
    /*
        HudMessage Pass arguments in the json file.
        x = -1, y = -1, effect = 1, color = 255 255 255, color2 = 255 255 255, fadein = 0, fadeout = 1, hold = 1, fxtime = 1, channel = 8
    */
    HUDMSG,
    /*
        ClientPrint -> HUD_PRINTNOTIFY
    */
    NOTIFY,
    /*
        ClientPrint -> HUD_PRINTCONSOLE
    */
    CONSOLE,
}

namespace Language
{
    // This is bad but i can't make the external shared thing
    bool blhook = blHook();

    bool blHook()
    {
        g_Hooks.RemoveHook( Hooks::Player::ClientSay, @Language::ClientSay );
        g_Hooks.RemoveHook( Hooks::Player::ClientPutInServer, @Language::ClientPutInServer );

        return (
            g_Hooks.RegisterHook( Hooks::Player::ClientSay, @Language::ClientSay ) &&
            g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @Language::ClientPutInServer )
        );
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && g_Data.exists( Mikk.PlayerFuncs.GetSteamID( pPlayer ) ) )
        {
            SetLanguage( pPlayer, string( g_Data[ Mikk.PlayerFuncs.GetSteamID( pPlayer ) ] ) );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode ClientSay( SayParameters@ pParams )
    {
        CBasePlayer@ pPlayer = pParams.GetPlayer();
        const CCommand@ args = pParams.GetArguments();

        if( pPlayer is null || args.ArgC() <= 0 )
            return HOOK_CONTINUE;

        array<string> strHook = { "trans","localization",
        "lang","idioma","lenguaje","translate","lenguage","language",
        "lingvo","langue","sprache","linguaggio","taal",
        "gjuhe","dil","limba","jazyk","bahasa" };

        if( strHook.find( args[0].SubString( ( args[0][0] == '/' ? 1 : 0 ), args[0].Length() ) ) >= 0 )
        {
            if( args.ArgC() == 2 )
            {
                SetLanguage( pPlayer, args[1] );
            }
            else
            {
                OpenMenu( pPlayer );
            }
            return HOOK_HANDLED;
        }

        return HOOK_CONTINUE;
    }

    void SetLanguage( CBasePlayer@ pPlayer, string m_szLanguage )
    {
        if( pPlayer !is null )
        {
            g_Data[ Mikk.PlayerFuncs.GetSteamID( pPlayer ) ] = m_szLanguage;
            CustomKeyValue( pPlayer, '$s_language', m_szLanguage.ToLowercase() );
        }
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

    dictionary g_Data;

    CTextMenu@ g_VoteMenu;
    void OpenMenu( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && pPlayer.IsConnected() )
        {
            @g_VoteMenu = CTextMenu( @MainCallback );

            g_VoteMenu.SetTitle( 'Language:\\r' );

            for( uint ui = 0; ui < LanguageSupport.length(); ++ui )
            {
                g_VoteMenu.AddItem( LanguageSupport[ui] );
            }

            g_VoteMenu.Register();
            g_VoteMenu.Open( 25, 0, pPlayer );
        }
    }

    void MainCallback( CTextMenu@ CMenu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
    {
        if( pItem !is null && pPlayer !is null )
        {
            string Choice = pItem.m_szName;

            if( iSlot >= 1 && !Choice.IsEmpty() )
            {
                SetLanguage( pPlayer, Choice );
            }
        }
    }
}

class MKLanguage
{
    /*
        @prefix Mikk.Language.GetLanguage GetLanguage
        @body Mikk.Language
        Gets a language string from the given json value,
        pReplacement keys will be replaced with their values.
        note in the json string it have to be enclosed with two $
    */
    string GetLanguage( CBasePlayer@ pPlayer, json@ pJson, dictionary@ pReplacement = null )
    {
        string m_szLanguage = CustomKeyValue( pPlayer, "$s_language" );

        if( m_szLanguage == String::EMPTY_STRING || m_szLanguage == '' )
            m_szLanguage = "english";

        string m_szMessage = pJson[ m_szLanguage, pJson[ 'english', '' ] ];

        if( m_szLanguage == "spanish spain" && pJson[ m_szLanguage,'' ].IsEmpty() )
            m_szMessage = pJson[ 'spanish', pJson[ 'english','' ] ];
        else if( m_szLanguage == "spanish" && pJson[ m_szLanguage,'' ].IsEmpty() )
            m_szMessage = pJson[ 'spanish spain', pJson[ 'english','' ] ];

        if( pReplacement !is null )
        {
            const array<string> strFrom = pReplacement.getKeys();

            for( uint i = 0; i < strFrom.length(); i++ )
                m_szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
        }

        return m_szMessage;
    }

    /*
        @prefix Mikk.Language.PrintAll PrintAll Language
        @body Mikk.Language
        Prints a language string from the given json value,
        PrintType is the message type. see the enum
        pReplacement keys will be replaced with their values.
        note in the json string it have to be enclosed with two $
    */
    void PrintAll( json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() )
                Print( pPlayer, pJson, PrintType, pReplacement );
        }
    }

    /*
        @prefix Mikk.Language.PrintAll PrintAll Language
        @body Mikk.Language
        Prints a language string from the given json value,
        PrintType is the message type. see the enum
        pReplacement keys will be replaced with their values.
        note in the json string it have to be enclosed with two $
    */
    void Print( CBasePlayer@ pPlayer, json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null )
    {
        if( pPlayer is null || pJson is null )
            return;

        string m_szMessage = GetLanguage( pPlayer, pJson, pReplacement );

        if( m_szMessage.IsEmpty() || m_szMessage == '' )
            return;

        switch( PrintType )
        {
            case CHAT:
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, m_szMessage + '\n' );
                break;
            }
            case CENTER:
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCENTER, m_szMessage + '\n' );
                break;
            }
            case CONSOLE:
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, m_szMessage + '\n' );
                break;
            }
            case NOTIFY:
            {
                g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTNOTIFY, m_szMessage + '\n' );
                break;
            }
            case BIND:
            {
                g_PlayerFuncs.PrintKeyBindingString( pPlayer, m_szMessage + '\n' );
                break;
            }
            case HUDMSG:
            {
                HUDTextParams textParams;
                textParams.x = float( pJson[ 'x', -1 ] );
                textParams.y = float( pJson[ 'y', -1 ] );
                textParams.effect = pJson[ 'effect', 1 ];

                RGBA rgba = atorgba( pJson[ 'color', '255 255 255' ] );
                textParams.r1 = rgba.r;
                textParams.g1 = rgba.g;
                textParams.b1 = rgba.b;

                RGBA rgba2 = atorgba( pJson[ 'color2', '255 255 255' ] );
                textParams.r2 = rgba.r;
                textParams.g2 = rgba.g;
                textParams.b2 = rgba.b;

                textParams.fadeinTime = float( pJson[ 'fadein', 0 ] );
                textParams.fadeoutTime = float( pJson[ 'fadeout', 1 ] );
                textParams.holdTime = float( pJson[ 'hold', 1 ] );
                textParams.fxTime = float( pJson[ 'fxtime', 1 ] );
                textParams.channel = pJson[ 'channel', 8 ];

                g_PlayerFuncs.HudMessage( pPlayer, textParams, m_szMessage + '\n' );
                break;
            }
        }
    }
}