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
    namespace changelevel_items
    {
        void PluginInit()
        {
            InitHook( 'OnMapChange', 'changelevel_items' );
            InitHook( 'OnPlayerSpawn', 'changelevel_items' );
        }

        dictionary g_Data;

        enum gData_e
        {
            akimbo = ( 1 << 0 ),
            longjump = ( 1 << 1 ),
        }

        void OnPlayerSpawn( CBasePlayer@ pPlayer )
        {
            if( g_Data.exists( PlayerFuncs::GetSteamID( pPlayer ) ) )
            {
                int iBits = int( g_Data[ PlayerFuncs::GetSteamID( pPlayer ) ] );

                if( ( iBits & gData_e::akimbo ) != 0 )
                {
                    CBasePlayerItem@ pUzi = pPlayer.HasNamedPlayerItem( 'weapon_uzi' );

                    if( pUzi !is null )
                    {
                        pPlayer.RemovePlayerItem( pUzi );
                    }

                    pPlayer.GiveNamedItem( 'weapon_uziakimbo', 0, 0 );
                }

                if( ( iBits & gData_e::longjump ) != 0 )
                {
                    pPlayer.m_fLongJump = true;
                    g_EngineFuncs.GetPhysicsKeyBuffer( pPlayer.edict() ).SetValue( "slj", "1" );
                }
            }
        }

        void OnMapChange()
        {
            g_Data.deleteAll();

            for( int i = 1; i <= g_Engine.maxClients; i++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                if( pPlayer !is null )
                {
                    int DataItems = 0;

                    CBasePlayerItem@ pItem = pPlayer.HasNamedPlayerItem( 'weapon_uzi' );

                    if( pItem !is null )
                    {
                        CBasePlayerWeapon@ pUzi = cast<CBasePlayerWeapon@>( pItem );

                        if( pUzi !is null && pUzi.m_fIsAkimbo )
                        {
                            DataItems |= gData_e::akimbo;
                        }
                    }

                    if( pPlayer.m_fLongJump || atoi( CustomKeyValue( pPlayer, '$i_fix_lost_longjump' ) ) == 1 )
                    {
                        DataItems |= gData_e::longjump;
                    }

                    g_Data[ PlayerFuncs::GetSteamID( pPlayer ) ] = DataItems;
                }
            }
        }
    }
}
