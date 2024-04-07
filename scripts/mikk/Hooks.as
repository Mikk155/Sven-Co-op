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

#include 'Hooks/Player'
#include "Hooks/Game"

namespace Hooks
{
    namespace Player
    {
        enum Player_e
        {
            PlayerKeyInput = 0,
            PlayerFlashLight,
            PlayerJump,
            PlayerObserverMode,
            CONST
        }
    }

    namespace Game
    {
        enum Game_e
        {
            SurvivalEndRound = Player::CONST
        }
    }

    bool m_bPlayerPreThinkHook = false;

    HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
    {
        if( pPlayer !is null )
        {
            Hooks::Player::PlayerJumpHook::PlayerJumpFunction( pPlayer );
            Hooks::Player::PlayerKeyInputHook::PlayerKeyInputFunction( pPlayer );
            Hooks::Player::PlayerFlashLightHook::PlayerFlashLightFunction( pPlayer );
            Hooks::Player::PlayerObserverModeHook::PlayerObserverModeFunction( pPlayer );
        }
        return HOOK_CONTINUE;
    }

    void CheckPlayerPreThinkHook()
    {
        if( Hooks::Player::PlayerKeyInputHook::PlayerKeyInputHooks.length() < 1
        or Hooks::Player::PlayerFlashLightHook::PlayerFlashLightHooks.length() < 1
        or Hooks::Player::PlayerJumpHook::PlayerJumpHooks.length() < 1
        or Hooks::Player::PlayerObserverModeHook::PlayerObserverModeHooks.length() < 1 )
        {
            g_Hooks.RemoveHook( Hooks::Player::PlayerPreThink, @Hooks::PlayerPreThink );
        }
    }
}

class MKHooks
{
    /*
        @prefix Mikk.Hooks.RegisterHook Hooks CustomHooks RegisterHooks
        @body Mikk.Hooks
        Register a custom hook
    */
    bool RegisterHook( const int& in iHookID, ref @fn )
    {
        if( fn is null )
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] ref@ fn Null Pointer.\n' );
            return false;
        }

        // -2 Select your enum and register
        switch( iHookID )
        {
            case   Hooks::Player::PlayerKeyInput:
            return Hooks::Player::PlayerKeyInputHook::Register( fn );

            case   Hooks::Player::PlayerFlashLight:
            return Hooks::Player::PlayerFlashLightHook::Register( fn );

            case   Hooks::Player::PlayerJump:
            return Hooks::Player::PlayerJumpHook::Register( fn );

            case   Hooks::Player::PlayerObserverMode:
            return Hooks::Player::PlayerObserverModeHook::Register( fn );

            case   Hooks::Game::SurvivalEndRound:
            return Hooks::Game::SurvivalEndRoundHook::Register( fn );

            default:
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            return false;
        }
        return false;
    }

    /*
        @prefix Mikk.Hooks.RemoveHooks Hooks CustomHooks RemoveHook
        @body Mikk.Hook
        Remove a custom hook
    */
    void RemoveHook( const int& in iHookID, ref @function )
    {
        if( function is null )
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] ref@ fn Null Pointer.\n' );
            return;
        }

        switch( iHookID )
        {
            case Hooks::Player::PlayerKeyInput:
                 Hooks::Player::PlayerKeyInputHook::Remove( function );
            break;

            case Hooks::Player::PlayerFlashLight:
                 Hooks::Player::PlayerFlashLightHook::Remove( function );
            break;

            case Hooks::Player::PlayerJump:
                 Hooks::Player::PlayerJumpHook::Remove( function );
            break;

            case Hooks::Player::PlayerObserverMode:
                 Hooks::Player::PlayerObserverModeHook::Remove( function );
            break;

            case Hooks::Game::SurvivalEndRound:
                 Hooks::Game::SurvivalEndRoundHook::Remove( function );
            break;

            default:
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            break;
        }
    }

    /*
        @prefix Mikk.Hooks.RemoveHooks Hooks CustomHooks RemoveHooks
        @body Mikk.Hooks
        Remove all custom hook
    */
    void RemoveHook( const int& in iHookID )
    {
        switch( iHookID )
        {
            case Hooks::Player::PlayerKeyInput:
                 Hooks::Player::PlayerKeyInputHook::RemoveAll();
            break;

            case Hooks::Player::PlayerFlashLight:
                 Hooks::Player::PlayerFlashLightHook::RemoveAll();
            break;

            case Hooks::Player::PlayerJump:
                 Hooks::Player::PlayerJumpHook::RemoveAll();
            break;

            case Hooks::Player::PlayerObserverMode:
                 Hooks::Player::PlayerObserverModeHook::RemoveAll();
            break;

            case Hooks::Game::SurvivalEndRound:
                 Hooks::Game::SurvivalEndRoundHook::RemoveAll();
            break;

            default:
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            break;
        }
    }
}