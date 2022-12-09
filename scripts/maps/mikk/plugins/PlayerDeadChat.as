/*
DOWNLOAD:

scripts/maps/mikk/player_deadchat.as
scripts/maps/mikk/plugins/PlayerDeadChat.as


INSTALL:

	"plugin"
	{
		"name" "PlayerDeadChat"
		"script" "../maps/mikk/plugins/PlayerDeadChat"
	}
*/

#include "../player_deadchat"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
        "\nDescription: Make dead player's messages readable for dead players only."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\ngithub.com/Mikk155"
    );
}