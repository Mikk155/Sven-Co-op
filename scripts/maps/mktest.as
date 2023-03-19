#include "mikk/ammo_custom"

void MapInit()
{
    g_Util.DebugMode();

    if( blTestMap( 'ammo_custom' ) )
    {
        ammo_custom::Register();
    }
}

string map = string( g_Engine.mapname );

bool blTestMap( const string& in szMapName )
{
    if( map.EndsWith( szMapName ) )
	{
		g_Util.ScriptAuthor.insertLast
		(
			"Map: " + map + ".bsp\n"
			"Description: Test Scripts.\n"
			"Script: scripts/maps/" + map.Replace( '1test_', 'mikk/' ) + ".as\n"
		);
        return true;
	}
    return false;
}