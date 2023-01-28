#include "mikk/ammo_custom"

#include "mikk/config_classic_mode"
#include "mikk/config_map_precache"
#include "mikk/config_survival_mode"

#include "mikk/entitymaker"

#include "mikk/env_alien_teleport"
#include "mikk/env_bloodpuddle"
#include "mikk/env_fog"
#include "mikk/env_geiger"
#include "mikk/env_render"
#include "mikk/env_spritehud"
#include "mikk/env_spritetrail"

#include "mikk/game_debug"
#include "mikk/game_stealth"
#include "mikk/game_text_custom"
#include "mikk/game_time"
#include "mikk/game_trigger_iterator"
#include "mikk/game_zone_entity"

#include "mikk/item_oxygentank"

#include "mikk/monster_damage_inflictor"

#include "mikk/player_command"

#include "mikk/trigger_changecvar"
#include "mikk/trigger_changevalue"
#include "mikk/trigger_individual"
#include "mikk/trigger_multiple"
#include "mikk/trigger_random"
#include "mikk/trigger_sound"
#include "mikk/trigger_votemenu"

#include "mikk/utils"

void MapInit()
{
    g_Util.DebugMode( true );

    g_Util.ScriptAuthor.insertLast
    (
        "Map: 1mikktest_*\n"
        "Author: Mikk\n"
        "Github: github.com/Mikk155\n"
        "Description: Test almost of the scripts.\n"
    );

    g_Util.MapAuthor.insertLast( "STEAM_0:0:202010794" );
    g_Util.MapAuthor.insertLast( "STEAM_0:0:481307649" );

    ammo_custom::Register();

    config_classic_mode::Register();
    config_map_precache::Register();
    config_survival_mode::Register();

    entitymaker::Register();

    env_alien_teleport::Register();
    env_bloodpuddle::Register( false );
    env_fog::Register();
    env_geiger::Register();
    env_spritehud::Register();
    env_spritetrail::Register();

    game_debug::Register();
    game_text_custom::Register();
    game_time::Register();
    game_trigger_iterator::Register();
    game_zone_entity::Register();
    
    item_oxygentank::Register();
    
    player_command::Register();

    trigger_changecvar::Register();
    g_TriggerMultiple.LoadConfigFile();
    trigger_sound::Register();
    trigger_votemenu::Register();
}