/*

// INSTALLATION:

#include "mikk/game_stealth"

*/
#include "../beast/respawndead_keepweapons"
namespace player_reequipment
{
    void ScriptInfo()
    {
        g_Information.SetInformation
        ( 
            'Script: game_debug\n' +
            'Description: Entity wich when fired, shows a debug message, also shows other entities being triggered..\n' +
            'Author: Mikk\n' +
            'Discord: ' + g_Information.GetDiscord( 'mikk' ) + '\n'
            'Server: ' + g_Information.GetDiscord() + '\n'
            'Github: ' + g_Information.GetGithub()
        );
    }

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "game_debug::CBaseDebug", "game_debug" );
    }

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