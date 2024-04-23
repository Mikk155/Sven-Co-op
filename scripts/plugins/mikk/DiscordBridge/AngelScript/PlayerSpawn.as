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

namespace PlayerSpawn
{
    void Register()
    {
        g_Hooks.RemoveHook( Hooks::Player::PlayerSpawn, @PlayerSpawn::PlayerSpawn );

        if( pJson[ 'MESSAGES', {} ][ 'PlayerSpawn', {} ][ 'enable', false ] )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn::PlayerSpawn );
        }
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        FormatMessage( pJson[ 'MESSAGES', {} ][ 'PlayerSpawn', {} ][ 'spawned', {} ][ language, '' ], { { 'player', string( pPlayer.pev.netname ) } } );

        return HOOK_CONTINUE;
    }
}

