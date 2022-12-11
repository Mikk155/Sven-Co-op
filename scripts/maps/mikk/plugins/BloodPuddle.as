/*
DOWNLOAD:

models/mikk/misc/bloodpuddle.mdl
scripts/maps/mikk/env_bloodpuddle.as
scripts/maps/mikk/plugins/BloodPuddle.as


INSTALL:

    "plugin"
    {
        "name" "BloodPuddle"
        "script" "../maps/mikk/plugins/BloodPuddle"
    }
*/

#include "../env_bloodpuddle"

void MapInit()
{
    env_bloodpuddle::Register();
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nAuthor: Gaftherman"
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
        "\nDescription: Generates a blood puddle when a monster die."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\ngithub.com/Gaftherman"
        "\ngithub.com/Mikk155"
    );
}