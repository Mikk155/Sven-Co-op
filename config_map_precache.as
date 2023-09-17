#include 'as_register'

namespace config_map_precache
{
    void MapInit()
    {
        m_EntityFuncs.CustomEntity( 'config_map_precache' );

        m_ScriptInfo.SetScriptInfo
        (
            {
                { 'script', 'config_map_precache' },
                { 'description', 'custom_precache expanded.' }
            }
        );
    }

    void MapStart()
    {
        g_CustomEntityFuncs.UnRegisterCustomEntity( 'config_map_precache' );
    }

    class config_map_precache : ScriptBaseEntity
    {
        private string m_iszConfigFile;
        dictionary g_KeyValues;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            g_KeyValues[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_KeyValues.getKeys(); }
        }

        void Precache()
        {
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string Key = string( strKeyValues[ui] );
                string Value = string( g_KeyValues[ Key ] );

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

        void PreSpawn()
        {
            if( !m_iszConfigFile.IsEmpty() )
            {
                m_FileSystem.GetKeyAndValue( 'scripts/maps/' + m_iszConfigFile, g_KeyValues, true );
            }

            BaseClass.PreSpawn();
        }

        void Spawn()
        {
            Precache();

            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                m_Debug.Server( "[config_map_precache] '" + string( g_KeyValues[ string( strKeyValues[ui] ) ] ) + "'" );
            }

            m_Debug.Server( "[config_map_precache] Map precached configuration. Removing entity..." );

            g_EntityFuncs.Remove( self );

            BaseClass.Spawn();
        }
    }
}
