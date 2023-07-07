#include 'utils/CGetInformation'
#include 'utils/Reflection'

namespace appearflags
{
    void Register()
    {
        g_Scheduler.SetTimeout( "AppearFlags", 0.0f );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'appearflags' ) +
            g_ScriptInfo.Description( 'Allow to configurate Entitie\'s appearence status' ) +
            g_ScriptInfo.Wiki( 'appearflags' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    // Allow for trigger_script
    void Match( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        AppearFlags();
    }

    void AppearFlags()
    {
        for( int eidx = g_PlayerFuncs.GetNumPlayers() + 1; eidx < g_EngineFuncs.NumberOfEntities(); ++eidx ) 
        {
            CBaseEntity@ pEntity = g_EntityFuncs.Instance( eidx );
            
            if( pEntity is null )
            {
                continue;
            }

            if( FlagClassicMode( pEntity ) || FlagSurvivalMode( pEntity ) )
            {
                g_EntityFuncs.Remove( pEntity );
            }
        }
    }

    enum ef_appearflags
    {
        NO_AFFECT = 0,
        NOT_IN = 1,
        ONLY_IN = 2
    }

    bool FlagClassicMode( CBaseEntity@ pEntity )
    {
        if(iValue( pEntity, 'classicmode' ) == NOT_IN && g_ClassicMode.IsEnabled()
        or iValue( pEntity, 'classicmode' ) == ONLY_IN && !g_ClassicMode.IsEnabled() )
        {
            return true;
        }
        return false;
    }

    bool FlagSurvivalMode( CBaseEntity@ pEntity )
    {
        int iSurvival = int( g_EngineFuncs.CVarGetFloat( 'mp_survival_supported' ) ) + int( g_EngineFuncs.CVarGetFloat( 'mp_survival_starton' ) );

        if(iValue( pEntity, 'survivalmode' ) == NOT_IN && iSurvival == 2
        or iValue( pEntity, 'survivalmode' ) == ONLY_IN && iSurvival < 2 )
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