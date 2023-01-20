/*
DOWNLOAD:

models/mikk/misc/bloodpuddle.mdl
scripts/maps/mikk/env_bloodpuddle.as
scripts/plugins/mikk/BloodPuddle.as


INSTALL:

    "plugin"
    {
        "name" "BloodPuddle"
        "script" "BloodPuddle"
    }
*/

#include "../maps/mikk/env_bloodpuddle"

void MapInit()
{
    // Optional function 1 you can set true if you want the blood puddle to be removed when the monster fades
    // Optional function 2 you can set a custom model of your own
    env_bloodpuddle::Register();
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nGitub: github.com/Mikk155"
        "\nAuthor: Gaftherman"
        "\nGitub: github.com/Gaftherman"
        "\nDescription: Generates a blood puddle when a monster die."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
    );
}