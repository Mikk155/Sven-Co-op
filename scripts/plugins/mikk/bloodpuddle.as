//	See https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/bloodpuddle.md

#include "../../maps/mikk/bloodpuddle"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

void MapInit()
{
    RegisterBloodPuddle();
}