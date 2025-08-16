/**
*   Include any plugin by name in here.
*   For example: #include "PluginExample/main"
*
*   Then go to RegisterExtensions() and add the plugin's name
*   For example: g_MKExtensionManager::Register( PluginExample::GetName() );
*
*   The order of addition of plugins is important for priority. plugins added first will have priority over later ones.
**/

#include "PluginExample/main"

namespace Extensions
{
    void RegisterExtensions()
    {
        g_MKExtensionManager.Register( PluginExample::GetName() );
    }
}
