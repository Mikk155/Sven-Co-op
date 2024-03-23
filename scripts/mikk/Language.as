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

enum PRINT_LANGUAGE
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
    void PrintAll( json@ pJson, const string &in m_szKey, PRINT_LANGUAGE PrintType = CHAT, dictionary@ pReplacement = null )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() )
                Print( pPlayer, pJson, m_szKey, PrintType, pReplacement );
        }
    }

    void Print( CBasePlayer@ pPlayer, json@ pJson, const string &in m_szKey, PRINT_LANGUAGE PrintType = CHAT, dictionary@ pReplacement = null )
    {
        if( pPlayer is null || m_szKey.IsEmpty() || pJson is null )
            return;

        string m_szLanguage = CustomKeyValue( pPlayer, "$s_language" );

        if( m_szLanguage == String::EMPTY_STRING || m_szLanguage == '' )
            m_szLanguage = "english";

        m_szLanguage.ToUppercase();

        string m_szMessage = pJson[ m_szLanguage, pJson[ 'ENGLISH' ] ];

        if( m_szMessage.IsEmpty() )
            return;

        if( pReplacement !is null )
        {
            const array<string> strFrom = pReplacement.getKeys();

            for( uint i = 0; i < strFrom.length(); i++ )
                m_szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
        }

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
                g_PlayerFuncs.PrintKeyBindingString( pPlayer, m_szMessage + '\n' );
                break;
            }
        }
    }
}