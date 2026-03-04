/**
*   @brief Common metamod utilities
**/

namespace meta_api
{
    /**
    *   @brief Return whatever metamod's "aslp" plugin is installed in the server
    *   You can use the pre-processor "METAMOD_PLUGIN_ASLP" to know that. That is escentially what this method does.
    **/
    const bool IsInstalled()
    {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return true;
#endif
        return false;
    }

    /**
    *   @brief Notice the server if metamod's "aslp" plugin is not installed
    **/
    void NoticeInstallation()
    {
        if( !IsInstalled() )
        {
            string buffer;
            snprintf( buffer, "[Error] %1 requires metamod plugin \"aslp\" to work.\n", g_Module.GetModuleName() );
            g_EngineFuncs.ServerPrint( buffer );
            g_EngineFuncs.ServerPrint( "Some features may work poorly or not work at all.\n" );
            g_EngineFuncs.ServerPrint( "Install metamod at: https://github.com/Mikk155/Sven-Co-op\n" );
        }
    }
}
