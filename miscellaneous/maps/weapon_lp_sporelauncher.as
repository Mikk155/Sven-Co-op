//#include '../as_register'

namespace weapon_lp_sporelauncher
{
    void MapInit()
    {
        //g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @weapon_lp_sporelauncher::WeaponPrimaryAttack );
        g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @weapon_lp_sporelauncher::WeaponTertiaryAttack );
        //g_Hooks.RegisterHook( Hooks::Entity::Touch, @weapon_lp_sporelauncher::Touch );
    }

/*    HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pWeapon.GetClassname() != 'weapon_sporelauncher' || pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pWeapon is null )
            return HOOK_CONTINUE;

        CBaseEntity@ pSpore = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 32, 'sporegrenade', 'classname' );

        if( pSpore !is null )
        {
            pSpore.pev.movetype = MOVETYPE_FLY;
            pSpore.pev.velocity = g_Engine.v_forward * 1024;
        }
        return HOOK_CONTINUE;
    }*/

    HookReturnCode WeaponTertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pWeapon.GetClassname() != 'weapon_sporelauncher' || pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() || pWeapon is null )
            return HOOK_CONTINUE;

        if( pWeapon.m_flNextTertiaryAttack <= g_Engine.time )
        {
            pWeapon.m_flNextTertiaryAttack = 0.6f;
            pWeapon.PrimaryAttack();

            CBaseEntity@ pSpore = g_EntityFuncs.FindEntityInSphere( null, pPlayer.pev.origin, 32, 'sporegrenade', 'classname' );

            if( pSpore !is null )
            {
                pSpore.pev.movetype = MOVETYPE_FLY;
                pSpore.pev.velocity = g_Engine.v_forward * 1024;
            }
        }
        return HOOK_CONTINUE;
    }

/*    HookReturnCode Touch( CBaseEntity@ pTouched, CBaseEntity@ pOther, META_RES& out meta_result )
    {
        if( pOther is null || pOther.GetClassname() != 'sporegrenade' || pOther.pev.movetype != MOVETYPE_FLY )
            return HOOK_CONTINUE;

        CBaseEntity@ pOwner = g_EntityFuncs.Instance( pOther.pev.owner );

        if( pTouched.pev.takedamage == DAMAGE_NO )
        {
            g_WeaponFuncs.RadiusDamage
            (
                pOther.pev.origin, pOther.pev,
                ( pOwner is null ? pOther.pev : pOwner.pev ),
                g_EngineFuncs.CVarGetFloat( 'sk_plr_spore' ),
                128, CLASS_PLAYER, DMG_GENERIC | DMG_ALWAYSGIB | DMG_POISON
            );
        }

        g_EntityFuncs.Remove( pOther );

        return HOOK_CONTINUE;
    }*/
}