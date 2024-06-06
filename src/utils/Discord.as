namespace Discord
{
    const string name = 'DiscordBridge';

    json pJson;

    /*
        @prefix Discord Discord::language language
        @body Discord::language()
        @description Accede a la eleccion de lenguaje del operador del servidor.
    */
    const string language()
    {
        if( pJson.size() == 0 ) { pJson.load( 'plugins/mikk/DiscordBridge/DiscordBridge.json' ); }
        return pJson[ 'language', 'english' ];
    }

    /*
        @prefix Discord Discord::bridge Discord::print
        @body Discord::print( string szMessage, dictionary@ pReplacement = null )
        @description Envia un mensaje a el plugin DiscordBridge para que este se encargue de enviarlo a Discord.
        @description Si tienes un plugin con multiples lenguajes utiliza Discord::language() para saber que mensaje enviar.
        @description pReplacement son los argumentos a reemplazar en el string.
    */
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
                g_EntityFuncs.DispatchKeyValue( pDiscord.edict(), g_Module.GetModuleName(), szMessage );
            }
        }
    }
}
