//	See https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/DupeFix.md

#include "../../maps/mikk/DupeFix"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155" );
}

void MapInit()
{
    CSurvival::AmmoDupeFix( true, true, true );
}