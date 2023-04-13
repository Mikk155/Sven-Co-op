#include "../beast/respawndead_keepweapons"
namespace player_reequipment
{
    bool keep_ammo = true;
    bool player_reequipment_register = g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @player_reequipment::PlayerReEquip );

    HookReturnCode PlayerReEquip( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, keep_ammo );
        }
        return HOOK_CONTINUE;
    }
}