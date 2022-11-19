/*
INSTALL:

    "plugin"
    {
        "name" "RenameServer"
        "script" "mikk/RenameServer"
    }
*/

// Name of your server
const string strHostname = "[US] Limitless Potential (Hardcore + Anti-Rush)";

// < name of your map		|		title of your hostname >

string[][] strMaps = 
{
	{"hl",				"Half-Life"},

	{"rp",				"Residual Point"},

	{"rl_",				"Residual Life"},

	{"ast_",			"A Soldier's Tale"},

	{"tln_",			"The Long Night"},

	{"accesspoint",		"Access Point"},

	{"bridge_the_gap",	"Bridge The Gap"},

	{"bm_sts",			"BM: Special Tactics"},

	{"ba",				"Blue-Shift"},

	{"hcl",				"Hardcore-Life"},

	{"of",				"Opposing-Force"}
};

// Your server's hostname will look like "[US] Limitless Potential (Hardcore + Anti-Rush) Playing Opposing-Force"

string strTittle = "";

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk & Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo
	(
		"Mikk: https://github.com/Mikk155
		Gaftherman: https://github.com/Gaftherman
		Discord: https://discord.gg/VsNnE3A7j8 \n"
	);
}

void MapInit()
{
	for(uint i = 0; i < strMaps.length(); i++)
	{
		if(string(g_Engine.mapname).StartsWith(strMaps[i][0]))
		{
			strTittle = " Playing " + strMaps[i][1];
			break;
		}
		else
		{
			strTittle = "";
		}
	}
}

void MapActivate()
{
	g_EngineFuncs.ServerCommand("hostname \""+ strHostname + strTittle +"\"\n");
	g_EngineFuncs.ServerExecute();
}