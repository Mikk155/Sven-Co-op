#include "utils"
#include "utils/customentity"

namespace config_map_precache
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'config_map_precache::config_map_precache','config_map_precache' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'config_map_precache' ) +
            g_ScriptInfo.Description( 'Allow to precache anything' ) +
            g_ScriptInfo.Wiki( 'config_map_precache' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    class config_map_precache : ScriptBaseEntity
    {
        dictionary g_PrecacheKeys;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            g_PrecacheKeys[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_PrecacheKeys.getKeys(); }
        }

        void Precache()
        {
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( g_PrecacheKeys[ Key ] );

                if( Key.StartsWith( 'model' ) )
                {
                    g_Game.PrecacheModel( Value );
                    g_Game.PrecacheGeneric( Value );
                }
                else if( Key.StartsWith( 'entity' ) )
                {
                    g_Game.PrecacheOther( Value );
                }
                else if( Key.StartsWith( 'sound' ) )
                {
                    g_Game.PrecacheGeneric( 'sound/' + Value );
                    g_SoundSystem.PrecacheSound( Value );
                }
                else if( Key.StartsWith( 'generic' ) )
                {
                    g_Game.PrecacheGeneric( Value );
                }
            }

            BaseClass.Precache();
        }

        void Spawn()
        {
            Precache();

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                g_Util.Debug( "[config_map_precache] '" + string( g_PrecacheKeys[ string( strKeyValues[ui] ) ] ) + "'" );
            }

            g_Util.Debug( "[config_map_precache] Map precached configuration. Removing entity..." );

            g_EntityFuncs.Remove( self );

            BaseClass.Spawn();
        }
    }
}