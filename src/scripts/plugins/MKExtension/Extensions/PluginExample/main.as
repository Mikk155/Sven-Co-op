#if VSC_EXTENSION
#include "../../main"
#endif

namespace Extensions
{
    namespace PluginExample
    {
        CLogger@ Logger;

        string GetName()
        {
            return "PluginExample";
        }

        void OnExtensionInit( Hooks::IExtensionInit@ info )
        {
            @Logger = CLogger( "Plugin Example" );
            Logger.info( "Registered \"" + GetName() + "\" at index \"" + info.ExtensionIndex + "\"" );
        }
    }
}
