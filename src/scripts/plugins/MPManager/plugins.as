/**
*   Include any plugin by name in here.
*   For example: #include "FastRestart/main"
*
*   Then go to RegisterAllPlugins() and add the plugin instance
*   For example: AddPlugin( FastRestart() );
*   "FastRestart" in this case is the name of the class defined in the FastRestart/main.as file.
*
*   The order of addition of plugins is important for priority. plugins added first will have priority over later ones.
**/

#include "FastRestart/main"

void RegisterAllPlugins()
{
    AddPlugin( FastRestart() );
}
