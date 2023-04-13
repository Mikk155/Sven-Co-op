#include "utils"

bool trigger_sound_register = g_Util.CustomEntity( 'trigger_sound::trigger_sound','trigger_sound' );
bool ClientDisconnect_register = g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @trigger_sound::ClientDisconnect );
bool ClientPutInServer_register = g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @trigger_sound::ClientPutInServer );

namespace trigger_sound
{
    class trigger_sound : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string roomtype = 0;

        bool KeyValue (const string& in szKey, const string& in szValue)
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
            if( string( self.pev.target ) != "!activator" && pActivator !is null && pActivator.IsPlayer() )
            {
                CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

                ModifyDSPSound( pPlayer );
            }
            else
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        ModifyDSPSound( pPlayer );
                    }
                }
            }
        }

        void ModifyDSPSound( CBasePlayer@ pPlayer )
        {
            CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

            if( pDSPSound !is null && !IsLockedByMaster() )
            {
                g_EntityFuncs.DispatchKeyValue( pDSPSound.edict(), "roomtype", roomtype );
                g_EntityFuncs.FireTargets( "DSP_SOUND_" + g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ), pPlayer, pPlayer, USE_ON );
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

    HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
        {
            return HOOK_CONTINUE;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

        if( pDSPSound !is null )
        {
            g_EntityFuncs.Remove( pDSPSound );
        }

        return HOOK_CONTINUE;
    }

    HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
        {
            return HOOK_CONTINUE;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

        if( pDSPSound is null )
        {
            dictionary DSPS;
            DSPS [ "radius" ] = "100";
            DSPS [ "roomtype" ] = "0";
            DSPS [ "targetname" ] = "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) );
            g_EntityFuncs.CreateEntity( "env_sound", DSPS, true );
        }

        return HOOK_CONTINUE;
    }

    CScheduledFunction@ g_Think = g_Scheduler.SetInterval( "Think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );

    void Think()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if( pPlayer !is null )
            {
                CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) );

                if( pDSPSound !is null )
                {
                    pDSPSound.SetOrigin( pPlayer.pev.origin );
                }
            }
        }
    }
}