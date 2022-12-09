/*
DOWNLOAD:

scripts/maps/mikk/game_level_config.as
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

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);
            g_ItemMappings[ szKey ] = szValue;
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
                        g_Game.AlertMessage( at_console, "[config_classic_mode::Precache()] Precached model '" + Value + "'\n" );
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
                        g_Game.AlertMessage( at_console, "[config_classic_mode::Spawn()] Created trigger_changemodel replaces '" + Key + "' -> '" + Value + "' \n" );
                    }
                }
            }

            UTILS::Trigger( ( g_ClassicMode.IsEnabled() ) ? self.pev.noise1 : self.pev.noise2 , self, self, USE_TOGGLE, 0.0f );

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
                UTILS::Trigger( self.pev.message, pActivator, self, useType, 0.0f );
                return;
            }

            g_ClassicMode.SetShouldRestartOnChange( ( self.pev.SpawnFlagBitSet( SF_CCM_RESTART_NOW ) ) ? true : false );

            g_ClassicMode.Toggle();

            UTILS::Trigger( self.pev.target, pActivator, self, useType, 0.0f );
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
                            g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, "[config_classic_mode::Think()] replaced '" + string( pEntity.pev.model ) + "' -> '" + string( Value ) + "' \n" );
                            UTILS::Trigger( "CCM_" + Key, pEntity, self, USE_ON, 0.0f );
                        }
                    }

                    while( ( @pWeapon = g_EntityFuncs.FindEntityByString( pWeapon, "classname", Key ) ) !is null )
                    {
                        if( pWeapon !is null )
                        {
                            g_PlayerFuncs.ClientPrintAll( HUD_PRINTCONSOLE, "[config_classic_mode::Think()] replaced '" + string( pWeapon.pev.classname ) + "' -> '" + string( Value ) + "' \n" );
                            g_EntityFuncs.Create( Value, pWeapon.pev.origin, pWeapon.pev.angles, false);
                            g_EntityFuncs.Remove( pWeapon );
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