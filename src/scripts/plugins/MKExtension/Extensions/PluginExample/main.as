// Is obligatory to work under the "Extensions" namespace.
namespace Extensions
{
    namespace PluginExample
    {
        // This is obligatory and must be the namespace in string form.
        string GetName()
        {
            return "PluginExample";
        }

        void Register()
        {
            // This register all the hooks in this namespace.
            // Returns the index of registration of this space if needed to notice server ops to update the installation hierarchy.
            // Returns -1 on any failure and the namespace is ignored and marked as disabled.
            // in such case you can still make use of the current context method to handle stuff
            int index = g_MKExtensionManager.RegisterHooks( GetName() );
        }

        void OnPluginInit( HookInfo@ info )
        {
            g_Logger.debug( "Called plugins::PluginExample::OnPluginInit" );

            // Update the hook's post action if needed
            // info.code = ( HookCode::Break );
        }

        void OnMapActivate( HookInfoMapActivate@ info )
        {
        }
    }
}
