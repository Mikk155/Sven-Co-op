enum MKLANG
{
    CHAT = 0,
    BIND,
    CENTER,
    /*@
        HudMessage Pass arguments in the json file.
        x = -1, y = -1, effect = 1, color = 255 255 255, color2 = 255 255 255, fadein = 0, fadeout = 1, hold = 1, fxtime = 1, channel = 8
    */
    HUDMSG,
    NOTIFY,
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
        if( pPlayer !is null && g_Data.exists( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) )
        {
            SetLanguage( pPlayer, string( g_Data[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] ) );
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
            g_Data[ g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ] = m_szLanguage;
            pPlayer.GetCustomKeyvalues().SetKeyvalue( '$s_language', m_szLanguage.ToLowercase() );
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

    /*
        @prefix Language Language::GetLanguage GetLanguage
        @body Language::GetLanguage( CBasePlayer@ pPlayer, json@ pJson, dictionary@ pReplacement = null )
        @description Retorna el mensaje correspondiente para este jugador
    */
    string GetLanguage( CBasePlayer@ pPlayer, json@ pJson, dictionary@ pReplacement = null )
    {
        string m_szLanguage = pPlayer.GetCustomKeyvalues().GetKeyvalue( "$s_language" ).GetString();

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
        @prefix Language Language::PrintAll PrintAll
        @body Language::PrintAll( json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null )
        @description Muestra un mensaje con el lenguaje correspondiente para cada jugador
    */
    void PrintAll( json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null, string szPrefix = '' )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() )
                Print( pPlayer, pJson, PrintType, pReplacement, szPrefix );
        }
    }

    /*
        @prefix Language Language::PrintAll PrintAll
        @body Language::PrintAll( json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null )
        @description Muestra un mensaje con el lenguaje correspondiente para este jugador
    */
    void Print( CBasePlayer@ pPlayer, json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null, string szPrefix = '' )
    {
        if( pPlayer is null || pJson is null )
            return;

        string m_szMessage = ( szPrefix != '' ? szPrefix + ' ' : '' ) + GetLanguage( pPlayer, pJson, pReplacement );

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
                textParams.x = float( pJson[ 'x' ] );
                textParams.y = float( pJson[ 'y' ] );
                textParams.effect = int( pJson[ 'effect' ] );

                RGBA rgba = RGBA( pJson[ 'color' ] );
                textParams.r1 = rgba.r;
                textParams.g1 = rgba.g;
                textParams.b1 = rgba.b;

                RGBA rgba2 = RGBA( pJson[ 'color2' ] );
                textParams.r2 = rgba.r;
                textParams.g2 = rgba.g;
                textParams.b2 = rgba.b;

                textParams.fadeinTime = float( pJson[ 'fadein' ] );
                textParams.fadeoutTime = float( pJson[ 'fadeout' ] );
                textParams.holdTime = float( pJson[ 'hold' ] );
                textParams.fxTime = float( pJson[ 'fxtime' ] );
                textParams.channel = int( pJson[ 'channel' ] );

                g_PlayerFuncs.HudMessage( pPlayer, textParams, m_szMessage + '\n' );
                break;
            }
        }
    }
}