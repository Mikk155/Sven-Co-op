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

void print( string s ){ g_Game.AlertMessage( at_console, s + '\n' );}

#include "../../mikk/json"
#include "../../mikk/Reflection"

// Removable scripts
#include "BetterWeapons/weapon_sporelauncher"

json pJson;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    pJson.load( 'plugins/mikk/BetterWeapons.json' );

    g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @PrimaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @SecondaryAttack );
    g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @TertiaryAttack );
}

HookReturnCode PrimaryAttack(  CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { PlayerAttack( pPlayer, pWeapon, 1 ); return HOOK_CONTINUE; }
HookReturnCode SecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { PlayerAttack( pPlayer, pWeapon, 2 ); return HOOK_CONTINUE; }
HookReturnCode TertiaryAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon ) { PlayerAttack( pPlayer, pWeapon, 3 ); return HOOK_CONTINUE; }

void MapInit()
{
    pJson.reload( 'plugins/mikk/BetterWeapons.json' );

    g_Reflection.Call( 'MapInit' );
}

HookReturnCode PlayerAttack( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int uiAttackType )
{
    if( pPlayer is null || pWeapon is null || pWeapon.m_fInReload )
        return HOOK_CONTINUE;

    json Data = json( pJson[ pWeapon.GetClassname() ] );

    if( !bool( Data[ 'enable' ] ) )
        return HOOK_CONTINUE;

    switch( uiAttackType )
    {
        case 1:
        {
            if( !Data.exists( 'Primary Attack' ) || g_Engine.time < pWeapon.m_flNextPrimaryAttack || pWeapon.m_iClip == 0 )
                break;

            if( pWeapon.GetClassname() == 'weapon_sporelauncher'
            and g_Reflection[ 'weapon_sporelauncher::PrimaryAttack' ] !is null ) {
                g_Reflection[ 'weapon_sporelauncher::PrimaryAttack' ].Call( @pPlayer, @pWeapon, json( Data[ 'Primary Attack' ] ) );
            }

            break;
        }
        case 2:
        {
            if( !Data.exists( 'Secondary Attack' ) || g_Engine.time < pWeapon.m_flNextSecondaryAttack || pWeapon.m_iClip == 0 )
                break;

            if( pWeapon.GetClassname() == 'weapon_sporelauncher'
            and g_Reflection[ 'weapon_sporelauncher::SecondaryAttack' ] !is null ) {
                g_Reflection[ 'weapon_sporelauncher::SecondaryAttack' ].Call( @pPlayer, @pWeapon, json( Data[ 'Secondary Attack' ] ) );
            }

            break;
        }
        case 3:
        {
            if( !Data.exists( 'Tertiary Attack' ) || g_Engine.time < pWeapon.m_flNextTertiaryAttack || pWeapon.m_iClip == 0 )
                break;

            if( pWeapon.GetClassname() == 'weapon_sporelauncher'
            and g_Reflection[ 'weapon_sporelauncher::TertiaryAttack' ] !is null ) {
                g_Reflection[ 'weapon_sporelauncher::TertiaryAttack' ].Call( @pPlayer, @pWeapon, @json( Data[ 'Tertiary Attack' ] ) );
            }

            break;
        }
    }
    return HOOK_CONTINUE;
}
