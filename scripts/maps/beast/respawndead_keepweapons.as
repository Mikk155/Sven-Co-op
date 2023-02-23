/*
respawndead_keepweapons
Adds a feature for trigger_respawn to let dead players respawn with the weapons they collected when they died, instead of losing them
Option to keep ammo as well

Install:-
Put the script file into "scripts/maps/beast" then either
- put "map_script respawndead_keepweapons" to your map cfg
OR
-Add this as a trigger_script
"classname" "trigger_script"
"m_iszScriptFile" "respawndead_keepweapons"
OR
-Include it in your main map script header
#include "beast/respawndead_keepweapons"

Usage:-
- make your trigger_respawn, check the flag "Respawn dead" then 
- check flag box 4 (value 8)- this is the new flag to allow the trigger_respawn to let dead respawning players keep their weapons they had when they died
- To keep ammo, check box 5 (value 16)
*/
namespace RESPAWNDEAD_KEEPWEAPONS
{

enum respawndead_flags
{
    KEEP_WEAPONS    = 8,
    KEEP_AMMO       = 16
};

CScheduledFunction@ fnPatchTriggerRespawn = g_Scheduler.SetTimeout( "PatchTriggerRespawn", 0.0f );
bool blPlayerKilled = g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, PlayerKilled );
array<dictionary> DICT_PLAYER_LOADOUT( g_Engine.maxClients + 1 );

void PatchTriggerRespawn()
{
    dictionary dictDeadRespawner =
    {
        { "m_iszScriptFunctionName", "RESPAWNDEAD_KEEPWEAPONS::RespawnDead" },
        { "m_iMode", "1" },
        { "targetname", "ts_dead_respawner" }
    };
    
    CBaseEntity@ pEntity;

    while( ( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "trigger_respawn" ) ) !is null ) )
    {
        if( pEntity is null )
            continue;

        if( pEntity.pev.SpawnFlagBitSet( 1 << 1 ) && pEntity.pev.SpawnFlagBitSet( KEEP_WEAPONS ) )
        {
            pEntity.pev.spawnflags &= ~( 1 << 0 | 1 << 1 );// disable respawn dead setting, trigger_script will do this now
            pEntity.pev.target = string( dictDeadRespawner["targetname"] );
        }
    }

    g_EntityFuncs.CreateEntity( "trigger_script", dictDeadRespawner );
}
// Replace trigger_respawn's dead respawner with our own
void RespawnDead(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
    for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); iPlayer++ )
    {
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

        if( pPlayer is null || !pPlayer.IsConnected() || pPlayer.IsAlive() )
            continue;

        g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );
        ReEquipCollected( pPlayer, pCaller !is null ? pCaller.pev.SpawnFlagBitSet( KEEP_AMMO ) : false );
    }
}
// Players get their old loadout when they died
void ReEquipCollected(EHandle hPlayer, bool blKeepAmmo = false)
{
    if( !hPlayer )
        return;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );
    array<string> STR_LOADOUT_WEAPONS = DICT_PLAYER_LOADOUT[pPlayer.entindex()].getKeys();

    for( uint i = 0; i < STR_LOADOUT_WEAPONS.length(); i++ )
    {
        if( STR_LOADOUT_WEAPONS[i] == "" || pPlayer.HasNamedPlayerItem( STR_LOADOUT_WEAPONS[i] ) !is null )
            continue;

        pPlayer.GiveNamedItem( STR_LOADOUT_WEAPONS[i] ); // Would be nice if this returned the actual item ptr....
        CBasePlayerWeapon@ pEquippedWeapon = cast<CBasePlayerWeapon@>( pPlayer.HasNamedPlayerItem( STR_LOADOUT_WEAPONS[i] ) );

        if( pEquippedWeapon is null )
            continue;

        if( blKeepAmmo && !FIsNoAmmoWpn( pEquippedWeapon ) )
            pPlayer.m_rgAmmo( pEquippedWeapon.m_iPrimaryAmmoType, int( DICT_PLAYER_LOADOUT[pPlayer.entindex()][STR_LOADOUT_WEAPONS[i]] ) );
    }

    DICT_PLAYER_LOADOUT[pPlayer.entindex()] = dictionary();
}
// Save player loadout upon death
HookReturnCode PlayerKilled(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    DICT_PLAYER_LOADOUT[pPlayer.entindex()] = dictionary();

    for( uint i = 0; i < MAX_ITEM_TYPES; i++ )
    {
        CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>( pPlayer.m_rgpPlayerItems( i ) );

        while( pWeapon !is null )
        {
            DICT_PLAYER_LOADOUT[pPlayer.entindex()][pWeapon.GetClassname()] = FIsNoAmmoWpn( pWeapon ) ? 0 : pPlayer.m_rgAmmo( pWeapon.m_iPrimaryAmmoType );
            @pWeapon = cast<CBasePlayerWeapon@>( pWeapon.m_hNextItem.GetEntity() );
        }
    }

    return HOOK_CONTINUE;
}

bool FIsNoAmmoWpn(CBasePlayerWeapon@ pWeapon)
{
    if( pWeapon is null )
        return false;

    const array<string> NO_AMMO_WPNS =
    {
        "weapon_crowbar",
        "weapon_hlcrowbar",
        "weapon_knife",
        "weapon_medkit"//technically it does use ammo but lets pretend it doesn't
    };

    return( NO_AMMO_WPNS.find( pWeapon.GetClassname() ) >= 0 );
}

}
