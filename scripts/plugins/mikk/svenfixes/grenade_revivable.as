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
    namespace grenade_revivable
    {
        void PluginInit()
        {
            InitHook( 'OnThink', 'grenade_revivable' );
        }

        float time;

        void OnThink()
        {
            if( g_Engine.time > time )
            {
                CBaseEntity@ pGrenade = null;

                while( ( @pGrenade = g_EntityFuncs.FindEntityByClassname( pGrenade, 'grenade' ) ) !is null  )
                {
                    g_EntityFuncs.DispatchKeyValue( pGrenade.edict(), 'is_not_revivable', '1' );
                }

                time = g_Engine.time + 2.0f;
            }
        }
    }
}
