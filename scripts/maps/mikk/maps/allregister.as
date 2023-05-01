#include '../ammo_custom'

#include '../config_classic_mode'
#include '../config_map_cvars'
#include '../config_map_precache'
// #include '../config_map_saveload'
#include '../config_survival_mode'

#include '../counterstrike_classes'

#include '../entitymaker'

#include '../ef_nodecals'

#include '../env_bloodpuddle'
#include '../env_effects'
#include '../env_fade_custom'
#include '../env_fog_custom'
#include '../env_geiger'
#include '../env_message_custom'
#include '../env_render_custom'
#include '../env_spritehud'
// #include '../env_spritetrail'

#include '../func_ladder_custom'

#include '../game_debug'
#include '../game_text_custom'
#include '../game_time'
#include '../game_zone_entity'

#include '../info_commentary'

#include '../item_oxygentank'

// #include '../monster_dead'
// #include '../monster_stealth'

#include '../player_command'
#include '../player_data'
#include '../player_equipment'
#include '../player_flashlight'
#include '../player_inbutton'
#include '../player_observer'
#include '../player_reequipment'

#include '../trigger_changevalue_custom'
#include '../trigger_manager'
#include '../trigger_multiple_custom'
#include '../trigger_percent'
#include '../trigger_randomplayer'
#include '../trigger_sound'
#include '../trigger_teleport_relative'
#include '../trigger_votemenu'

void Register()
{
    g_Util.DebugEnable = true;
}
