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
        // You can register your own logger but idealy do after the plugin is being propertly registered.
        CLogger@ Logger;

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
        void OnExtensionInit( Hooks::IExtensionInit@ info )
        {
            @Logger = CLogger( "Plugin Example" );
            Logger.info( "Registered \"" + GetName() + "\" at index \"" + info.ExtensionIndex + "\"" );
        }

        /**
        *   Called when all extensions has been initialized. this is the last action in the plugin's PluginInit method.
        **/
        void OnPluginInit( Hooks::IHookInfo@ info )
        {
            Logger.info( "Called OnPluginInit for \"" + GetName() + "\"" );
        }

        void OnMapActivate( Hooks::IMapActivate@ info )
        {
        }

        void OnMapChange( Hooks::IMapChange@ info )
        {
            Logger.info( "Called OnMapChange for \"" + GetName() + "\" to \"" + info.NextMap + "\"" );
        }

        void OnPlayerSay( Hooks::IPlayerSay@ info )
        {
            Logger.info( "Called OnClientSay for \"" + GetName() + "\" to \"" + info.params.GetArguments()[0] + "\"" );
        }
    }
}
