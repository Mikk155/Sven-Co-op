namespace Hooks
{
    HookReturnCode PlayerPostThink( CBasePlayer@ player )
    {
        if( player is null )
        {
            return HOOK_CONTINUE;
        }

        CBasePlayerWeapon@ activeWeapon;
        
        if( player.m_hActiveItem.IsValid() )
        {
            @activeWeapon = cast<CBasePlayerWeapon@>( player.m_hActiveItem.GetEntity() );
        }

        string activeWeaponClassname = activeWeapon.GetClassname();

        if( activeWeaponClassname == "weapon_medkit" )
        {
            if( ( player.pev.button & IN_ATTACK2 ) != 0 )
            {
                gpPlayerRevivedMedkitAmmo[ player.entindex() - 1 ] = player.m_rgAmmo( activeWeapon.PrimaryAmmoIndex() );
            }
        }

        return HOOK_CONTINUE;
    }
}