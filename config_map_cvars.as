#include 'as_register'

namespace config_map_cvars
{
    void MapInit()
    {
        m_EntityFuncs.CustomEntity( 'config_map_cvars' );

        m_ScriptInfo.SetScriptInfo
        (
            {
                { 'script', 'config_map_cvars' },
                { 'description', 'trigger_setcvar expanded.' }
            }
        );
    }

    void Remove()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, 'config_map_cvars' ) ) !is null )
        {
            pEntity.Use( null, null, USE_OFF, 0.0f );
        }

        g_CustomEntityFuncs.UnRegisterCustomEntity( 'config_map_cvars' );
    }

    enum config_map_cvars_spawnflags
    {
        START_ON = 1,
        STORE_CVARS = 2
    }

    class config_map_cvars : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string m_iszConfigFile;
        dictionary g_KeyValues;
        dictionary dictOldCvars;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            g_KeyValues[ szKey ] = szValue;
            return true;
        }

        const array<string> strKeyValues
        {
            get const { return g_KeyValues.getKeys(); }
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( !IsLockedByMaster() )
            {
                for(uint ui = 0; ui < strKeyValues.length(); ui++)
                {
                    string m_iszKey = string( strKeyValues[ui] );
                    string m_iszValue = string( g_KeyValues[ m_iszKey ] );

                    Store( m_iszKey );

                    g_EngineFuncs.CVarSetString( m_iszKey, ( useType == USE_OFF ) ? string( dictOldCvars[ m_iszKey ] ) : m_iszValue );
                    m_Debug.Server( "[config_map_cvars] " + m_iszKey + ": '" + string( g_EngineFuncs.CVarGetString( m_iszKey ) ) + "'" );
                }
            }
        }
        
        void Store( string m_iszKey )
        {
            if( spawnflag( STORE_CVARS ) )
            {
                string cvar;
                m_CustomKeyValue.GetValue( self, '$s_' + m_iszKey, cvar );
                m_Debug.Server( "[config_map_cvars] Stored " + m_iszKey + ": '" + string( g_EngineFuncs.CVarGetString( m_iszKey ) ) + "' as '$s_" + m_iszKey );
            }
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
            if( spawnflag( START_ON ) )
            {
                self.Use( null, null, USE_TOGGLE, 0.5f );
            }

            // Fix for cvars with not default value
            for(uint ui = 0; ui < strKeyValues.length(); ui++)
            {
                string m_iszKey = string( strKeyValues[ui] );

                if( m_iszKey == 'mp_pcbalancing_factorlist' or m_iszKey == 'mp_disable_pcbalancing' )
                {
                    if( g_EngineFuncs.CVarGetString( 'mp_pcbalancing_factorlist' ).IsEmpty() )
                    {
                        dictOldCvars[ m_iszKey ] = '0';
                        continue;
                    }
                }
                else if( m_iszKey == 'mp_forcespawn' && g_EngineFuncs.CVarGetString( 'mp_forcespawn' ).IsEmpty() )
                {
                    dictOldCvars[ m_iszKey ] = '0';
                }
                else
                {
                    dictOldCvars[ m_iszKey ] = g_EngineFuncs.CVarGetString( m_iszKey );
                }

                Store( m_iszKey );


                m_Debug.Server( "[config_map_cvars] Stored " + m_iszKey + ": '" + string( dictOldCvars[ m_iszKey ] ) + "'" );
            }

            BaseClass.Spawn();
        }
    }
}
