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
    namespace tripmine_spam
    {
        void PluginInit()
        {
            InitHook( 'OnPlayerAttack', 'tripmine_spam' );
        }

        void OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
        {
            if( pWeapon.GetClassname() == 'weapon_tripmine' )
            {
                CBaseEntity@ pMine = null;

                for( int i = 0; ( @pMine = g_EntityFuncs.FindEntityInSphere( pMine, pPlayer.pev.origin, 128, 'monster_tripmine', 'classname' ) ) !is null; i++ )
                {
                    if( i > 10 )
                    {
                        pMine.Killed( pPlayer.pev, GIB_NEVER );
                    }
                }
            }
        }
    }
}
