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

namespace ClientSay
{
    void Register()
    {
        g_Hooks.RemoveHook( Hooks::Player::ClientSay, @ClientSay::ClientSay );

        if( pJson[ 'MESSAGES', {} ][ 'ClientSay', {} ][ 'enable', false ] )
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

        array<string> BadWords = array<string>( pJson[ 'bad words' ] );

        for( uint ui = 0; ui < BadWords.length(); ui++ )
        {
            int ilength = BadWords[ui].Length();
            string strAsterisks;
            while( ilength > 0 )
            {
                strAsterisks += '*';
                ilength--;
            }
            sentence.Replace( BadWords[ui], strAsterisks );
        }
        g_Game.AlertMessage( at_console, 'sex ' + sentence + '\n' );

        FormatMessage( string( pJson[ 'MESSAGES', {} ][ 'ClientSay', {} ][ 'message' ] ),
        {
            { 'message', sentence },
            { 'emote', GetEmote( pPlayer ) },
            { 'name', string( pPlayer.pev.netname ) },
            { 'steam', PlayerFuncs::GetSteamID( pPlayer ) },
            { 'dead', ( pPlayer.IsAlive() ? '' : string( pJson[ 'MESSAGES', {} ][ 'ClientSay', {} ][ 'dead', {} ][ language ] ) ) }
        });

        return HOOK_CONTINUE;
    }
}