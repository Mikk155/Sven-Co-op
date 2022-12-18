//#include "mikk/ammo_individual"
#include "mikk/config_classic_mode"
//#include "mikk/config_survival_mode"
#include "mikk/env_bloodpuddle"
// #include "mikk/env_fog"
#include "mikk/env_render"
// #include "mikk/env_scanner"
#include "mikk/env_spritehud"
#include "mikk/env_spritetrail"
// #include "mikk/game_level_end"
#include "mikk/game_stealth"
#include "mikk/game_text_custom"
#include "mikk/game_time"
#include "mikk/item_oxygentank"
#include "mikk/monster_dmg_inflictor"
#include "mikk/player_command"
// #include "mikk/player_condition"
#include "mikk/player_data"
#include "mikk/player_deadchat"
#include "mikk/player_talk"
#include "mikk/trigger_changecvar"
#include "mikk/trigger_hurt_remote"
#include "mikk/trigger_individual"
//#include "mikk/trigger_inout"
#include "mikk/trigger_multiple"
//#include "mikk/trigger_percent"
#include "mikk/trigger_random"
#include "mikk/trigger_sound"
#include "mikk/trigger_votemenu"
#include "mikk/weapon_changevalue"

void MapInit()
{
//    ammo_individual::Register();
    config_classic_mode::Register();
//config_survival_mode::Register();
    env_bloodpuddle::Register();
    env_spritehud::Register();
    env_spritetrail::Register();
// game_level_end::Register();
    game_text_custom::Register();
    game_time::Register();
    item_oxygentank::Register();
    player_command::Register();
    // player_condition::Register();
    player_talk::Register();
    trigger_changecvar::Register();
    //    trigger_inout::Register();
    trigger_sound::Register();
    trigger_votemenu::Register();
    weapon_changevalue::Register();
}