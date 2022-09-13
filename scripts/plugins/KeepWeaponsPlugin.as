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