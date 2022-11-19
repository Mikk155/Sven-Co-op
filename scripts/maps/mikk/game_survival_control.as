/*

INSTALL:

#include "mikk/game_survival_control"

void MapInit()
{
    RegisterGameSurvivalControl();
}
*/

#include "utils"

void RegisterGameSurvivalControl() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseSurvivalEntity", "game_survival_control" );
}

class CBaseSurvivalEntity : ScriptBaseEntity
{
    void Spawn()
    {
        g_EngineFuncs.CVarSetFloat( "mp_survival_supported", 1 );
        g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 0 );

        if( self.pev.frags != 0 )
        {
            CSurvival::AmmoDupeFix
            (
                atobool(self.pev.netname),
                atobool(self.pev.health),
                atobool(self.pev.message),
                ( string(self.pev.target).IsEmpty() ) ?
                g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" ) :
                atof( self.pev.target )
            );
        }

        BaseClass.Spawn();
    }

    void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        switch( useType )
        {
            case USE_ON:
            {
                CSurvival::Enable();
            }
            break;

            case USE_OFF:
            {
                CSurvival::Disable();
            }
            break;

            default:
            {
                g_SurvivalMode.Toggle();
            }
            break;
        }
    }
}

namespace CSurvival
{
    void AmmoDupeFix( const bool blcooldown = true, const bool bDropWeapEnabled = true, const bool ForceChase = true, const float flSurvivalStartDelay = 25.0f )
    {
        if( ForceChase )
        {
            g_Scheduler.SetInterval( "JoinSpectatorThink", 0.3f, g_Scheduler.REPEAT_INFINITE_TIMES );
        }
        if( blcooldown )
        {
            Disable();
            g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
            g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 0 );
            g_Scheduler.SetTimeout( "Enable", flSurvivalStartDelay );
        }
        if( bDropWeapEnabled )
        {
            g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
            g_Scheduler.SetTimeout( "SetDrop", flSurvivalStartDelay );
        }
    }

    void Enable()
    {
        g_SurvivalMode.Enable();
        g_SurvivalMode.Activate( true );
            UTILS::Debug("\nMAP DEBUG-: survival enabled \n\n");
    }

    void Disable()
    {
        g_SurvivalMode.Disable();
            UTILS::Debug("\nMAP DEBUG-: survival disabled \n\n");
    }

    void SetDrop()
    {
        g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 1 );
    }

    void JoinSpectatorThink()
    {
        for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null || pPlayer.IsAlive() || !pPlayer.GetObserver().IsObserver() )
                return;

            pPlayer.GetObserver().SetMode( OBS_CHASE_FREE );
            pPlayer.GetObserver().SetObserverModeControlEnabled( false );
        }
    }
}
