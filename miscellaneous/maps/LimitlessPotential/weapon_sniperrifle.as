namespace BS_SNIPER
{
    string ZoomModel = "models/scp_m40a1.mdl";

    HookReturnCode SniperSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.pev.classname == "weapon_sniperrifle" && pPlayer.m_flNextAttack <= 0 )
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

        BS_UTILS::Weapons.insertLast( "weapon_sniperrifle" );

        g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, SniperSecondaryAttack );
    }
}