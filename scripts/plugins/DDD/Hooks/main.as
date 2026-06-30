#include "PlayerPostThink"
#include "PlayerRevived"

namespace Hooks
{
    void Register()
    {
        g_Hooks.RegisterHook( Player::PlayerRevived, @PlayerRevived );
        g_Hooks.RegisterHook( Player::PlayerPostThink, @PlayerPostThink );

#if METAMOD_PLUGIN_ASLP
#endif
    }
}
