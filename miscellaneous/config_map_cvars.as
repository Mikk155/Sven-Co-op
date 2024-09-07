#include 'as_register'

namespace config_map_cvars
{
    void MapInit()
    {
        mk.EntityFuncs.CustomEntity( 'config_map_cvars' );
    }

    void UnRegister()
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
                }
            }
        }
        
        void Store( string m_iszKey )
        {
            if( spawnflag( STORE_CVARS ) )
            {
                g_EntityFuncs.DispatchKeyValue( self.edict(), '$s_' + m_iszKey, m_iszKey );
            }
        }

        void PreSpawn()
        {
            if( !m_iszConfigFile.IsEmpty() )
            {
                mk.FileManager.GetKeyAndValue( 'scripts/maps/' + m_iszConfigFile, g_KeyValues, true );
            }

            BaseClass.PreSpawn();
        }

        void Spawn()
        {
            if( spawnflag( START_ON ) )
            {
                self.Use( null, null, USE_TOGGLE, 0.5f );
            }

            // Fix for cvars without default value
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
            }

            BaseClass.Spawn();
        }
    }
}
