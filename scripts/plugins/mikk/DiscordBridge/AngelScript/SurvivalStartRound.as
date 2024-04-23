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

namespace SurvivalStartRound
{
    void MapStart()
    {
        if( pJson[ 'MESSAGES', {} ][ 'SurvivalStartRound', {} ][ 'enable', false ] && g_SurvivalMode.IsEnabled() )
        {
            if( g_SurvivalMode.IsActive() )
            {
                SurvivalStartRound();
            }
            else
            {
                g_Scheduler.SetTimeout( "SurvivalStartRound", g_SurvivalMode.GetDelayBeforeStart() );
            }
        }
    }

    void SurvivalStartRound()
    {
        FormatMessage( pJson[ 'MESSAGES', {} ][ 'SurvivalStartRound', {} ][ 'Started', {} ][ language, '' ] );
    }
}