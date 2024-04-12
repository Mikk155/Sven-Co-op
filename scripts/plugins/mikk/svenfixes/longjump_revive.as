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
    namespace longjump_revive
    {
        void PluginInit()
        {
            InitHook( 'OnPlayerRevive', 'longjump_revive' );
            InitHook( 'OnPlayerKilled', 'longjump_revive' );
            InitHook( 'OnPlayerSpawn', 'longjump_revive' );
        }

        void OnPlayerRevive( CBasePlayer@ pPlayer )
        {
            if( atoi( CustomKeyValue( pPlayer, '$i_fix_lost_longjump' ) ) == 1 )
            {
                pPlayer.m_fLongJump = true;
                g_EngineFuncs.GetPhysicsKeyBuffer( pPlayer.edict() ).SetValue( "slj", "1" );
            }
        }

        void OnPlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
        {
            if( pPlayer.m_fLongJump )
            {
                CustomKeyValue( pPlayer, '$i_fix_lost_longjump', 1 );
            }
        }

        void OnPlayerSpawn( CBasePlayer@ pPlayer )
        {
            if( pPlayer.GetCustomKeyvalues().HasKeyvalue( '$i_fix_lost_longjump' ) )
            {
                CustomKeyValue( pPlayer, '$i_fix_lost_longjump', 0 );
            }
        }
    }
}
