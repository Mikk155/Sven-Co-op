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
    namespace elevator_kill
    {
        void PluginInit()
        {
            InitHook( 'OnPlayerTakeDamage', 'elevator_kill' );
        }

        void OnPlayerTakeDamage( DamageInfo@ pDamageInfo )
        {
            CBaseEntity@ pVictim = pDamageInfo.pVictim;
            CBaseEntity@ pInflictor = pDamageInfo.pInflictor;
            CBaseEntity@ pAttacker = pDamageInfo.pAttacker;

            if( ( pDamageInfo.bitsDamageType & DMG_CRUSH ) != 0 && pDamageInfo.flDamage > 0 )
            {
                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                    if( pPlayer !is null && pPlayer.IsConnected()
                    && pPlayer.IsAlive() && pPlayer !is pVictim
                    && pPlayer.pev.origin.z > pVictim.pev.origin.z
                    && ( pPlayer.pev.origin - pVictim.pev.origin ).Length() < 74 )
                    {
                        pPlayer.TakeDamage( pInflictor.pev, pAttacker.pev, pDamageInfo.flDamage, pDamageInfo.bitsDamageType );
                        Vector VecPos = pPlayer.pev.origin;
                        pPlayer.SetOrigin( pVictim.pev.origin );
                        pVictim.SetOrigin( VecPos );
                        pDamageInfo.flDamage = 0;
                    }
                }
            }
        }
    }
}
