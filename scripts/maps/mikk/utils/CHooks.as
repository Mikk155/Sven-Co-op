#include 'CHooks/Player'
#include "CHooks/Game"

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
            MapChanged = Player::CONST,
            SurvivalEndRound
        }
    }
}

class CMKHooks
{
    bool RegisterHook( const int& in iHookID, ref @fn )
    {
        if( fn is null )
        {
            g_Game.AlertMessage( at_console, '[CMKHooks] ref@ fn Null Pointer.\n' );
            return false;
        }

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

            case   Hooks::Game::MapChanged:
            return Hooks::Game::MapChangedHook::Register( fn );

            case   Hooks::Game::SurvivalEndRound:
            return Hooks::Game::SurvivalEndRoundHook::Register( fn );

            default:
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            break;
        }
        return false;
    }

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

            case Hooks::Game::MapChanged:
                 Hooks::Game::MapChangedHook::Remove( function );
            break;

            case Hooks::Game::SurvivalEndRound:
                 Hooks::Game::SurvivalEndRoundHook::Remove( function );
            break;

            default:
                g_Game.AlertMessage( at_error, '[CMKHooks] Invalid hook ID.\n' );
            break;
        }
    }

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

            case Hooks::Game::MapChanged:
                 Hooks::Game::MapChangedHook::RemoveAll();
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