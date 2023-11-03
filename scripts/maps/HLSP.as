#include "hlsp/trigger_suitcheck"

#include "LimitlessPotential/entities_state"

#include "mikk/env_fog_gradual"

#include "mikk/trigger_manager"

namespace HLSP
{
    void MapInit()
    {
        RegisterTriggerSuitcheckEntity();
        g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
        mk.Hooks.RegisterHook( Hooks::Player::PlayerObserverMode, @PlayerObserverMode );
    }
}

HookReturnCode PlayerObserverMode( CBasePlayer@ pPlayer, ObserverMode m_ObserverMode )
{
    g_Game.AlertMessage( at_console, 'Call Hook' + int( m_ObserverMode ) +'\n' );
    return HOOK_CONTINUE;
}