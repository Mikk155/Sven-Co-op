/*

// INSTALLATION:

#include "mikk/player_data"

*/
#include "utils"
namespace player_data
{
    void ScriptInfo()
    {
        g_Information.SetInformation
        ( 
            'Script: player_data\n' +
            'Description: \n' +
            'Author: Mikk\n' +
            'Discord: ' + g_Information.GetDiscord( 'mikk' ) + '\n'
            'Server: ' + g_Information.GetDiscord() + '\n'
            'Github: ' + g_Information.GetGithub()
        );
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_data::player_data", "player_data" );
    }

    enum player_data_spawnflags
    {
        ALL_PLAYERS = 1
    }

    class player_data : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
            {
                if( spawnflag( ALL_PLAYERS ) )
                {
                    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                    {
                        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                        StoreData( pPlayer );
                    }
                }
                else
                {
                    StoreData( cast<CBasePlayer@>( pActivator ) );
                }
            }
        }

        void StoreData( CBasePlayer@ pPlayer )
        {
            if( pPlayer !is null && pPlayer.IsPlayer() )
            {
                g_Util.SetCKV( pPlayer, "$i_data_suit", string( pPlayer.HasSuit() ) );
                g_Util.SetCKV( pPlayer, "$i_data_longjump", string( pPlayer.m_fLongJump ) );
                g_Util.SetCKV( pPlayer, "$i_data_hascorpse", string( pPlayer.GetObserver().HasCorpse() ) );
                g_Util.SetCKV( pPlayer, "$i_data_flashlight", string( pPlayer.FlashlightIsOn() ) );
                g_Util.SetCKV( pPlayer, "$i_data_inladder", string( pPlayer.IsOnLadder() ) );
                g_Util.SetCKV( pPlayer, "$i_data_adminlevel", string( g_PlayerFuncs.AdminLevel( pPlayer ) ) );
                g_Util.SetCKV( pPlayer, "$s_data_steamid", string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );
                g_Util.SetCKV( pPlayer, "$s_data_index", string( pPlayer.entindex() ) );
                g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
            }
        }
    }
}