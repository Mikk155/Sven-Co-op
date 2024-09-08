enum PRINT_LANGUAGE
{
    CHAT = 0,
    BIND,
    CENTER,
    HUDMSG,
    NOTIFY,
}

class MKLanguage
{
    void PrintAll( JSon@ pJson, const string &in m_szKey, PRINT_LANGUAGE PrintType = CHAT, dictionary@ pReplacement = null )
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null && pPlayer.IsConnected() )
                Print( pPlayer, pJson, m_szKey, PrintType, pReplacement );
        }
    }

    void Print( CBasePlayer@ pPlayer, JSon@ pJson, const string &in m_szKey, PRINT_LANGUAGE PrintType = CHAT, dictionary@ pReplacement = null )
    {
        if( pPlayer is null || m_szKey.IsEmpty() || pJson is null )
            return;

        string m_szLanguage = CustomKeyValue( pPlayer, "$s_language" );

        if( m_szLanguage == String::EMPTY_STRING )
            m_szLanguage = "english";

        m_szLanguage.ToUppercase();

        string m_szMessage = pJson.get( m_szLanguage + ":" + m_szKey );

        if( m_szMessage.IsEmpty() )
            m_szMessage = pJson.get( m_szKey + ":ENGLISH" );

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
        }
    }
}