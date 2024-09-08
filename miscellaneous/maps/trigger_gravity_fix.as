#include '../../maps/mikk/as_utils'

namespace trigger_gravity_fix
{
    void MapInit()
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerRevive, @trigger_gravity_fix::PlayerPostRevive );
        g_Hooks.RegisterHook( Hooks::Player::PlayerKilled, @trigger_gravity_fix::PlayerKilled );
    }

    HookReturnCode PlayerKilled( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
    {
        if( pPlayer !is null && pPlayer.pev.gravity != 1.0f )
        {
            g_EntityFuncs.DispatchKeyValue( pPlayer.edict(), '$f_fix_lost_gravity', pPlayer.pev.gravity );
        }
        return HOOK_CONTINUE;
    }

    HookReturnCode PlayerPostRevive( CBasePlayer@ pPlayer )
    {
        float fGravity;
        m_CustomKeyValue.GetValue( pPlayer, '$f_fix_lost_gravity', fGravity );

        if( pPlayer !is null && fGravity != 1.0f && fGravity > 0.0f )
        {
            pPlayer.pev.gravity = fGravity;
        }
        return HOOK_CONTINUE;
    }
}