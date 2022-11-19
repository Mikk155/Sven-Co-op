/*
	This entity doesn't exactly follow the logics from SoHL.
	It is more like spawn the dummy env_sound for every player connected and attach it to him.
	Then change its roomtype when the player touch the trigger_sound.
    
	Also there is another additions (more for myself) the posibility to trigger the entity and apply it globaly or for activator only.

INSTALL:

#include "mikk/trigger_sound"

void MapInit()
{
	RegisterCBaseDSPSound();
}
*/

#include "utils"

void RegisterCBaseDSPSound() 
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CBaseDSPSound", "trigger_sound" );
    g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @DSPDisconnect );
    g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @DSPPutInServer );
	g_Scheduler.SetInterval( "DSPSOUNDTHINK", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES);
}

class CBaseDSPSound : ScriptBaseEntity, UTILS::MoreKeyValues
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
        if( multisource() )
        {
            self.pev.nextthink = g_Engine.time + 0.1f;
            return;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, string( pPlayer.pev.netname ) );

        if( pDSPSound !is null )
        {
            g_EntityFuncs.DispatchKeyValue( pDSPSound.edict(), "roomtype", roomtype );
            g_EntityFuncs.FireTargets( pPlayer.pev.netname, pPlayer, pPlayer, USE_ON );
        }
    }

    void Spawn()
    {
        self.pev.solid = SOLID_NOT;
        self.pev.effects |= EF_NODRAW;
        self.pev.movetype = MOVETYPE_NONE;

        UTILS::SetSize( self, false );

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

            if( UTILS::InsideZone( pPlayer, self ) )
            {
                ModifyDSPSound( pPlayer );
            }
        }
        self.pev.nextthink = g_Engine.time + 0.1f;
    }
}

HookReturnCode DSPDisconnect( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
    {
        return HOOK_CONTINUE;
    }

    CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, string( pPlayer.pev.netname ) );

    if( pDSPSound !is null )
    {
        g_EntityFuncs.Remove( pDSPSound );
    }

    return HOOK_CONTINUE;
}

HookReturnCode DSPPutInServer( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
    {
        return HOOK_CONTINUE;
    }

    CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, string( pPlayer.pev.netname ) );

    if( pDSPSound is null )
    {
        dictionary DSPS;
        DSPS [ "radius" ] = "100";
        DSPS [ "roomtype" ] = "0";
        DSPS [ "targetname" ] =  string( pPlayer.pev.netname );
        g_EntityFuncs.CreateEntity( "env_sound", DSPS, true );
    }

    return HOOK_CONTINUE;
}

void DSPSOUNDTHINK()
{
    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if(pPlayer is null or !pPlayer.IsConnected() )
        {
            continue;
        }

        CBaseEntity@ pDSPSound = g_EntityFuncs.FindEntityByTargetname( pDSPSound, string( pPlayer.pev.netname ) );

        if( pDSPSound !is null )
        {
            pDSPSound.SetOrigin( pPlayer.pev.origin );
        }
    }
}

