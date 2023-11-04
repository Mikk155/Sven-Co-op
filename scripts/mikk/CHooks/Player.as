#include "Player/PlayerJumpHook"
#include "Player/PlayerKeyInputHook"
#include "Player/PlayerFlashLightHook"
#include "Player/PlayerObserverModeHook"


namespace Hooks
{
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