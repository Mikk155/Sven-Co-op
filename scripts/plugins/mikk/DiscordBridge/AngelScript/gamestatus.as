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

namespace gamestatus
{
    void CreateJson()
    {
        string szBuffer
        = '{'
        +       '"hostname": "$hostname$",'
        +       '"color": $color$,'
        +       '"campos":'
        +       '{'
        +           '"$k_players$": {'
        +               '"valor": "$v_players$",'
        +               '"inline": true'
        +           '},'
        +           '"$k_survival$": {'
        +               '"valor": "$v_survival$",'
        +               '"inline": true'
        +           '}'
        +       '}'
        + '}';

        json msg = pJson[ 'MESSAGES', {} ][ 'Discord', {} ];

        dictionary pData;
        pData[ 'hostname' ] = g_EngineFuncs.CVarGetString( 'hostname' );
        pData[ 'color' ] = pJson[ 'status', {} ][ 'color', '16711680' ];

        pData[ 'k_players' ] = msg[ 'Players', {} ][ language, '' ];
        pData[ 'v_players' ] = string( g_PlayerFuncs.GetNumPlayers() ) + '/' + g_Engine.maxClients;

        bool b;

        b = g_SurvivalMode.MapSupportEnabled();
        pData[ 'k_survival' ] = ( b ? msg[ 'survival', {} ][ 'language', '' ] : '' );
        pData[ 'v_survival' ] = ( b ? string( GetCheckpoints() ) + ' ' + msg[ 'checkpoints', {} ][ 'language', '' ] : '' );

        szBuffer = szBuffer.Replace( '\\n', ' ' );

        FormatMessage( szBuffer, pData, true );
    }

    int GetCheckpoints()
    {
        int i = 0;
        CBaseEntity@ pCheckPoint = null;
        while( ( @pCheckPoint = g_EntityFuncs.FindEntityByClassname( pCheckPoint, 'point_checkpoint' ) ) !is null )
            i++;
        return i;
    }
}

