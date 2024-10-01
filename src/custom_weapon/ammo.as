bool CCustomWeaponAmmoRegister = BCustomWeaponAmmoRegister();

bool BCustomWeaponAmmoRegister()
{
	if( !g_CustomEntityFuncs.IsCustomEntity( "custom_weapon_ammo" ) )
	{
		g_CustomEntityFuncs.RegisterCustomEntity( "CCustomWeaponAmmo", "custom_weapon_ammo" );
		g_Game.PrecacheOther( "custom_weapon_ammo" );
	}
	return g_CustomEntityFuncs.IsCustomEntity( "custom_weapon_ammo" );
}

class CCustomWeaponAmmo : ScriptBasePlayerAmmoEntity
{
	json weapon_data;
	json projectile_data;

	json@ value( const string szValue )
	{
		if( weapon_data.exists( szValue ) )
			return weapon_data[ szValue ];
		return projectile_data[ szValue ];
	}

	void Spawn()
	{
	}

	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		return false;
	}
}
