/*
    INSTALL:

    "plugin"
    {
        "name" "NoAutoPick"
        "script" "mikk/NoAutoPick"
    }
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Mikk");
    g_Module.ScriptInfo.SetContactInfo(
	"Github https://github.com/Mikk155
	Discord https://discord.gg/VsNnE3A7j8 \n");
	g_Scheduler.SetInterval( "EntityCreate", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

array<string> Items = { "weapon_*", "item_healthkit", "item_battery", "weaponbox", "ammo_*" };

void EntityCreate()
{
	for( uint i = 0; i < Items.length(); ++i )
	{
		CBaseEntity@ pEntity = null;
		while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, Items[i] ) ) !is null)
		{
			if( pEntity.pev.spawnflags == "0" )
				pEntity.pev.spawnflags = 256;
		}
	}
}