#include "../maps/mikk/env_bloodpuddle"
void MapInit()
{
    env_bloodpuddle::Register( false );
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