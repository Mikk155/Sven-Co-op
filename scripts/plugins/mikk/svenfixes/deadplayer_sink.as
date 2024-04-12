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
    namespace deadplayer_sink
    {
        void PluginInit()
        {
            InitHook( 'OnObserverMode', 'deadplayer_sink' );
        }

        void OnObserverMode( CBasePlayer@ pPlayer, ObserverMode iMode )
        {
            if( iMode != OBS_NONE && pPlayer.GetObserver().HasCorpse() )
            {
                CBaseEntity@ pCorpse = null;

                while( ( @pCorpse = g_EntityFuncs.FindEntityByClassname( pCorpse, 'deadplayer' ) ) !is null )
                {
                    if( pCorpse.pev.renderamt == pPlayer.entindex() )
                    {
                        deadplayer_sinkCheckCorpse( EHandle( pCorpse ), pCorpse.pev.origin );
                        break;
                    }
                }
            }
        }

        void deadplayer_sinkCheckCorpse( EHandle hCorpse, Vector VecPos )
        {
            CBaseEntity@ pCorpse = hCorpse.GetEntity();

            if( pCorpse !is null )
            {
                TraceResult tr;

                g_Game.AlertMessage( at_console, 'velocity ' + string(pCorpse.pev.origin.z) + '\n' );
                g_Utility.TraceLine( pCorpse.pev.origin, pCorpse.pev.origin, ignore_monsters, pCorpse.edict(), tr );

                if( tr.fInOpen == 1 && ( pCorpse.pev.flags & FL_ONGROUND ) == 0 )
                {
                    g_Scheduler.SetTimeout( 'deadplayer_sinkCheckCorpse', 0.1f, EHandle( pCorpse ), VecPos );
                }
                else if( pCorpse.pev.origin.z > VecPos.z - 100 )
                {
                    VecPos.z += 20;
                    g_EntityFuncs.SetOrigin( pCorpse, VecPos );
                    g_EngineFuncs.DropToFloor( pCorpse.edict() );
                    pCorpse.pev.movetype = MOVETYPE_NONE;
                    pCorpse.pev.solid = SOLID_NOT;
                }
            }
        }
    }
}
