#include "mikk/ammo_custom"
#include "mikk/env_bloodpuddle"
#include "mikk/config_classic_mode"
#include "mikk/entitymaker"
#include "mikk/env_alien_teleport"
#include "mikk/env_fog"
#include "mikk/game_debug"
#include "mikk/game_stealth"
#include "mikk/game_time"
#include "mikk/game_zone_entity"
#include "mikk/trigger_individual"
#include "mikk/trigger_multiple"
#include "mikk/trigger_random"
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
    env_bloodpuddle::Register( false, "models/mikk/misc/bloodpuddle.mdl" );
    config_classic_mode::Register();
    entitymaker::Register();
    env_alien_teleport::Register();
    env_fog::Register();
    game_debug::Register();
    game_time::Register();
    game_zone_entity::Register();
    trigger_votemenu::Register();
}