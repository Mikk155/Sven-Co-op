/**
*   MPManager aka "Mikk's plugin manager" As for lack of imagination for a name.
*   This plugin works as a loader for other plugins of mine to prevent multiple initialization of different objects.
*   To include any new plugin go to the MPManager/plugins.as and add a new entry.
**/

#include "../../Mikk155/Logger"
#include "../../Mikk155/Reflection"

#include "IPlugin"
#include "plugins"
#include "PluginManager"

CLogger g_Logger( "MPManager", true );

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    Logger::RegisterConCommands();

    RegisterAllPlugins();

    g_MPManager.PluginInit();
}
