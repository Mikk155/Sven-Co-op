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
    CHAT = 0,
    BIND,
    CENTER,
    HUDMSG,
    NOTIFY,
    CONSOLE,
}

class MKLanguage
{
    string GetLanguage( CBasePlayer@ pPlayer, json@ pJson, dictionary@ pReplacement = null )
    {
        string m_szLanguage = CustomKeyValue( pPlayer, "$s_language" );

        if( m_szLanguage == String::EMPTY_STRING || m_szLanguage == '' )
            m_szLanguage = "english";

        string m_szMessage = pJson[ m_szLanguage, pJson[ 'english' ] ];

        if( pReplacement !is null )
        {
            const array<string> strFrom = pReplacement.getKeys();

            for( uint i = 0; i < strFrom.length(); i++ )
                m_szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
        }

        return m_szMessage;
    }

    void PrintAll( json@ pJson, MKLANG PrintType = CHAT, dictionary@ pReplacement = null )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() )
                Print( pPlayer, pJson, PrintType, pReplacement );
        }
    }

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