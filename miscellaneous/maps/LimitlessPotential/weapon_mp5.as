namespace BS_MP5
{
    string ZoomModel = "models/scp_9mmar.mdl";

    HookReturnCode Mp5PrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.pev.classname == "weapon_9mmAR" )
        {
            int iMode = int(pPlayer.GetUserData( "mp5_mode" ));
            
            if( iMode == 1 )
            {
                for( int i = 1; i < 3; ++i )
                {
                    g_Scheduler.SetTimeout( "FakePrimaryAttack", 0.05 * i, @pPlayer, @pWeapon );
                }  

                pPlayer.m_flNextAttack = 0.55;
            }
        }

        return HOOK_CONTINUE;
    }

    void FakePrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer.pev.waterlevel == WATERLEVEL_HEAD || pWeapon.m_iClip <= 0 )
        {
            pWeapon.PlayEmptySound();
            return;
        }

        pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
        pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

        --pWeapon.m_iClip;
        
        switch ( g_PlayerFuncs.SharedRandomLong( pPlayer.random_seed, 0, 2 ) )
        {
            case 0: pWeapon.SendWeaponAnim( 5, 0, 0 ); break;
            case 1: pWeapon.SendWeaponAnim( 6, 0, 0 ); break;
            case 2: pWeapon.SendWeaponAnim( 7, 0, 0 ); break;
        }

        g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_WEAPON, "weapons/hks1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );

        // player "shoot" animation
        pPlayer.SetAnimation( PLAYER_ATTACK1 );

        Vector vecSrc	 = pPlayer.GetGunPosition();
        Vector vecAiming = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
        
        // optimized multiplayer. Widened to make it easier to hit a moving player
        pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 8192, BULLET_PLAYER_MP5, 2 );

        if( pWeapon.m_iClip == 0 && pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType ) <= 0 )
            // HEV suit - indicate out of ammo condition
            pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

        pPlayer.pev.punchangle.x = Math.RandomLong( -2, 2 );

        pWeapon.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( pPlayer.random_seed,  10, 15 );
        
        TraceResult tr;
        
        float x, y;
        
        g_Utility.GetCircularGaussianSpread( x, y );
        
        Vector vecDir = vecAiming 
                        + x * VECTOR_CONE_3DEGREES.x * g_Engine.v_right 
                        + y * VECTOR_CONE_3DEGREES.y * g_Engine.v_up;

        Vector vecEnd	= vecSrc + vecDir * 4096;

        g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pPlayer.edict(), tr );
        
        if( tr.flFraction < 1.0 )
        {
            if( tr.pHit !is null )
            {
                CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
                
                if( pHit is null || pHit.IsBSPModel() )
                    g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
            }
        }
    }

    HookReturnCode Mp5TertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.pev.classname == "weapon_9mmAR" )
        {
            int iMode = int(pPlayer.GetUserData( "mp5_mode" ));
            pPlayer.GetUserData( "mp5_mode" ) = ( iMode == 1 ) ? 0 : 1;
            pWeapon.m_fInZoom = false;
            pPlayer.pev.fov = pPlayer.m_iFOV = 0;

            pPlayer.m_flNextAttack = pWeapon.m_flNextSecondaryAttack;
        }

        return HOOK_CONTINUE;
    }

    HookReturnCode Mp5SecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.pev.classname == "weapon_9mmAR" && pPlayer.m_flNextAttack <= 0 )
        {            
            if( pWeapon.m_fInZoom )
            {
                BS_UTILS::VerifyPlayer( @pPlayer, 0 );
                BS_UTILS::SetViewModel( @pPlayer, @pWeapon, ZoomModel );
            }
            else
            {
                BS_UTILS::VerifyPlayer( @pPlayer, 1 );
                BS_UTILS::ResetViewModel( @pPlayer, @pWeapon );
            }

            pPlayer.m_flNextAttack = 0.35;
        }

        return HOOK_CONTINUE;
    }

    void MapInit()
    {
        g_Game.PrecacheModel( ZoomModel );
        g_Game.PrecacheGeneric( ZoomModel );

        g_SoundSystem.PrecacheSound( "weapons/hks1.wav" );

        g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, Mp5PrimaryAttack );
        g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, Mp5SecondaryAttack );
        g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, Mp5TertiaryAttack );
    }
}