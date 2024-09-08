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

namespace Hooks {
namespace Player {
/*@
    @prefix Hooks::Player::PlayerAttackHook PlayerAttackHook
    @body Hooks::Player
    Called when a player jumps
*/
namespace PlayerAttackHook
{
    /*@
        @prefix PlayerAttackHook
        Called when a player jumps
    */
    funcdef HookReturnCode PlayerAttackHook( CBasePlayer@, CBasePlayerWeapon@, int );

    array<PlayerAttackHook@> PlayerAttackHooks;

    bool Register( ref @pFunction )
    {
        PlayerAttackHook@ pHook = cast<PlayerAttackHook@>( pFunction );

        if( pHook is null )
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Hooks::Player::PlayerAttackHook( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int uiAttackType ) Not found.\n' );
            return false;
        }
        else
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] Registered Hooks::Player::PlayerAttackHook( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int uiAttackType ).\n' );

            PlayerAttackHooks.insertLast( @pHook );

            if( Hooks::m_bWeaponPrimaryAttackHook == false )
            {
                Hooks::m_bWeaponPrimaryAttackHook = g_Hooks.RegisterHook( Hooks::Weapon::WeaponPrimaryAttack, @Hooks::WeaponPrimaryAttack );
            }

            if( Hooks::m_bWeaponSecondaryAttackHook == false )
            {
                Hooks::m_bWeaponSecondaryAttackHook = g_Hooks.RegisterHook( Hooks::Weapon::WeaponSecondaryAttack, @Hooks::WeaponSecondaryAttack );
            }

            if( Hooks::m_bWeaponTertiaryAttackHook == false )
            {
                Hooks::m_bWeaponTertiaryAttackHook = g_Hooks.RegisterHook( Hooks::Weapon::WeaponTertiaryAttack, @Hooks::WeaponTertiaryAttack );
            }
            return true;
        }
    }

    void Remove( ref @pFunction )
    {
        PlayerAttackHook@ pHook = cast<PlayerAttackHook@>( pFunction );

        if( PlayerAttackHooks.findByRef( pHook ) >= 0 )
        {
            PlayerAttackHooks.removeAt( PlayerAttackHooks.findByRef( pHook ) );
            g_Game.AlertMessage( at_console, '[CMKHooks] Removed hook Hooks::Player::PlayerAttack.\n' );
        }
        else
        {
            g_Game.AlertMessage( at_error, '[CMKHooks] Could not remove Hooks::Player::PlayerAttack.\n' );
        }
        CheckPlayerPrimaryAttackHook();
        CheckPlayerSecondaryAttackHook();
        CheckPlayerTertiaryAttackHook();
    }

    void RemoveAll()
    {
        PlayerAttackHooks.resize( 0 );
        g_Game.AlertMessage( at_console, '[CMKHooks] Removed ALL hooks Hooks::Player::PlayerAttackPlayerAttack.\n' );
        CheckPlayerPrimaryAttackHook();
        CheckPlayerSecondaryAttackHook();
        CheckPlayerTertiaryAttackHook();
    }

    void PlayerAttackFunction( CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon, int uiAttackType )
    {
        if( pPlayer !is null && pWeapon !is null && PlayerAttackHooks.length() > 0 )
        {
            for( uint ui = 0; ui < PlayerAttackHooks.length(); ui++ )
            {
                PlayerAttackHook@ pHook = cast<PlayerAttackHook@>( PlayerAttackHooks[ui] );

                if( pHook !is null && pHook( pPlayer, pWeapon, uiAttackType ) == HOOK_HANDLED )
                {
                    break;
                }
            }
        }
    }
}
}
}