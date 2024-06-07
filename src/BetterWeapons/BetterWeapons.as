#include "json"

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( 'plugins/mikk/BetterWeapons.json' );

    PluginUpdate();
}

void MapInit()
{
    if( pJson.reload('plugins/mikk/BetterWeapons.json') != 1 )
    {
        PluginUpdate();
    }
}

void PluginUpdate()
{
    g_Hooks.RemoveHook( Hooks::Player::MapChange, @MapChange );
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @MapChange );
    g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @PlayerKilled );
    g_Hooks.RemoveHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @PlayerPostThink );
    g_Hooks.RemoveHook( Hooks::Player::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RemoveHook( Hooks::Player::WeaponTertiaryAttack, @WeaponTertiaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack );
    g_Hooks.RemoveHook( Hooks::Player::WeaponSecondaryAttack, @WeaponSecondaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );
}

enum ATTACK
{
    PRIMARY = 1,
    SECONDARY = 2,
    TERTIARY = 3,
};

HookReturnCode MapChange()
{
    return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::PRIMARY ); return HOOK_CONTINUE; }
HookReturnCode WeaponTertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::TERTIARY ); return HOOK_CONTINUE; }
HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { OnPlayerAttack( pPlayer, pWeapon, ATTACK::SECONDARY ); return HOOK_CONTINUE; }
HookReturnCode OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
{
    if( pPlayer is null || pWeapon is null )
        return HOOK_CONTINUE;

    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    return HOOK_CONTINUE;
}

HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    return HOOK_CONTINUE;
}
