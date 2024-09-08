string ParseLanguage( JSon@ pJson, const string &in m_szValue, dictionary@ pReplacement = null )
{
    string szMessage = pJson.get( m_szValue + ":" + pJson.get( "LANGUAGE:BOT" ) );

    if( pReplacement !is null )
    {
        const array<string> strFrom = pReplacement.getKeys();

        for( uint i = 0; i < strFrom.length(); i++ )
            szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
    }

    return szMessage;
}