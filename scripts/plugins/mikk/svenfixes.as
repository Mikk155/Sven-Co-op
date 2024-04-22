//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

#include '../../mikk/shared'

// Plugins, you can comment out these to disable
// Or you can also create your own using the same method as these does.
#include 'svenfixes/observer_noises'
#include 'svenfixes/grenade_revivable'
#include 'svenfixes/observer_presence'
#include 'svenfixes/gravity_lost'
#include 'svenfixes/satchel_stun'
#include 'svenfixes/deadplayer_sink'
#include 'svenfixes/tripmine_spam'
#include 'svenfixes/gonome_crouch'
#include 'svenfixes/hwgrunt_crouch'
#include 'svenfixes/longjump_revive'
// Not finished yet.-
//#include 'svenfixes/changelevel_items'

namespace svenfixes
{
    enum ATTACK
    {
        PRIMARY = 1,
        SECONDARY = 2,
        TERTIARY = 3,
    };

    dictionary g_HookData =
    {
        { 'OnPlayerAttack', '' },
        { 'OnMapInit', '' },
        { 'OnMapStart', '' },
        { 'OnMapActivate', '' },
        { 'OnThink', '' },
        { 'OnObserverMode', '' },
        { 'OnPlayerRevive', '' },
        { 'OnPlayerKilled', '' },
        { 'OnPlayerSpawn', '' },
        { 'OnMonsterCheckEnemy', '' },
        { 'OnMapChange', '' },
        { '', '' }
    };

    void InitHook( string &in szHook, string &in szNamespace )
    {
        if( !szHook.IsEmpty() && !szNamespace.IsEmpty() && g_HookData.exists( szHook ) )
        {
            array<string> pHooks = array<string>( g_HookData[ szHook ] );
            pHooks.insertLast( 'svenfixes::' + szNamespace + '::' + szHook );
            g_HookData[ szHook ] = pHooks;
            //g_Game.AlertMessage( at_console, 'Init Hook ' + pHooks[pHooks.length()-1] + '\n' );
        }
    }

    CScheduledFunction@ pThink;

    void Think()
    {
        array<string> Functions = array<string>( g_HookData[ 'OnThink' ] );
        for( uint ui = 0; ui < Functions.length(); ui++ )
            if( g_Reflection[ Functions[ui] ] !is null )
                g_Reflection[ Functions[ui] ].Call();
    }

    // These three has been moved into one, use enum ATTACK
    HookReturnCode WeaponPrimaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
        { OnPlayerAttack( pPlayer, pWeapon, ATTACK::PRIMARY ); return HOOK_CONTINUE; }
    HookReturnCode WeaponTertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
        { OnPlayerAttack( pPlayer, pWeapon, ATTACK::TERTIARY ); return HOOK_CONTINUE; }
    HookReturnCode WeaponSecondaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon )
        { OnPlayerAttack( pPlayer, pWeapon, ATTACK::SECONDARY ); return HOOK_CONTINUE; }

    HookReturnCode OnPlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, ATTACK AttackMode )
    {
        if( pPlayer !is null && pWeapon !is null && AttackMode > 0 )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnPlayerAttack' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pPlayer, @pWeapon, int(AttackMode) );
        }
        return HOOK_CONTINUE;
    }

    // These three has been moved into one, use enum ObserverMode
    HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer )
        { return OnObserverMode( pPlayer, OBS_NONE ); }
    HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer )
        { return OnObserverMode( pPlayer, OBS_ROAMING ); }

    HookReturnCode OnObserverMode( CBasePlayer@ pPlayer, ObserverMode iMode )
    {
        if( pPlayer !is null )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnObserverMode' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pPlayer, int(iMode) );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnPlayerRevive' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pPlayer );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer !is null )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnPlayerKilled' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pPlayer, @pAttacker, iGib );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnPlayerSpawn' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pPlayer );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode MonsterPostCheckEnemy( CBaseMonster@ pMonster, CBaseEntity@ pEnemy )
    {
        if( pMonster !is null && pEnemy !is null )
        {
            array<string> Functions = array<string>( g_HookData[ 'OnMonsterCheckEnemy' ] );
            for( uint ui = 0; ui < Functions.length(); ui++ )
                if( g_Reflection[ Functions[ui] ] !is null )
                    g_Reflection[ Functions[ui] ].Call( @pMonster, @pEnemy );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode MapChange()
    {
        array<string> Functions = array<string>( g_HookData[ 'OnMapChange' ] );
        for( uint ui = 0; ui < Functions.length(); ui++ )
            if( g_Reflection[ Functions[ui] ] !is null )
                g_Reflection[ Functions[ui] ].Call();

        return HOOK_CONTINUE;
    }
}

void MapActivate()
{
    array<string> Functions = array<string>( svenfixes::g_HookData[ 'OnMapActivate' ] );
    for( uint ui = 0; ui < Functions.length(); ui++ )
        if( g_Reflection[ Functions[ui] ] !is null )
            g_Reflection[ Functions[ui] ].Call();
}

void MapInit()
{
    array<string> Functions = array<string>( svenfixes::g_HookData[ 'OnMapInit' ] );
    for( uint ui = 0; ui < Functions.length(); ui++ )
        if( g_Reflection[ Functions[ui] ] !is null )
            g_Reflection[ Functions[ui] ].Call();
}

void MapStart()
{
    array<string> Functions = array<string>( svenfixes::g_HookData[ 'OnMapStart' ] );
    for( uint ui = 0; ui < Functions.length(); ui++ )
        if( g_Reflection[ Functions[ui] ] !is null )
            g_Reflection[ Functions[ui] ].Call();
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );

    g_Hooks.RegisterHook( Hooks::Game::MapChange, @svenfixes::MapChange );
    g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @svenfixes::PlayerSpawn );
    g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @svenfixes::PlayerKilled );
    g_Hooks.RegisterHook( Hooks::Player::PlayerLeftObserver, @svenfixes::PlayerLeftObserver );
    g_Hooks.RegisterHook( Hooks::ASLP::Player::PlayerPostRevive, @svenfixes::PlayerPostRevive );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @svenfixes::WeaponPrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @svenfixes::WeaponTertiaryAttack );
    g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @svenfixes::PlayerEnteredObserver );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @svenfixes::WeaponSecondaryAttack );
    g_Hooks.RegisterHook( Hooks::ASLP::Monster::MonsterPostCheckEnemy, @svenfixes::MonsterPostCheckEnemy );

    Mikk.UpdateTimer( svenfixes::pThink, 'Think', 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );

    g_Reflection.Call( 'PluginInit' );
}
