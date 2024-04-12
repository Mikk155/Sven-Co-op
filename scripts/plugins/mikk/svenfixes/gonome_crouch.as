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
    namespace gonome_crouch
    {
        void PluginInit()
        {
            InitHook( 'OnMonsterCheckEnemy', 'gonome_crouch' );
        }

        void OnMonsterCheckEnemy( CBaseMonster@ pMonster, CBaseEntity@ pEnemy )
        {
            if( pMonster.GetClassname() == 'monster_gonome' && pEnemy.IsPlayer()
            && ( pEnemy.pev.origin - pMonster.pev.origin ).Length() < 64
            && pEnemy.pev.flags & FL_ONGROUND == 0 )
            {
                pEnemy.pev.velocity.z = 100;
            }
        }
    }
}
