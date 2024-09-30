#include "../../mikk/json"

namespace custom_weapon
{
    bool Register( const string &in JsonFile )
    {
        json pJson;

        if( !pJson.load( JsonFile ) )
            g_EngineFuncs.ServerPrint( "WARNING! Failed to load \"" + JsonFile + "\"\n" );

		g_ItemRegistry.RegisterWeapon( "custom_weapon::CWeaponBase", pJson[ "txt sprites" ], pJson[ "ammo" ], "", "custom_weapon::CAmmoBase" );
	    g_CustomEntityFuncs.RegisterCustomEntity( "custom_weapon::CWeaponBase", pJson[ "classname" ] );
    }

	class CWeaponBase : ScriptBasePlayerWeaponEntity
	{
		private CBasePlayer@ m_pPlayer = null;

		void Spawn()
		{

		}

		void Precache()
		{

		}

		bool GetItemInfo( ItemInfo& out info )
		{
			return true;
		}

		bool AddToPlayer(CBasePlayer@ pPlayer)
		{
			return true;
		}

		bool PlayEmptySound()
		{
			return false;
		}

		bool Deploy()
		{
			return bResult;
		}

		void Holster( int skiplocal = 0 )
		{
		}

		void PrimaryAttack()
		{
		}

		void SecondaryAttack()
		{
		}

		void WeaponIdle()
		{
		}

		void Reload()
		{
		}
	}

	class CAmmoBase : ScriptBasePlayerAmmoEntity
	{
		void Spawn()
		{ 
		}

		bool AddAmmo( CBaseEntity@ pOther )
		{ 
			return false;
		}
	}
}
