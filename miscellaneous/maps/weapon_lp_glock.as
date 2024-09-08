namespace weapon_lp_glock
{
    void MapInit()
    {
        if( g_EngineFuncs.CVarGetFloat( 'weaponmode_9mmhandgun' ) == 0 )
        {
            g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @weapon_lp_glock::WeaponSecondaryAttack );
        }
    }

    HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pWeapon.GetClassname() != 'weapon_9mmhandgun' || pWeapon.m_iClip == 0 || pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pWeapon is null )
            return HOOK_CONTINUE;

        pPlayer.pev.punchangle.x = -3.0f;
        pWeapon.m_flNextSecondaryAttack = 0.05f;

        return HOOK_CONTINUE;
    }
}