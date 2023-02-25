#include "../beast/respawndead_keepweapons"
#include "utils"
namespace player_reequipment
{
	bool bKeepAmmo = true;

    CScheduledFunction@ g_Renders = g_Scheduler.SetTimeout( "AutoRegister", 0.0f );

    void AutoRegister()
    {
		g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, @PlayerSpawn );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: player_reequipment\n"
            "Author: Outerbeast\n"
            "Github: github.com/Outerbeast\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Re-spawning players gets it's weapon's they had at the moment they died.\n"
        );
    }
	
	void KeepAmmo( bool blKeepAmmo = true )
	{
		bKeepAmmo = blKeepAmmo;
	}

	HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
	{
		if( pPlayer !is null )
		{
        	RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, bKeepAmmo );
		}
		return HOOK_CONTINUE;
	}
}
// End of namespace