/*
DOWNLOAD:

scripts/maps/mikk/plugins/NoAutoPick.as


INSTALL:

    "plugin"
    {
        "name" "NoAutoPick"
        "script" "../maps/mikk/plugins/NoAutoPick"
    }
*/

void MapInit()
{
    g_Scheduler.SetInterval( "EntityCreate", 0.1f, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
        "\nDescription: Make items/weapons pick-able only if pressing E-key."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\ngithub.com/Mikk155"
    );
}

array<string> Items = { "weapon_*", "item_healthkit", "item_battery", "weaponbox", "ammo_*" };

void EntityCreate()
{
    for( uint i = 0; i < Items.length(); ++i )
    {
        CBaseEntity@ pEntity = null;
        while((@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, Items[i] ) ) !is null)
        {
            if( pEntity is null || pEntity.pev.spawnflags != "0" )
                continue;
            pEntity.pev.spawnflags = 256;
        }
    }
}