#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_autosave_custom
{
    void Register()
    {
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @trigger_autosave_custom::ClientPutInServer );
        g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @trigger_autosave_custom::PlayerSpawn );
        g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @trigger_autosave_custom::PlayerKilled );
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_autosave_custom::trigger_autosave_custom", "trigger_autosave_custom" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_autosave_custom' ) +
            g_ScriptInfo.Description( 'Attempt to create the mechanic of trigger_autosave with co-op in mind.' ) +
            g_ScriptInfo.Wiki( 'trigger_autosave_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            for( uint i = 0; i < g_AutoSave.PlayersStatus.length(); i++ )
            {
                if( string( g_AutoSave.PlayersStatus[i][ 'player' ] ) == g_AutoSave.GetSteamID( pPlayer ) )
                {
                    return HOOK_CONTINUE;
                }
            }
            dictionary g_PlayerStatus;
            g_PlayerStatus[ 'player' ] = g_AutoSave.GetSteamID( pPlayer );

            g_AutoSave.PlayersStatus.insertLast( g_PlayerStatus );
            
            if( g_SurvivalMode.IsEnabled() )
            {
                g_Scheduler.SetTimeout( "SpawnPlayer", 1.0f, @pPlayer );
            }
        }
        return HOOK_CONTINUE;
    }
    
    void SpawnPlayer( CBasePlayer@ pPlayer )
    {
        g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer !is null )
        {
            if( g_SurvivalMode.IsEnabled() && g_AutoSave.GetSave( pPlayer ) > 0 )
            {
                g_Util.SetCKV( pPlayer, '$i_tas_zone', g_AutoSave.GetSave( pPlayer ) - 1 );
                g_Scheduler.SetTimeout( "SpawnPlayer", 1.0f, @pPlayer );
            }
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            for( uint i = 0; i < g_AutoSave.PlayersStatus.length(); i++ )
            {
                if( string( g_AutoSave.PlayersStatus[i][ 'player' ] ) == g_AutoSave.GetSteamID( pPlayer ) )
                {
                    if( g_AutoSave.GetSave( pPlayer ) >= 0 )
                    {
                        g_AutoSave.LoadStatus( pPlayer, g_AutoSave.PlayersStatus[i] );
                    }
                }
            }
        }
        return HOOK_CONTINUE;
    }

    class trigger_autosave_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        void Touch( CBaseEntity@ pOther )
        {
            Save( pOther );
        }
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float fldelay )
        {
            Save( pActivator );
        }

        private array<string> m_iszSteamIDs;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return BaseClass.KeyValue( szKey, szValue );
        }

        bool HasBeenSaved( CBasePlayer@ pPlayer )
        {
            for( uint i = 0; i < m_iszSteamIDs.length(); i++ )
            {
                if( m_iszSteamIDs[i] == g_AutoSave.GetSteamID( pPlayer ) )
                {
                    return true;
                }
            }
            return false;
        }

        void Save( CBaseEntity@ pTarget )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( pTarget );

            if( pPlayer !is null && !HasBeenSaved( pPlayer ) )
            {
                // For survival mode
                g_Util.SetCKV( pPlayer, '$i_tas_zone', g_AutoSave.GetSave( pPlayer ) + 1 );

                m_iszSteamIDs.insertLast( g_AutoSave.GetSteamID( pPlayer ) );
                g_AutoSave.SaveStatus( pPlayer );
                g_Util.Trigger( pPlayer, self, USE_TOGGLE, 0.0f );
            }
        }

        void Spawn()
        {
            self.pev.solid = SOLID_TRIGGER;
            // self.pev.effects |= EF_NODRAW;
            self.pev.movetype = MOVETYPE_NONE;

            SetBoundaries();

            BaseClass.Spawn();
        }
    }
}

CAutoSave g_AutoSave;

final class CAutoSave
{
    array<dictionary> PlayersStatus;

    string GetSteamID( CBasePlayer@ pPlayer )
    {
        return string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );
    }

    int GetSave( CBasePlayer@ pPlayer )
    {
        return atoi( g_Util.GetCKV( pPlayer, '$i_tas_zone' ) );
    }

    void SaveStatus( CBasePlayer@ pPlayer )
    {
        for( uint i = 0; i < g_AutoSave.PlayersStatus.length(); i++ )
        {
            if( string( g_AutoSave.PlayersStatus[i][ 'player' ] ) == g_AutoSave.GetSteamID( pPlayer ) )
            {
                g_AutoSave.PlayersStatus[i][ 'origin' ] = pPlayer.pev.origin.ToString();
                g_AutoSave.PlayersStatus[i][ 'angles' ] = pPlayer.pev.angles.ToString();
                g_AutoSave.PlayersStatus[i][ 'health' ] = string( pPlayer.pev.health );
                g_AutoSave.PlayersStatus[i][ 'armorvalue' ] = string( pPlayer.pev.armorvalue );
            }
        }
    }

    void LoadStatus( CBasePlayer@ pPlayer, dictionary g_Values )
    {
        pPlayer.pev.origin = g_Util.StringToVec( string( g_Values[ 'origin' ] ) );
        pPlayer.pev.angles = g_Util.StringToVec( string( g_Values[ 'angles' ] ) );
        pPlayer.pev.health = atoi( string( g_Values[ 'health' ] ) );
        pPlayer.pev.armorvalue = atoi( string( g_Values[ 'armorvalue' ] ) );
    }
}