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

namespace chatbridge
{
    namespace PlayerKilled
    {
        void PluginInit()
        {
            if( JsonLog[ 'player killed', false ] )
            {
                g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @chatbridge::PlayerKilled::PlayerKilled );
            }
        }

        HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
        {
            if( pPlayer !is null )
            {
                dictionary pReplacement;
                pReplacement["name"] = string( pPlayer.pev.netname );

                if( pAttacker is null )
                {
                    g_Chatbridge.Discord.print( JsonLang[ 'player_die','' ], pReplacement );
                }
                else
                {
                    if( pAttacker is pPlayer )
                    {
                        g_Chatbridge.Discord.print( JsonLang[ 'player_suicide','' ], pReplacement );
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
                                pReplacement["killer"] = string( pAttacker.pev.classname );
                            }
                        }
                        pReplacement["killer"] = ( pAttacker.IsPlayer() ? string( pAttacker.pev.netname ) : string( pAttacker.pev.classname ) );
                        g_Chatbridge.Discord.print( JsonLang[ 'player_killed','' ], pReplacement );
                    }
                }
            }
            return HOOK_CONTINUE;
        }
    }
}