#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_sound
{
    CScheduledFunction@ g_Think = null;

    void Register()
    {
        g_Util.CustomEntity( 'trigger_sound' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_sound' ) +
            g_ScriptInfo.Description( 'Expands env_sound entity.' ) +
            g_ScriptInfo.Wiki( 'trigger_sound' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );

        if( g_Think !is null )
        {
            g_Scheduler.RemoveTimer( g_Think );
        }

        @g_Think = g_Scheduler.SetInterval( "Think", 0.4f);
    }

    class trigger_sound : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string roomtype = 0;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "roomtype" || szKey == "health" )
            {
                roomtype = atof( szValue );
                return true;
            }
            else
                return BaseClass.KeyValue( szKey, szValue );
        }

        void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
        {
            for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer !is null && g_Util.WhoAffected( pPlayer, m_iAffectedPlayer, pActivator ) )
                {
                    ModifyDSPSound( pPlayer );
                }
            }
        }

        void ModifyDSPSound( CBasePlayer@ pPlayer )
        {
            CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

            if( pDSPSound !is null && !IsLockedByMaster() )
            {
                g_EntityFuncs.DispatchKeyValue( pDSPSound.edict(), "roomtype", roomtype );
                g_EntityFuncs.DispatchKeyValue( pDSPSound.edict(), "health", roomtype );
                pDSPSound.Use( pPlayer, pPlayer, USE_ON, 0.0f );
            }
        }

        void Spawn()
        {
            self.pev.solid = SOLID_NOT;
            self.pev.effects |= EF_NODRAW;
            self.pev.movetype = MOVETYPE_NONE;

            SetBoundaries();

            SetThink( ThinkFunction( this.TriggerThink ) );
            self.pev.nextthink = g_Engine.time + 0.1f;

            BaseClass.Spawn();
        }
        
        void TriggerThink() 
        {
            for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
            {
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                if( pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive() )
                    continue;

                if( self.Intersects( pPlayer ) )
                {
                    ModifyDSPSound( pPlayer );
                }
            }
            self.pev.nextthink = g_Engine.time + 0.1f;
        }
    }

    CBaseEntity@ g_GetDSP( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            string m_iszPlayerID = 'DSP_SOUND_' + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );

            CBaseEntity@ DSP = g_EntityFuncs.FindEntityByTargetname( null, m_iszPlayerID );

            if( DSP is null )
            {
                dictionary DSPS;
                DSPS [ "radius" ] = "100";
                DSPS [ "roomtype" ] = "0";
                DSPS [ "targetname" ] = "DSP_SOUND_" + m_iszPlayerID;
                g_EntityFuncs.CreateEntity( "env_sound", DSPS, true );
                return null;
            }
            return DSP;
        }
        return null;
    }

    void Think()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null )
            {
                CBaseEntity@ pDSPSound = g_GetDSP( pPlayer );

                if( pDSPSound !is null )
                {
                    pDSPSound.SetOrigin( pPlayer.pev.origin );
                }
            }
        }
    }
}
