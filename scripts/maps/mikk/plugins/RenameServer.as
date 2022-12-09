/*
DOWNLOAD:

scripts/maps/mikk/plugins/RenameServer.as


INSTALL:

    "plugin"
    {
        "name" "RenameServer"
        "script" "../maps/mikk/plugins/RenameServer"
    }
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nAuthor: Gaftherman"
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
        "\nDescription: Changes your server's hostname dynamicaly depending the map playing."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\ngithub.com/Mikk155"
        "\ngithub.com/Gaftherman"
    );
}

// Name of your server
const string strHostname = "[US] Limitless Potential (Hardcore + Anti-Rush)";

// < name of your map        |        title of your hostname >

string[][] strMaps = 
{
    {"hl", "Half-Life"},

    {"rp", "Residual Point"},

    {"rl_", "Residual Life"},

    {"ast_", "A Soldier's Tale"},

    {"tln_", "The Long Night"},

    {"accesspoint", "Access Point"},

    {"bridge_the_gap", "Bridge The Gap"},

    {"bm_sts", "BM: Special Tactics"},

    {"ba", "Blue-Shift"},

    {"hcl", "Hardcore-Life"},

    {"of", "Opposing-Force"}
};

// Your server's hostname will look like "[US] Limitless Potential (Hardcore + Anti-Rush) Playing Opposing-Force"

void MapInit()
{
    for(uint i = 0; i < strMaps.length(); i++)
    {
        if(string(g_Engine.mapname).StartsWith(strMaps[i][0]))
        {
            g_EngineFuncs.ServerCommand("hostname \"" + strHostname + " Playing " + strMaps[i][1] +"\"\n");
            break;
        }
        else
        {
            g_EngineFuncs.ServerCommand("hostname \"" + strHostname + "\"\n");
        }
    }
    g_EngineFuncs.ServerExecute();
}