// Is obligatory to work under the "Extensions" namespace.
namespace Extensions
{
    /**
    *   All the HookInfo arguments provided by the hooks supports:
    *   code: bitwise
    *       HookCode::Continue = 0
    *           Continue calling other extensions normally
    *       HookCode::Break = 1
    *           Stop calling other extensions
    *       HookCode::Handle = ( 1 << 1 )
    *           Handle vanilla and metamod plugins. equivalent to HOOK_HANDLED
    *       HookCode::Supercede = ( 1 << 2 )
    *           Handle the original game's call (metamod API only)
    **/
    namespace PluginExample
    {
        /**
        *   This is obligatory and must be the namespace in string form.
        **/
        string GetName()
        {
            return "PluginExample";
        }

        /**
        *   Called when the extension is initialized
        *   @info
        *       ExtensionIndex: Contains the index for the current extension if needed to notice server ops to update the installation hierarchy.
        **/
        void OnExtensionInit( Hooks::InfoExtensionInit@ info )
        {
            info.ExtensionIndex;
        }

        /**
        *   Called whenall extensions has been initialized. this is the last action in the plugin's PluginInit method.
        **/
        void OnPluginInit( Hooks::Info@ info )
        {
                g_Logger.warn( "Called OnPluginInit for \"" + GetName() + "\"" );
        }

        void OnMapActivate( Hooks::InfoMapActivate@ info )
        {
        }
    }
}
