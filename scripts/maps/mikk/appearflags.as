#include 'utils/CGetInformation'
#include 'utils/Reflection'

namespace appearflags
{
    void Register()
    {
        g_Scheduler.SetTimeout( "RemoveMatched", 0.0f );
        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'appearflags' ) +
            g_ScriptInfo.Description( 'Allow to configurate Entitie\'s appearence status' ) +
            g_ScriptInfo.Wiki( 'appearflags' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    void RemoveMatched()
    {
        for( int eidx = 0; eidx < g_Engine.maxEntities; ++eidx ) 
        {
            CBaseEntity@ pEntity = g_EntityFuncs.Instance( eidx );
            
            if( pEntity !is null )
            {
                if( AppearFlags( pEntity ) )
                {
                    g_EntityFuncs.Remove( pEntity );
                }
            }
        }
    }

    enum appearflags
    {
        NO_AFFECT = 0,
        NOT_IN = 1,
        ONLY_IN = 2
    }

    bool AppearFlags( CBaseEntity@ pEntity )
    {
        if( iValue( pEntity, 'classicmode' ) == NOT_IN && g_ClassicMode.IsEnabled() )
        {
            return true;
        }
        else if( iValue( pEntity, 'classicmode' ) == ONLY_IN && !g_ClassicMode.IsEnabled() )
        {
            return true;
        }
        return false;
    }
    
    int iValue( CBaseEntity@ pEntity, const string iszKey )
    {
        return pEntity.GetCustomKeyvalues().GetKeyvalue( '$i_appearflags_' + iszKey ).GetInteger();
    }
}