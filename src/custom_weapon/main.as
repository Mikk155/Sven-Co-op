/*
    #include "mikk/custom_weapon/main"

    void MapInit()
    {
        // Show warning messages
	    g_CustomWeapon.Logger.SetLogLevel.warn( true );

        // Show debugging messages
	    g_CustomWeapon.Logger.SetLogLevel.debug( true );

        // Show critical-error messages
	    g_CustomWeapon.Logger.SetLogLevel.error( true );

        // Register your custom weapon entity (use schema_weapon.json)
	    g_CustomWeapon.Register.Weapon( "Path to json file" );

        // Register your custom ammo entity (use schema_ammo.json)
    	g_CustomWeapon.Register.Ammo( "Path to json file" );
    }
*/


#include "../../mikk/json"
#include "Logger"
#include "Register"
#include "weapon"
#include "ammo"

CCustomWeapon g_CustomWeapon;
class CCustomWeapon
{
    CLogger Logger;
    CRegistering Register;

    CCustomWeapon()
    {
        Logger = CLogger();
        Register = CRegistering();
    }
}
