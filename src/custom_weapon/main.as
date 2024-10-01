/*
    #include "mikk/custom_weapon/main"

    void MapInit()
    {
        // Show warning messages
	    g_CustomWeapon.Logger.SetLog.warn( true );

        // Show debugging messages
	    g_CustomWeapon.Logger.SetLog.debug( true );

        // Show critical-error messages
	    g_CustomWeapon.Logger.SetLog.error( true );

        // Register your custom weapon entity (use schema_weapon.json)
	    g_CustomWeapon.Register.Weapon( "Path to json file" );

        // Register your custom ammo entity (use schema_ammo.json)
    	g_CustomWeapon.Register.Ammo( "Path to json file" );
    }
*/


#include "../../mikk/json"

#include "ammo"
#include "weapon"
#include "Projectile"

CCustomWeapon g_CustomWeapon;
class CCustomWeapon
{
    protected dictionary gpData = {};

    CLogger Logger;
    CRegistering Register;
    CProjectile Projectile;

    CCustomWeapon()
    {
        Logger = CLogger();
        Register = CRegistering();
        Projectile = CProjectile();
    }

    bool exists( const string &in szkeyName )
    {
        return gpData.exists( szkeyName );
    }

    json opIndex( const string &in szkeyName )
    {
        if( !exists( szkeyName ) )
        {
            Logger.error( "Json filename {} doesn't exists!", { szkeyName } );
        }

        return json( gpData[ szkey ] );
    }
}

final class CRegistering
{
	private void Register( const string &in JsonFile )
	{
        json pJson;

        if( !pJson.load( 'maps/' + JsonFile ) )
		{
			Logger.error( "Failed to load \"{}\"", { "scripts/maps/" + JsonFile } );
			return false;
		}

        gpData[ string( pJson[ "classname" ] ) ] = @pJson;
	}

	bool Weapon( const string &in JsonFile )
	{
		this.Register( JsonFile );

        if( !g_CustomEntityFuncs.IsCustomEntity( string( pJson[ "classname" ] ) ) )
        {
            g_CustomEntityFuncs.RegisterCustomEntity( "CWeaponBase", string( pJson[ "classname" ] ) );
            g_ItemRegistry.RegisterWeapon(
                "CWeaponBase",
                pJson[ "txt sprites", "" ],
                pJson[ "Primary Attack" ][ "ammo", "" ],
                pJson[ "Secondary Attack" ][ "ammo", "" ],
                "CAmmoBase"
            );
        }
	}

	bool Ammo( const string &in JsonFile )
	{
		this.Register( JsonFile );
	}
}

final class CSetLog
{
	void warn( bool Enable ) { WARN = Enable; }
	void debug( bool Enable ){ DEBUG = Enable; }
	void error( bool Enable ){ ERROR = Enable; }
}

class CLogger
{
    CSetLog SetLog;

    CLogger()
    {
        SetLog = CSetLog();
    }

	protected bool WARN  = false;
	protected bool DEBUG = false;
	protected bool ERROR = false;

	private void print( string logger, string message, array<string> szFormatting )
	{
        while( message.Find( "{}" ) != String::INVALID_INDEX )
        {

            if( szFormatting.length() != 0 )
            {
                message = message.SubString( 0, message.Find( '{' ) - 1 ) + szFormatting[0] + message.SubString( message.Find( '}' ) );
                szFormatting.removeAt(0);
            }
            else
            {
                message.Replace( "{}", String::EMPTY_STRING );
            }
        }

		g_EngineFuncs.ServerPrint( '[custom_weapon::' + logger + ']' + message + '\n' );
	}

	void error( string message, array<string> szFormatting = {} ) { if( ERROR ) { print( 'error', message, szFormatting ); } }
	void debug( string message, array<string> szFormatting = {} ) { if( DEBUG ) { print( 'debug', message, szFormatting ); } }
	void warn( string message, array<string> szFormatting = {} ) { if( WARN ) { print( 'warning', message, szFormatting ); } }
}

class CProjectile
{
    CAmmoBase@ Create( CBasePlayer@ m_hPlayer, json@ pWeaponJson, json@ pAmmoJson = {} )
    {
        const string sReport = "{} == nullptr \"{}\" at pointer \"CProjectile::Create\"";

        if( m_hPlayer is null )
        {
            Logger.error( sReport, { "CBasePlayer*", "m_hPlayer" } );
            return null;
        }

        if( pWeaponJson is null )
        {
            Logger.error( sReport, { "json*", "pWeaponJson" } );
            return null;
        }

        CBaseEntity@ pEntity = g_EntityFuncs.Create( "custom_weapon_ammo", g_vecZero, g_vecZero, true, m_hPlayer );

        if( pEntity is null )
        {
            Logger.error( sReport, { "CBaseEntity*", "pEntity" } );
            return null;
        }

        CCustomWeaponAmmo@ pAmmo = cast<CCustomWeaponAmmo@>( CastToScriptClass( pEntity ) );

        if( pEntity is null )
        {
            Logger.error( sReport, { "CCustomWeaponAmmo*", "pAmmo" } );
            return null;
        }

        pAmmo.weapon_data = pWeaponJson;
        pAmmo.projectile_data = pAmmoJson;

        pAmmo.Spawn();

        return @pAmmo;
    }
}
