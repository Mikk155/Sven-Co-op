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
    namespace gravity_lost
    {
        void PluginInit()
        {
            InitHook( 'OnPlayerRevive', 'gravity_lost' );
            InitHook( 'OnPlayerKilled', 'gravity_lost' );
            InitHook( 'OnPlayerSpawn', 'gravity_lost' );
        }

        void OnPlayerRevive( CBasePlayer@ pPlayer )
        {
            if( pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_fix_lost_gravity' ) )
            {
                pPlayer.pev.gravity = pPlayer.GetCustomKeyvalues().GetKeyvalue( '$f_fix_lost_gravity' ).GetFloat();
            }
        }

        void OnPlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
        {
            array<string> str =
            {
                "trigger_gravity",
                "trigger_copyvalue",
                "trigger_changevalue"
            };

            for( uint ui = 0; ui < str.length(); ui++ )
            {
                if( g_EntityFuncs.FindEntityByClassname( null, str[ui] ) !is null || pPlayer.pev.gravity != 1.0 )
                {
                    g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_fix_lost_gravity', pPlayer.pev.gravity );
                    break;
                }
            }
        }

        void OnPlayerSpawn( CBasePlayer@ pPlayer )
        {
            if( pPlayer.GetCustomKeyvalues().HasKeyvalue( '$f_fix_lost_gravity' ) )
            {
                g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_fix_lost_gravity', pPlayer.pev.gravity );
            }
        }
    }
}
