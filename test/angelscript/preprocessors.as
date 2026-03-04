#include "../../scripts/mikk155/meta_api/core"

namespace test
{
    namespace preprocessors
    {
        void PluginInit()
        {
            g_Game.AlertMessage( at_console, "Is metamod installed? " + ( meta_api::IsInstalled() ? "True" : "False" ) + "\n" );

            meta_api::NoticeInstallation();

#if METAMOD_DEBUG
            g_Game.AlertMessage( at_console, "We are on a debug build of metamod\n" );
#endif

#if METAMOD_RELEASE
            g_Game.AlertMessage( at_console, "We are on a Release build of metamod\n" );
#endif

#if LINUX
            g_Game.AlertMessage( at_console, "We are on linux\n" );
#endif

// Both WINDOWS and WIN32 are the same.
#if WINDOWS
            g_Game.AlertMessage( at_console, "We are on windows\n" );
#endif
        }
    }
}