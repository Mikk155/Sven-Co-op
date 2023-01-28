#include "utils"
namespace config_map_precache
{
    void Register()
    {
        g_Util.ScriptAuthor.insertLast
        (
            "Script: config_map_precache\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Entity that precache almost anything.\n"
        );

        g_CustomEntityFuncs.RegisterCustomEntity( "config_map_precache::entity", "config_map_precache" );
    }

    class entity : ScriptBaseEntity
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

                if( Value == 'model' )
                {
                    g_Game.PrecacheModel( Key );
                }
                else if( Value == 'entity' )
                {
                    g_Game.PrecacheOther( Key );
                }
                else if( Value == 'sound' )
                {
                    g_Game.PrecacheGeneric( 'sound/' + Key );
                    g_SoundSystem.PrecacheSound( Key );
                }
                else if( Value == 'generic' )
                {
                    g_Game.PrecacheGeneric( Key );
                }
            }

            BaseClass.Precache();
        }

        void Spawn()
        {
            g_Scheduler.SetTimeout( this, "Debugger", 3.0f );
            BaseClass.Spawn();
        }

        void Debugger()
        {
            g_Util.DebugMessage( "[config_map_precache] Precaching..." );
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                g_Util.DebugMessage( "'" + Key + "'" );
            }
            g_Util.DebugMessage( "[config_map_precache] Map precached configuration. Removing entity..." );
            g_EntityFuncs.Remove( self );
        }
    }
}
// End of namespace