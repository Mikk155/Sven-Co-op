#include "utils"
namespace player_data
{
    class player_data : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
			if( master() )
				return;

            if( spawnflag( 1 ) )
            {
				for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    StoreData( pPlayer );
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                StoreData( cast<CBasePlayer@>( pActivator ) );
            }
        }

		void StoreData( CBasePlayer@ pPlayer )
		{
			g_Util.SetCKV( pPlayer, "$i_data_suit", string( pPlayer.HasSuit() ) );
			g_Util.SetCKV( pPlayer, "$i_data_longjump", string( pPlayer.m_fLongJump ) );
			g_Util.SetCKV( pPlayer, "$i_data_hascorpse", string( pPlayer.GetObserver().HasCorpse() ) );
			g_Util.SetCKV( pPlayer, "$i_data_flashlight", string( pPlayer.FlashlightIsOn() ) );
			g_Util.SetCKV( pPlayer, "$i_data_inladder", string( pPlayer.IsOnLadder() ) );
			g_Util.SetCKV( pPlayer, "$i_data_adminlevel", string( g_PlayerFuncs.AdminLevel( pPlayer ) ) );
			g_Util.SetCKV( pPlayer, "$s_data_steamid", string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );
			g_Util.Trigger( self.pev.target, pPlayer, self, USE_TOGGLE, delay );
		}
    }
	bool Register = g_Util.CustomEntity( 'player_data::player_data','player_data' );
}