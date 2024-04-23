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

namespace MapStarted
{
    string mapname;

    void MapStart()
    {
        if( pJson[ 'MESSAGES', {} ][ 'MapStart', {} ][ 'enable', false ] && mapname != g_Engine.mapname )
        {
            FormatMessage( pJson[ 'MESSAGES', {} ][ 'MapStart', {} ][ 'start', {} ][ language, '' ], { { 'map', string( g_Engine.mapname ) } } );
        }

        mapname = g_Engine.mapname;
    }
}
