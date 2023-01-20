/*
INFORMATION:
Allow Mappers to control survival mode with new features.


DOWNLOAD:
scripts/maps/mikk/config_survival_mode.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/config_survival_mode"

void MapInit()
{
    config_survival_mode::Register();
}


USAGE:
See our FGD.
*/

#include "utils"

float
 mp_respawndelay,
  mp_survival_startdelay;

int
 mp_dropweapons,
  mp_survival_supported;

bool SurvivalMode = false;

namespace config_survival_mode
{
    void Register()
    {
        // Enable map support-
        g_SurvivalMode.EnableMapSupport();

        // Get current server's cvars
        mp_survival_supported = g_EngineFuncs.CVarGetFloat( "mp_survival_supported" );
        mp_respawndelay = g_EngineFuncs.CVarGetFloat( "mp_respawndelay" );
        mp_survival_startdelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );
        mp_dropweapons = g_EngineFuncs.CVarGetFloat( "mp_dropweapons" );

        // Tell the script what was the state of survival mode
        SurvivalMode = ( mp_survival_supported == 1 ) ? true : false;

        // Activates survival to use our own modes.
        g_SurvivalMode.Enable();
            g_SurvivalMode.Activate( true );
                g_SurvivalMode.SetStartOn( true );
                    g_SurvivalMode.SetDelayBeforeStart( 0.0f );
                        CBaseCustomSurvivalMode::DropWeapons( 0, 0.0f );
                            CBaseCustomSurvivalMode::DropWeapons( 1, mp_survival_startdelay );

        g_Scheduler.SetInterval( "CBaseCustomSurvivalMode::Think", 1.0f, g_Scheduler.REPEAT_INFINITE_TIMES );

        g_CustomEntityFuncs.RegisterCustomEntity( "config_survival_mode::config_survival_mode", "config_survival_mode" );
    }

    class config_survival_mode : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        private bool
            survival_starton = false,
                survival_lockdrop = false,
                    survival_countdown = false,
                        survival_allowroam = false,
                            survival_suddenly = false;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);
            if( szKey == "survival_starton" ) survival_starton = atobool( szValue );
            else if( szKey == "survival_lockdrop" ) survival_lockdrop = atobool( szValue );
            else if( szKey == "survival_countdown" ) survival_countdown = atobool( szValue );
            else if( szKey == "survival_allowroam" ) survival_allowroam = atobool( szValue );
            else if( szKey == "survival_suddenly" ) survival_suddenly = atobool( szValue );
            else return BaseClass.KeyValue( szKey, szValue );
            return true;
        }

        void Spawn()
        {
            if( survival_starton && mp_survival_supported == 1 )
            {
                SurvivalMode = true;
            }
            else
            {
                SurvivalMode = false;
            }

            mp_dropweapons = survival_lockdrop;

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( master() )
            {
                return;
            }

            if( useType == USE_ON )
            {
                SurvivalMode = true;
            }
            else if( useType == USE_OFF )
            {
                SurvivalMode = false;
            }
            else if( useType == USE_TOGGLE )
            {
                SurvivalMode = !SurvivalMode;
            }

            CBaseCustomSurvivalMode::DropWeapons( int( SurvivalMode ), 0.0f );
        }
    }

}// end namespace

namespace CBaseCustomSurvivalMode
{
    void DropWeapons( const int imode, const float delay )
    {
        if( mp_dropweapons == 1 )
        {
            dictionary g_keyvalues;
            g_keyvalues [ "m_iszCVarToChange" ] = "mp_dropweapons";
            g_keyvalues [ "message" ] = string( imode );
            g_keyvalues [ "targetname" ] = "doweneedanamehere?";
            g_keyvalues [ "SetType" ] = "0";
            CBaseEntity@ pSetDrop = g_EntityFuncs.CreateEntity( "trigger_setcvar", g_keyvalues, true );

            if( pSetDrop !is null )
            {
                pSetDrop.Use( null, null, USE_ON, delay );
                g_EntityFuncs.Remove( pSetDrop );
            }
        }
    }

    void Think()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer is null )
                continue;

            if( survival_allowroam )
            {
                pPlayer.GetObserver().SetMode( OBS_CHASE_FREE );
                pPlayer.GetObserver().SetObserverModeControlEnabled( false );
            }

            // Survival mode is enabled.
            if( SurvivalMode )
            {
            }
            else
            {
                if( survival_countdown )
                {
                    // Mostrar mensajes de startdelay
                }

                CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
                int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_survivaln_t").GetInteger();

                if( kvSpawnIs >= 0 )
                {
                    if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
                    {
                        // Decrease dead player respawndelay's countdown
                        ckvSpawns.SetKeyvalue("$i_survivaln_t", kvSpawnIs - 1 );
                    }
                }
                else
                {
                    // Revive the player and set his next respawndelay
                    g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
                    ckvSpawns.SetKeyvalue("$i_survivaln_t", int( mp_respawndelay ) );
                }
            }
        }
    }
}