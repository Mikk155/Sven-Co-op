namespace BS_CROSSBOW
{
    string ZoomModel = "models/scp_crossbow.mdl";

    HookReturnCode CrossbowPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        g_Scheduler.SetTimeout( "FindBolt", 0.001, @pPlayer, @pWeapon );

        return HOOK_CONTINUE;
    }

    void FindBolt( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        CBaseEntity@ pCrossbow = null;
        while((@pCrossbow = g_EntityFuncs.FindEntityByClassname( pCrossbow, "bolt" )) !is null)
        {
            if( pPlayer is g_EntityFuncs.Instance( pCrossbow.pev.owner ) && pWeapon.m_fInZoom )
            {
                pCrossbow.pev.velocity = pCrossbow.pev.velocity * 2;
            }
        }
    }

    HookReturnCode CrossbowSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pPlayer is null || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.pev.classname == "weapon_crossbow" && pPlayer.m_flNextAttack <= 0 )
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

        BS_UTILS::Weapons.insertLast( "weapon_crossbow" );

        g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, CrossbowPrimaryAttack );
        g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, CrossbowSecondaryAttack );
    }
}