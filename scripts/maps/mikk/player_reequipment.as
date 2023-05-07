// https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as
#include "../beast/respawndead_keepweapons"

#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace player_reequipment
{
    void Register()
    {
        g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @player_reequipment::PlayerReEquip );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_reequipment' ) +
            g_ScriptInfo.Description( 'Re-Equips players inventory upon respawn' ) +
            g_ScriptInfo.Wiki( 'player_reequipment' ) +
            g_ScriptInfo.Author( 'Outerbeast' ) +
            g_ScriptInfo.GetGithub( 'Outerbeast' )
        );
    }

    bool keep_ammo = true;

    HookReturnCode PlayerReEquip( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, keep_ammo );
        }
        return HOOK_CONTINUE;
    }
}