#include 'as_register'

namespace appearflags
{
    void Meta( int i )
    {
        // Un-comment if you're using Gaftherman's Limitless Potential AngelScript Extended Metamod plugin.
        ///*
        switch(i)
        {
            case 0:
                g_Hooks.RegisterHook( Hooks::ASLP::Engine::KeyValue, @appearflags::KeyValue );
                    Metamod = true;
                        break;
            case 1:
                g_Hooks.RemoveHook( Hooks::ASLP::Engine::KeyValue, @appearflags::KeyValue );
                    break;
        }
        //*/
    }

    enum APPEARFLAGS_FLAGS
    {
        APPEARFLAGS_NO_AFFECT = 0,
        APPEARFLAGS_NOT_IN = 1,
        APPEARFLAGS_ONLY_IN = 2
    }

    bool Metamod;
    void MapInit()
    {
        Meta( 0 );
    }

    HookReturnCode KeyValue( CBaseEntity@ pEntity, const string& in pszKey, const string& in pszValue, const string& in szClassName, META_RES& out meta_result )
    {
        if( pszKey.StartsWith( '$i_appearflags_' ) && atoi( pszValue ) > 0  )
        {
            eidx.insertLast( pEntity.entindex() );
        }
        return HOOK_CONTINUE;
    }

    array<int> eidx;

    void MapActivate()
    {
        CBaseEntity@ pEntity = null;

        if( Metamod )
        {
            for( uint i = 0; i < eidx.length(); i++ )
                CheckEntity( g_EntityFuncs.Instance( eidx[i] ) );
        }
        else
        {
            for( int i = g_Engine.maxClients + 2; i <= g_EngineFuncs.NumberOfEntities(); ++i ) 
                CheckEntity( g_EntityFuncs.Instance( i ) );
        }

        Meta( 1 );
    }

    void CheckEntity( CBaseEntity@ pEntity )
    {
        if( pEntity is null )
            return;

        switch( atoi( pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_appearflags_classicmode' ).GetString() ) )
        {
            case APPEARFLAGS_NOT_IN:
            {
                if( g_ClassicMode.IsEnabled() )
                    g_EntityFuncs.Remove( pEntity );
                break;
            }
            case APPEARFLAGS_ONLY_IN:
            {
                if( !g_ClassicMode.IsEnabled() )
                    g_EntityFuncs.Remove( pEntity );
                break;
            }
        }

        bool SurvivalIsActive = ( int( g_EngineFuncs.CVarGetFloat( 'mp_survival_supported' ) ) + int( g_EngineFuncs.CVarGetFloat( 'mp_survival_starton' ) ) == 2 );

        switch( atoi( pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_appearflags_survivalmode' ).GetString() ) )
        {
            case APPEARFLAGS_NOT_IN:
            {
                if( SurvivalIsActive )
                    g_EntityFuncs.Remove( pEntity );
                break;
            }
            case APPEARFLAGS_ONLY_IN:
            {
                if( !SurvivalIsActive )
                    g_EntityFuncs.Remove( pEntity );
                break;
            }
        }
    }
}