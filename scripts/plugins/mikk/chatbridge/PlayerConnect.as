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
    namespace PlayerConnect
    {
        void PluginInit()
        {
            if( JsonLog[ 'client connected', false ] )
            {
                g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @chatbridge::PlayerConnect::ClientPutInServer );
            }
        }

        HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
        {
            if( pPlayer !is null )
            {
                string name = string( Mikk.PlayerFuncs.GetSteamID( pPlayer ) ) + " " + string( pPlayer.pev.netname );
                g_Chatbridge.Discord.print( JsonLang[ 'player_connected' ], { { 'name', name } } );
            }
            return HOOK_CONTINUE;
        }
    }
}