/*
	When respawn keep your collected weapons that you've take before die.

	"plugin"
	{
		"name" "KeepWeaponsPlugin"
		"script" "KeepWeaponsPlugin"
	}
	
	in svencoop/scripts/maps/ Requires you to install https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as
*/

#include "../maps/respawndead_keepweapons"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Outerbeast" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as" );
}

void MapInit()
{
	g_Hooks.RegisterHook( Hooks::Player::PlayerSpawn, PlayerSpawn );
}

HookReturnCode PlayerSpawn( CBasePlayer@ pPlayer )
{
    if( pPlayer is null )
        return HOOK_CONTINUE;

	RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, true );

	return HOOK_CONTINUE;
}