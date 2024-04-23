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

void FormatMessage( string szMessage, dictionary@ pReplacement = null )
{
    if( pReplacement !is null )
    {
        const array<string> strFrom = pReplacement.getKeys();

        for( uint i = 0; i < strFrom.length(); i++ )
        {
            szMessage.Replace( "$" + strFrom[i] + "$", string( pReplacement[ strFrom[i] ] ) );
        }
    }

    if( g_Reflection[ pJson[ 'method', 'fileload' ] + '::ToDiscord' ] !is null )
        g_Reflection[ pJson[ 'method', 'fileload' ] + '::ToDiscord' ].Call( szMessage );
}
