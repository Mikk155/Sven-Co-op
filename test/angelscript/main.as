
#include "../../test/angelscript/json"
#include "../../test/angelscript/preprocessors"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    test::json::PluginInit();
    test::preprocessors::PluginInit();
}
