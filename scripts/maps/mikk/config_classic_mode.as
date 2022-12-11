/*
DOWNLOAD:

scripts/maps/mikk/config_classic_mode.as
scripts/maps/mikk/utils.as


INSTALL:
    
#include "mikk/config_classic_mode"

void MapInit()
{
    config_classic_mode::Register();
}
*/

#include "utils"

namespace config_classic_mode
{
    enum config_classic_mode_flags
    {
        SF_CCM_RESTART_NOW = 1 << 0
    }

    class config_classic_mode : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        dictionary g_ItemMappings;

        const array<string> g_keys
        {
            get const { return g_ItemMappings.getKeys(); }
        }

        private string
            target_toggle,
                target_failed,
                    target_enabled,
                        target_disabled;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);
            g_ItemMappings[ szKey ] = szValue;
            if( szKey == "target_toggle" ) target_toggle = szValue;
            else if( szKey == "target_failed" ) target_failed = szValue;
            else if( szKey == "target_enabled" ) target_enabled = atof( szValue );
            else if( szKey == "target_disabled" ) target_disabled = atof( szValue );
            return true;
        }

        void Precache()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < g_keys.length(); ui++)
                {
                    string Key = g_keys[ui];
                    string Value = string( g_ItemMappings[ Key ] );

                    if( string( Key ).StartsWith( "models/" ) )
                    {
                        g_Game.PrecacheModel( Value );
                        UTILS::Debug( "[config_classic_mode::Precache()] Precached model '" + Value + "'" );
                    }
                }
            }

            BaseClass.Precache();
        }

        void Spawn()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for(uint ui = 0; ui < g_keys.length(); ui++)
                {
                    string Key = g_keys[ui];
                    string Value = string( g_ItemMappings[ Key ] );

                    if( string( Key ).StartsWith( "models/" ) )
                    {
                        dictionary g_changemodel;
                        g_changemodel [ "target" ] = "!activator";
                        g_changemodel [ "model" ] = Value;
                        g_changemodel [ "targetname" ] =  "CCM_" + Key;
                        g_EntityFuncs.CreateEntity( "trigger_changemodel", g_changemodel, true );
                        UTILS::Debug( "[config_classic_mode::Spawn()] Created trigger_changemodel replaces '" + Key + "' -> '" + Value + "'" );
                    }
                }
            }

            UTILS::Trigger( ( g_ClassicMode.IsEnabled() ) ? target_enabled : target_disabled , self, self, USE_TOGGLE, delay );

            SetThink( ThinkFunction( this.Think ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }
            else
            if( g_ClassicMode.IsEnabled() && useType == USE_ON || !g_ClassicMode.IsEnabled() && useType == USE_OFF )
            {
                UTILS::Trigger( target_failed, pActivator, self, useType, delay );
                return;
            }

            g_ClassicMode.SetShouldRestartOnChange( ( self.pev.SpawnFlagBitSet( SF_CCM_RESTART_NOW ) ) ? true : false );

            g_ClassicMode.Toggle();

            UTILS::Trigger( target_toggle, pActivator, self, useType, delay );
        }

        void Think()
        {
            if( g_ClassicMode.IsEnabled() )
            {
                for( uint ui = 0; ui < g_keys.length(); ui++)
                {
                    string Key = string( g_keys[ui] );
                    string Value = string( g_ItemMappings[ Key ] );

                    CBaseEntity@ pEntity = null;
                    CBaseEntity@ pWeapon = null;

                    while( ( @pEntity = g_EntityFuncs.FindEntityByString( pEntity, "model", Key ) ) !is null )
                    {
                        if( pEntity !is null && pEntity.GetCustomKeyvalues().GetKeyvalue( "$i_classic_mode_ignore" ).GetInteger() != 1 )
                        {
                            UTILS::Debug( "[config_classic_mode::Think()] replaced '" + string( pEntity.pev.model ) + "' -> '" + string( Value ) + "'" );
                            UTILS::Trigger( "CCM_" + Key, pEntity, self, USE_ON, 0.0f );
                        }
                    }

                    if(string( Key ).StartsWith( 'weapon') 
                    or string( Key ).StartsWith( 'item_' )
                    or string( Key ).StartsWith( 'ammo_' ) )
                    {
                        while( ( @pWeapon = g_EntityFuncs.FindEntityByString( pWeapon, "classname", Key ) ) !is null )
                        {
                            if( pWeapon !is null )
                            {
                                UTILS::Debug( "[config_classic_mode::Think()] replaced '" + string( pWeapon.pev.classname ) + "' -> '" + string( Value ) + "'" );
                                g_EntityFuncs.Create( Value, pWeapon.pev.origin, pWeapon.pev.angles, false);
                                g_EntityFuncs.Remove( pWeapon );
                            }
                        }
                    }
                }
            }
            self.pev.nextthink = g_Engine.time + self.pev.health + 0.1f;
        }
    }

    void Register()
    {
        //We want classic mode voting to be enabled here
        g_ClassicMode.EnableMapSupport();
        g_CustomEntityFuncs.RegisterCustomEntity( "config_classic_mode::config_classic_mode", "config_classic_mode" );
    }
}// end namespace