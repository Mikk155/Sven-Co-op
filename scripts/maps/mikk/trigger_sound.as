/*
DOWNLOAD:

scripts/maps/mikk/trigger_sound.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/trigger_sound"

void MapInit()
{
    trigger_sound::Register();
}
*/

#include "utils"

namespace trigger_sound
{
    class TriggerSoundEntity : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        private string roomtype = 0;

        bool KeyValue (const string& in szKey, const string& in szValue)
        {
            ExtraKeyValues(szKey, szValue);

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
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
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
            CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( pPlayer.pev.netname ) );

            if( pDSPSound !is null && !master() )
            {
                g_EntityFuncs.DispatchKeyValue( pDSPSound.edict(), "roomtype", roomtype );
                g_EntityFuncs.FireTargets( "DSP_SOUND_" + pPlayer.pev.netname, pPlayer, pPlayer, USE_ON );
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

    HookReturnCode TriggerSoundDisconnectHook( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
        {
            return HOOK_CONTINUE;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( pPlayer.pev.netname ) );

        if( pDSPSound !is null )
        {
            g_EntityFuncs.Remove( pDSPSound );
        }

        return HOOK_CONTINUE;
    }

    HookReturnCode TriggerSoundConnectHook( CBasePlayer@ pPlayer )
    {
        if( pPlayer is null )
        {
            return HOOK_CONTINUE;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( pPlayer.pev.netname ) );

        if( pDSPSound is null )
        {
            dictionary DSPS;
            DSPS [ "radius" ] = "100";
            DSPS [ "roomtype" ] = "0";
            DSPS [ "targetname" ] = "DSP_SOUND_" + string( pPlayer.pev.netname );
            g_EntityFuncs.CreateEntity( "env_sound", DSPS, true );
        }

        return HOOK_CONTINUE;
    }

    void TriggerSoundThink()
    {
        for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
        {
            CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

            if(pPlayer is null or !pPlayer.IsConnected() )
            {
                continue;
            }

            CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, "DSP_SOUND_" + string( pPlayer.pev.netname ) );

            if( pDSPSound !is null )
            {
                pDSPSound.SetOrigin( pPlayer.pev.origin );
            }
        }
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_sound::TriggerSoundEntity", "trigger_sound" );
        g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @TriggerSoundDisconnectHook );
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @TriggerSoundConnectHook );
        g_Scheduler.SetInterval( "TriggerSoundThink", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES);
    }
}// end namespace