#include "../../scripts/mikk155/meta_api/json/v1/tests"
#include "../../scripts/mikk155/meta_api/json/v2/tests"

#include "../../test/angelscript/preprocessors"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

#if METAMOD_PLUGIN_ASLP
#if LINUX
    g_Game.AlertMessage( at_console, "aslp.so is installed in the server.\n" );
#endif
#if WINDOWS
    g_Game.AlertMessage( at_console, "aslp.dll is installed in the server.\n" );
#endif
#endif
    g_Game.AlertMessage( at_console, "meta_api::IsInstalled(): " + ( meta_api::IsInstalled() ? "True" : "False" ) + "\n" );
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

    // Constructors registers the tests
    meta_api::json::v1::Test();
    meta_api::json::v2::Test();

    // Enable debug messages
//    meta_api::json::debug = true;

    // Run all json tests
    meta_api::json::tests::StartAll();
}
