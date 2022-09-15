void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
	
	g_Scheduler.SetInterval( "EntityCreate", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

array<string> Items = { "weapon_*", "item_healthkit", "item_battery", "weaponbox", "ammo_*" }; // May affect ammo_individual as well.

void EntityCreate()
{
	for( uint i = 0; i < Items.length(); ++i )
	{
		CBaseEntity@ pEntity = null;
		while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, Items[i] ) ) !is null)
		{
			// Check if the flag is null before updating it. prevents players unable to take items for first time.
			// And prevent mapper's choice for UseOnly + Touch only
			if( pEntity.pev.spawnflags == "0" )
			{
				pEntity.pev.spawnflags = 256;
			}
		}
	}
}