#include "json"
#include "Reflection"

#include "BetterWeapons/weapon_9mmhandgun"

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( 'plugins/mikk/BetterWeapons.json' );

    // This for testing, dont need on final release
                    Register();
}

bool Registered;

void MapInit()
{
    if( pJson.reload('plugins/mikk/BetterWeapons.json') != 1 )
    {
        UnRegister();
    }

    if( array<string>( pJson[ 'blacklist maps' ] ).find( string( g_Engine.mapname ) ) > 0 )
    {
        UnRegister();
        return;
    }

    if( !Registered )
    {
        Register();
    }
}

void UnRegister()
{
    g_Hooks.RemoveHook( Hooks::Game::MapChange, @OnMapChange );
    g_Hooks.RemoveHook( Hooks::Player::PlayerKilled, @OnPlayerKilled );
    g_Hooks.RemoveHook( Hooks::Player::PlayerPostThink, @OnPlayerPostThink );
    g_Hooks.RemoveHook( Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RemoveHook( Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack );
    g_Hooks.RemoveHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );
    Registered = false;
}

void Register()
{
    g_Hooks.RegisterHook( Hooks::Game::MapChange, @OnMapChange );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @OnPlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @OnPlayerPostThink );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack );
    Registered = true;
}

enum ATTACK
{
    PRIMARY = 1,
    SECONDARY = 2,
    TERTIARY = 3,
};

enum ReflectionHook
{
    NONE = 0,
    HOOK_HANDLED = 1
};

HookReturnCode OnMapChange()
{
    return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { return OnPlayerAttack( pPlayer, pWeapon, ATTACK::PRIMARY ); }
HookReturnCode WeaponTertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { return OnPlayerAttack( pPlayer, pWeapon, ATTACK::TERTIARY ); }
HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { return OnPlayerAttack( pPlayer, pWeapon, ATTACK::SECONDARY ); }
HookReturnCode OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
{
    if( pPlayer is null || pWeapon is null || pWeapon.m_fInReload )
        return HOOK_CONTINUE;

    Reflection::Function@ href = g_Reflection[ "BetterWeapons::" + pWeapon.GetClassname() + "::OnPlayerAttack" ];

    if( href !is null )
    {
        HookReturnCode bHooking = HOOK_CONTINUE;

        Reflection::ReturnValue@ pValue = href.Call( @pPlayer, @pWeapon, int(AttackMode) );

        int ibits = 0;
        if( pValue.HasReturnValue() )
        {
            pValue.ToAny().retrieve( ibits );
        }

        if( ibits != 0 )
        {
            ReflectionHook bits = ReflectionHook( ibits );

            if( ( bits & ReflectionHook::HOOK_HANDLED ) != 0 )
            {
                bHooking = HOOK_HANDLED;
            }
        }
        return bHooking;
    }

    return HOOK_CONTINUE;
}

HookReturnCode OnPlayerPostThink( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    CBaseEntity@ pItem = pPlayer.m_hActiveItem.GetEntity();
    CBasePlayerWeapon@ pWeapon = ( pItem !is null ? cast<CBasePlayerWeapon@>( pItem ) : null );

    if( pWeapon !is null )
    {
        if( g_Reflection[ "BetterWeapons::" + pWeapon.GetClassname() + "::OnPlayerPostThink" ] !is null )
            g_Reflection[ "BetterWeapons::" + pWeapon.GetClassname() + "::OnPlayerPostThink" ].Call( @pPlayer, @pWeapon );
    }

    return HOOK_CONTINUE;
}

HookReturnCode OnPlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

    return HOOK_CONTINUE;
}
