/**
*   Include any plugin by name in here.
*   For example: #include "FastRestart/main"
*
*   Then go to RegisterAllPlugins() and add the plugin's Register method with the namespace of the plugin name'
*   For example: FastRestart::Register();
*
*   The order of addition of plugins is important for priority. plugins added first will have priority over later ones.
**/

#include "PluginExample/main"

namespace plugins
{
void RegisterAllPlugins()
{
    PluginExample::Register();
}
}