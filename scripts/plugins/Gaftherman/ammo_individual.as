#include "../../maps/gaftherman/misc/ammo_individual"

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Gaftherman" );
	g_Module.ScriptInfo.SetContactInfo( "https://github.com/Gaftherman | https://github.com/Mikk155/Sven-Co-op" );
}


void MapInit()
{
	RegisterAmmoIndividual();
}

void MapActivate()
{
	AmmoIndividualRemap();
}