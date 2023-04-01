/*
Github page: https://github.com/Mikk155/Sven-Co-op/

Require:
- utils.as

Usage: https://github.com/Mikk155/Sven-Co-op/blob/main/develop/information/entities/config_english.md#config_map_precache
*/
#include "utils"
namespace config_map_precache
{
	bool Register = g_Util.CustomEntity( 'config_map_precache::config_map_precache','config_map_precache' );

    class config_map_precache : ScriptBaseEntity, ScriptBaseCustomEntity
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

            g_Util.Debug( "[config_map_precache] Precaching..." );

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                g_Util.Debug( "'" + string( g_PrecacheKeys[ string( strKeyValues[ui] ) ] ) + "'" );
            }

            g_Util.Debug( "[config_map_precache] Map precached configuration. Removing entity..." );

            g_EntityFuncs.Remove( self );

            BaseClass.Spawn();
        }
    }
}
// End of namespace