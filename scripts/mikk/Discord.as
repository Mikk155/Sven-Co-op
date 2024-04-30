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

/*
    @prefix #include Discord
    @body #include "${1:../../}mikk/Discord"
    @description Utilidad utilizada para hacer que cualquier plugin pueda enviar un string a discord mediante el plugin DiscordBridge.
*/
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
