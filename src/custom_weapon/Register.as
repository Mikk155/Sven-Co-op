final class CRegistering
{
	private bool Register( const string &in JsonFile, int bIsWeapon )
	{
        json pJson;

        if( !pJson.load( 'maps/' + JsonFile ) )
		{
			Logger.error( "Failed to load \"{}\"", { "scripts/maps/" + JsonFile } );
			return false;
		}

		string classname = pJson[ "classname", String::EMPTY_STRING ];

		switch( bIsWeapon )
		{
			case 1:
			{
				if( !g_CustomEntityFuncs.IsCustomEntity( classname ) )
				{
					g_CustomEntityFuncs.RegisterCustomEntity( "CWeaponBase", classname );
					g_ItemRegistry.RegisterWeapon(
						"CWeaponBase",
						pJson[ "txt sprites", "" ],
						pJson[ "Primary Attack" ][ "ammo", "" ],
						pJson[ "Secondary Attack" ][ "ammo", "" ],
						"CAmmoBase"
					);
				}
				break;
			}
			default:
			{
				if( !g_CustomEntityFuncs.IsCustomEntity( classname ) )
				{
					g_CustomEntityFuncs.RegisterCustomEntity( "CWeaponBase", classname );
					g_Game.PrecacheOther( classname );
				}
				break;
			}

			return g_CustomEntityFuncs.IsCustomEntity( classname );
		}
	}

	bool Weapon( const string &in JsonFile )
	{
		this.Register( JsonFile, 1 );
	}

	bool Ammo( const string &in JsonFile )
	{
		this.Register( JsonFile, 0 );
	}
}
