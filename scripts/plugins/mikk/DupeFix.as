/*
	INSTALL:

	"plugin"
	{
		"name" "DupeFix"
		"script" "mikk/DupeFix"
	}

*/
#include "../../maps/mikk/callbacks"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Mikk" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

// Call GM::DupeFixSurvivalOff( true, true, true );
// Change the true to false for disable the next features in order
// The first argument defines Show/hide survival mode countdown messages
// The second argument defines Block drop weapons while survival is Off
// The third argument defines Do a blip noise when survival is enabled
void MapInit()
{
	CTriggerScripts::DupeFixSurvivalOff( true, true, true );
}