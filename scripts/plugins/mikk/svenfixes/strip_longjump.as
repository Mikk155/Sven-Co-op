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

namespace svenfixes
{
    namespace strip_longjump
    {
        void PluginInit()
        {
            InitHook( 'OnThink', 'strip_longjump' );
        }

        float time;

        void OnThink()
        {
            if( g_EntityFuncs.FindEntityByClassname( null, 'player_weaponstrip' ) !is null && g_Engine.time > time )
            {
                for( int i = 0; i <= g_Engine.maxClients; i++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                    if( pPlayer !is null && !pPlayer.HasSuit() )
                    {
                        pPlayer.m_fLongJump = false;
                        g_EngineFuncs.GetPhysicsKeyBuffer( pPlayer.edict() ).SetValue( "slj", "0" );
                    }
                }
                time = g_Engine.time + 2.0f;
            }
        }
    }
}
