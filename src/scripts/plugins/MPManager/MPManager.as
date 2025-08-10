/**
*   MPManager aka "Mikk's plugin manager" As for lack of imagination for a name.
*   This plugin works as a loader for other plugins of mine to prevent multiple initialization of different objects.
*   To include any new plugin go to the MPManager/plugins.as and add a new entry.
**/

#include "../../Mikk155/Reflection"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
}
