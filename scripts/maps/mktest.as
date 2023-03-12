#include "mikk/ammo_custom"

#include "mikk/config_classic_mode"
#include "mikk/config_map_cvars"
#include "mikk/config_map_precache"
#include "mikk/config_survival_mode"

#include "mikk/env_alien_teleport"
#include "mikk/env_bloodpuddle"
//#include "mikk/env_effect"
#include "mikk/env_fog"
#include "mikk/env_geiger"
//#include "mikk/env_hurtzone"
#include "mikk/env_render"
#include "mikk/env_spritehud"
#include "mikk/env_spritetrail"

#include "mikk/game_debug"
//#include "mikk/game_save"
#include "mikk/game_stealth"
#include "mikk/game_text_custom"
#include "mikk/game_time"
#include "mikk/game_zone_entity"

#include "mikk/item_oxygentank"

#include "mikk/player_command"
//#include "mikk/player_flashlight"
#include "mikk/player_inbutton"
#include "mikk/player_reequipment"
//#include "mikk/player_talk"

#include "mikk/trigger_changevalue"
//#include "mikk/trigger_inout"
#include "mikk/trigger_manager"
#include "mikk/trigger_multiple"
#include "mikk/trigger_random"
#include "mikk/trigger_sound"
#include "mikk/trigger_votemenu"

#include "mikk/utils"

string map = string( g_Engine.mapname );

void MapInit()
{
    g_Util.DebugMode();

    if( blTestMap( 'ammo_custom' ) )
    {
        ammo_custom::Register();
    }

    if( blTestMap( 'config_classic_mode' ) )
    {
        config_classic_mode::Register();
    }

    config_map_cvars::Register();
    config_map_precache::Register();

    if( blTestMap( 'config_survival_mode' ) )
    {
        config_survival_mode::Register();
    }

    env_alien_teleport::Register();
    env_bloodpuddle::Register( false, 'models/mikk/misc/bloodpuddle.mdl' );
    //env_effect::Register();
    env_fog::Register();
    env_geiger::Register();
    //env_hurtzone::Register();
    env_spritehud::Register();
    env_spritetrail::Register();

    game_debug::Register();
    //game_save::Register();
    game_text_custom::RegisterCustomSentences( 'mikk/store/default_messages.txt' );
    game_text_custom::Register();
    game_time::Register( true );
    game_zone_entity::Register();

    item_oxygentank::Register();

    player_command::Register();
    //player_flashlight::Register();
    player_inbutton::Register();
    player_reequipment::KeepAmmo( true );
    //player_talk::Register();

    //trigger_inout::Register();
    trigger_manager::Register();
    trigger_sound::Register();
    trigger_votemenu::Register();
}

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