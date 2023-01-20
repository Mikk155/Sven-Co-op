/*
DOWNLOAD:

scripts/plugins/mikk/RenameServer.as


INSTALL:

    "plugin"
    {
        "name" "RenameServer"
        "script" "RenameServer"
    }
*/

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor
    (
        "Mikk"
        "\nithub: github.com/Mikk155"
        "\nAuthor: Gaftherman"
        "\nithub: github.com/Gaftherman"
        "\nDescription: Changes your server's hostname dynamicaly depending the map playing."
    );
    g_Module.ScriptInfo.SetContactInfo
    (
        "\nDiscord: https://discord.gg/VsNnE3A7j8"
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

    {"of_utbm", "Under The Black Moon"},

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