namespace BS_357
{
    string ZoomModel = "models/scp_crossbow.mdl";

    void Ejecute( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
    {
        if( pWeapon.pev.classname == "weapon_357" && pPlayer.pev.button & IN_ATTACK2 != 0 && pPlayer.m_flNextAttack <= 0 )
        {
            pWeapon.m_fInZoom = (pPlayer.pev.fov == 0 && pWeapon.m_fInZoom) ? true : !pWeapon.m_fInZoom;

            if( pWeapon.m_fInZoom )
            { 
                BS_UTILS::SetViewModel( @pPlayer, @pWeapon, ZoomModel, 40 );
            }
            else
            {
                BS_UTILS::ResetViewModel( @pPlayer, @pWeapon );
            }

            pPlayer.m_flNextAttack = 0.35;
        }
    }

    HookReturnCode Picked357( CBaseEntity@ pPickup, CBaseEntity@ pOther )
    {
        if( pPickup is null || pOther is null )
            return HOOK_CONTINUE;

        if( pPickup.pev.classname == "weapon_357" )
        {
            BS_UTILS::VerifyPlayer( cast<CBasePlayer@>(pOther), 0 );
        }

        return HOOK_CONTINUE;
    }

    void MapInit()
    {
        g_Game.PrecacheModel( ZoomModel );
        g_Game.PrecacheGeneric( ZoomModel );

        BS_UTILS::Weapons.insertLast( "weapon_357" );

        g_Hooks.RegisterHook( Hooks::PickupObject::Collected, Picked357 );
    }
}