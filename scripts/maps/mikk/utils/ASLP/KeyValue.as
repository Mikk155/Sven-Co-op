namespace ASLP_KeyValue
{
    void MapInit()
    {
        // In case it is a plugin
        EntInfo.deleteAll();
        g_Hooks.RegisterHook( Hooks::ASLP::Engine::KeyValue, @ASLP_KeyValue::KeyValue );
    }

    void MapActivate()
    {
        // Remove after everything is initialised because it's useles after Spawn
        g_Hooks.RemoveHook( Hooks::ASLP::Engine::KeyValue, @ASLP_KeyValue::KeyValue );
    }

    string GetKeyValue( uint& in uiEdict, const string& in m_iszKey )
    {
        if( uiEdict == 0 )
        {
            g_Game.AlertMessage( at_error, 'Can\'t access to worldspawn keyvalues!\n' );
        }
        else if( EntInfo.exists( uiEdict ) )
        {
            dictionary pInfo = dictionary( EntInfo[ uiEdict ] );

            if( pInfo.exists( m_iszKey ) )
            {
                return string( pInfo[ m_iszKey ] );
            }
        }
        return String::INVALID_INDEX;
    }

    const array<string> GetKeyValues( uint& in uiEdict, dictionary@ &out m_dValues )
    {
        array<string> m_aKeys;

        if( EntInfo.exists( uiEdict ) )
        {
            m_aKeys = dictionary( EntInfo[ uiEdict ] ).getKeys();
            m_dValues = dictionary( EntInfo[ uiEdict ] );
        }

        return m_aKeys;
    }

    dictionary EntInfo;

    HookReturnCode KeyValue(
        CBaseEntity@ pEntity,
        const string& in m_iszKey,
        const string& in m_iszValue,
        const string& in m_iszClassName,
        META_RES& out meta_result
    ){
        dictionary pInfo;

        if( EntInfo.exists( pEntity.entindex() ) )
        {
            pInfo = dictionary( EntInfo[ pEntity.entindex() ] );
        }

        pInfo[ m_iszKey ] = m_iszValue;

        EntInfo[ pEntity.entindex() ] = pInfo;

        return HOOK_CONTINUE;
    }
}