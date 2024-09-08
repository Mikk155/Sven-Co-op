namespace BS_UTILS
{
    CScheduledFunction@ pFunction = g_Scheduler.SetInterval( "InfinityThink", 0.0f, g_Scheduler.REPEAT_INFINITE_TIMES );
    array<EHandle> Players(g_Engine.maxClients);
    array<string> Weapons;

    void InfinityThink()
    {
        for( uint iPlayer = 0; iPlayer < Players.length(); ++iPlayer )
        {
            for( uint iWeapon = 0; iWeapon < Weapons.length(); ++iWeapon )
            {
                CBasePlayer@ pPlayer = cast<CBasePlayer@>( Players[iPlayer].GetEntity() );
                CBasePlayerWeapon@ pWeapon = (pPlayer !is null) ? cast<CBasePlayerWeapon@>( pPlayer.m_hActiveItem.GetEntity() ) : null;

                string weapon = Weapons[iWeapon];

                if( pPlayer is null || !pPlayer.IsConnected() || pWeapon is null )
                    continue;

                if( int(pPlayer.GetUserData( weapon+"_mode" )) == 1 && pWeapon.pev.classname != weapon )
                    ResetViewModel( @pPlayer, cast<CBasePlayerWeapon@>(pPlayer.HasNamedPlayerItem( weapon )), false );

                if( int(pPlayer.GetUserData( weapon+"_mode" )) == 1 && pWeapon.pev.classname == weapon && pWeapon.m_fInReload )
                    ResetViewModel( @pPlayer, @pWeapon );

                BS_357::Ejecute( @pPlayer, @pWeapon );
            }
        }
    }

    void SetViewModel( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, string viewmodel, int iFov = -1 )
    {
        if( !pPlayer.GetUserData().exists( string(pWeapon.pev.classname)+"_model" ) )
            pPlayer.GetUserData( string(pWeapon.pev.classname)+"_model" ) = string(pPlayer.pev.viewmodel);

        pPlayer.GetUserData( string(pWeapon.pev.classname)+"_mode" ) = 1;
        if( iFov != -1 ) pPlayer.pev.fov = pPlayer.m_iFOV = iFov;
        pPlayer.pev.viewmodel = viewmodel;
    }

    void ResetViewModel( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, bool force_model_view = true )
    {
        pPlayer.GetUserData( string(pWeapon.pev.classname)+"_mode" ) = 0;
        pPlayer.pev.fov = pPlayer.m_iFOV = 0;

        if( force_model_view )
            pPlayer.pev.viewmodel = string(pPlayer.GetUserData( string(pWeapon.pev.classname)+"_model" ));
    }

    void VerifyPlayer( CBasePlayer@ pPlayer, int mode )
    {
        for( uint iPlayer = 1; iPlayer < BS_UTILS::Players.length(); ++iPlayer )
        {
            CBasePlayer@ pFindPlayer = cast<CBasePlayer@>( BS_UTILS::Players[iPlayer].GetEntity() );

            if( mode == 0 )
            {
                if( pFindPlayer !is pPlayer )
                    BS_UTILS::Players.insertLast( @pPlayer );
            }
            if( mode == 1 )
            {
                if( pFindPlayer is pPlayer )
                    Players.removeAt( iPlayer );
            }
        }
    }
}