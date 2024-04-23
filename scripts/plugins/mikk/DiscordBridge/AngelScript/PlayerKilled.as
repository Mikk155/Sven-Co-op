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

namespace PlayerKilled
{
    void Register()
    {
        g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @PlayerKilled::PlayerKilled );

        if( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'enable', false ] )
        {
            g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled::PlayerKilled );
        }
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer is null )
            return HOOK_CONTINUE;

        dictionary pReplacement;
        pReplacement["player"] = string( pPlayer.pev.netname );
        pReplacement["gib"] =
            ( iGib != GIB_ALWAYS
                ? array<string>( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'Gib' ] )[1]
                : array<string>( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'Gib' ] )[0]
        );

        if( pAttacker is null )
        {
            FormatMessage( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'died', {} ][ language, '' ], pReplacement );
        }
        else
        {
            if( pAttacker is pPlayer )
            {
                FormatMessage( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'suicide', {} ][ language, '' ], pReplacement );
            }
            else
            {
                if( pAttacker.IsPlayer() )
                {
                    pReplacement["killer"] = string( pAttacker.pev.netname );
                }
                else if( pAttacker.IsMonster() )
                {
                    CBaseMonster@ pMonster = cast<CBaseMonster@>( pAttacker );

                    if( !string( pMonster.m_FormattedName ).IsEmpty() )
                    {
                        pReplacement["killer"] = string( pMonster.m_FormattedName ) + " (" + string( pAttacker.pev.classname ) + ")";
                    }
                    else
                    {
                        pReplacement["killer"] = string( pAttacker.pev.classname ).Replace( 'monster', '' ).Replace( '_', ' ' );
                    }
                }
                else
                {
                    pReplacement["killer"] = string( pAttacker.pev.classname ).Replace( '_', ' ' );
                }

                FormatMessage( pJson[ 'MESSAGES', {} ][ 'PlayerKilled', {} ][ 'killed', {} ][ language, '' ], pReplacement );
            }
        }
        return HOOK_CONTINUE;
    }
}