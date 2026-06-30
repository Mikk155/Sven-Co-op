namespace Hooks
{
    array<int> gpPlayerRevivedMedkitAmmo(g_Engine.maxClients);

    HookReturnCode PlayerRevived( CBasePlayer@ player )
    {
        if( player is null )
        {
            return HOOK_CONTINUE;
        }

        // Entity that revived player.
        CBaseEntity@ reviver = null;

        for( int i = 1; i <= g_Engine.maxClients; i++ )
        {
            CBasePlayer@ other = g_PlayerFuncs.FindPlayerByIndex(i);

            CBasePlayerWeapon@ activeWeapon;

            if( other is null
            || !player.m_hActiveItem.IsValid() // Has a weapon
            || ( other.pev.origin - player.pev.origin ).Length() >= 1024 // Is close enough
            || ( @activeWeapon = cast<CBasePlayerWeapon@>( other.m_hActiveItem.GetEntity() ) ) is null // cast
            || activeWeapon.GetClassname() != "weapon_medkit" // Is medkit
            || gpPlayerRevivedMedkitAmmo[ other.entindex() ]  >= other.m_rgAmmo( activeWeapon.PrimaryAmmoIndex() ) ) // Has less ammo than PlayerPostThink says
                continue;

            gpPlayerRevivedMedkitAmmo.resize(0);
            gpPlayerRevivedMedkitAmmo.resize(g_Engine.maxClients);
            @reviver = other;
            break;
        }

        if( reviver is null )
        {
            CBaseEntity@ ent = null;

            if( ( @ent = g_EntityFuncs.FindEntityInSphere( ent, player.pev.origin, 1024, "monster_scientist", "classname" ) ) !is null && ent.IRelationship( player ) == R_AL )
                @reviver = ent;
        }

        return HOOK_CONTINUE;
    }
}
