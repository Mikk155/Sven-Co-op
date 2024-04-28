namespace Discord
{
    string name = 'DiscordBridge';

    json pJson;

    string language()
    {
        if( pJson.size() == 0 ) { pJson.load( 'plugins/mikk/DiscordBridge/DiscordBridge.json' ); }
        return pJson[ 'language', 'english' ];
    }

    void print( string szMessage, dictionary@ pReplacement = null )
    {
        if( g_CustomEntityFuncs.IsCustomEntity( name ) )
        {
            if( pReplacement !is null )
            {
                const array<string> strFrom = pReplacement.getKeys();

                for( uint i = 0; i < strFrom.length(); i++ )
                    szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
            }

            CBaseEntity@ pDiscord = g_EntityFuncs.FindEntityByClassname( null, name );

            if( pDiscord !is null )
            {
                g_EntityFuncs.DispatchKeyValue( pDiscord.edict(), 'catch', szMessage );
            }
        }
    }
}
