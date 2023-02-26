#include "mikk/ammo_custom"

#include "mikk/config_classic_mode"
#include "mikk/game_text_custom"

void MapInit()
{
	g_Util.DebugMode( true );

    g_Util.ScriptAuthor.insertLast
    (
        "Map: " + string( g_Engine.mapname ) + ".bsp\n"
        "Description: Test Scripts.\n"
        "Script: scripts/maps/" + string( g_Engine.mapname ).Replace( '1test_', 'mikk/' ) + ".as\n"
    );

	if( blTestMap( 'ammo_custom' ) )
	{
		ammo_custom::Register();
	}

	if( blTestMap( 'config_classic_mode' ) )
	{
		config_classic_mode::Register();
	}

	game_text_custom::Register();
}

bool blTestMap( const string& in szMapName )
{
	if( string( g_Engine.mapname ).EndsWith( szMapName ) )
		return true;
	return false;
}