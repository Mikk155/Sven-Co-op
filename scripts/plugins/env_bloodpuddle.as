#include "../maps/mikk/env_bloodpuddle"
void MapInit()
{
    env_bloodpuddle::Register();
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Gaftherman"
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
    );
}