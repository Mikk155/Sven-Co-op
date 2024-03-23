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
    namespace ClientSay
    {
        void PluginInit()
        {
            if( JsonLog[ 'game chat', false ] )
            {
                g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay::ClientSay );
            }
        }

        HookReturnCode ClientSay( SayParameters@ pParams )
        {
            CBasePlayer@ pPlayer = pParams.GetPlayer();
            const CCommand@ args = pParams.GetArguments();

            if( pPlayer is null || args.ArgC() <= 0 || pParams.ShouldHide )
                return HOOK_CONTINUE;

            string sentence = args.GetCommandString();

            array<string> BadWords = JsonBadWords.getKeys();

            for( uint ui = 0; ui < BadWords.length(); ui++ )
                if( JsonBadWords[ BadWords[ui], true ] )
                    sentence.Replace( BadWords[ui], '|| ' + BadWords[ui] + ' ||' );

            g_Chatbridge.Discord.print( '- ' + GetEmote( pPlayer ) + ( pPlayer.IsAlive() ? "" : JsonLang[ 'player_status_dead' ] + " " ) + string( pPlayer.pev.netname ) + ": " + sentence, {} );

            return HOOK_CONTINUE;
        }
    }
}