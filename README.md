# Sven-Co-op Repository

An assortment of test maps, additional information for SC stuff, Angelscript plugins / map-scripts, new entities and anything related to SC.

[Tutorials](#tutorials)

[Plugins](#plugins)

[Scripts](#scripts)

[Credits](#people-who-contributed-in-any-way)

# Tutorials

[env_global](#env_global)

[numerical padlock](#numerical-padlock)

[Un-embed textures from a BSP](#un-embed-textures-from-a-bsp)


# Plugins

# Scripts

[ammo_custom](#ammo_custom)

[config_classic_mode](#config_classic_mode)

[config_map_precache](#config_map_precache)

[config_survival_mode](#config_survival_mode)

[entitymaker](#entitymaker)

[env_alien_teleport](#env_alien_teleport)

[env_bloodpuddle](#env_bloodpuddle)

[env_fog](#env_fog)

[env_geiger](#env_geiger)

[env_render](#env_render)

[env_spritehud](#env_spritehud)

[env_spritetrail](#env_spritetrail)

[game_debug](#game_debug)

[game_stealth](#game_stealth)

[game_text_custom](#game_text_custom)

[game_time](#game_time)

[game_trigger_iterator](#game_trigger_iterator)

[game_zone_entity](#game_zone_entity)

[item_oxygentank](#item_oxygentank)

[monster_damage_inflictor](#monster_damage_inflictor)

[player_command](#player_command)

[trigger_changecvar](#trigger_changecvar)

[trigger_changevalue](#trigger_changevalue)

[trigger_individual](#trigger_individual)

[trigger_multiple](#trigger_multiple)

[trigger_random](#trigger_random)

[trigger_sound](#trigger_sound)

[trigger_votemenu](#trigger_votemenu)

[Utility Various Scripts](#utils)












# ammo_custom
ammo_custom is an ammo item customizable that gives a specified ammout of bullets that the mapper sets.

**Download**
```angelscript
"scripts/maps/mikk/ammo_custom.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

# config_classic_mode
config_classic_mode is a entity that customize classic mode for monsters, models and items that the game doesn't support.

it also allow the mapper to swap **any** model into a classic model if specified by the entity.

**Download**
```angelscript
"scripts/maps/mikk/config_classic_mode.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/config_classic_mode"

void MapInit()
{
	config_classic_mode::Register();
}
```

# config_map_precache
config_map_precache is a entity that precache almost anything.

**Download**
```angelscript
"scripts/maps/mikk/config_map_precache.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/config_map_precache"

void MapInit()
{
	config_map_precache::Register();
}
```

# config_survival_mode
config_survival_mode is a entity that customize survival mode and make it better.

**Download**
```angelscript
"scripts/maps/mikk/config_survival_mode.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/config_survival_mode"

void MapInit()
{
	config_survival_mode::Register();
}
```

# entitymaker
entitymaker is a entity that when is fired it creates any entity on its origin and using the same keyvalues that entitymaker has.

basically trigger_createentity but we aimed to add a condition for it to spawn or not the entity depending the condition set.

**Download**
```angelscript
"scripts/maps/mikk/entitymaker.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/entitymaker"

void MapInit()
{
	entitymaker::Register();
}
```

# env_alien_teleport
env_alien_teleport is a entity that randomly teleport in aliens on a random player.

**Download**
```angelscript
"scripts/maps/mikk/env_alien_teleport.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_alien_teleport"

void MapInit()
{
	env_alien_teleport::Register();
}
```

# env_bloodpuddle
env_bloodpuddle Generates a blood puddle when a monster die.

**Download**
```angelscript
"models/mikk/misc/bloodpuddle.mdl"
"scripts/maps/mikk/env_bloodpuddle.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_bloodpuddle"

void MapInit()
{
	env_bloodpuddle::Register();
}
```
The function ``Register`` has two optional calls there.
```angelscript
const bool& in blRemove = false
```
if set to false or not set, the generated blood puddles won't disapear
if set to true, the generated blood puddles will disapear as soon as the monster who generated it disapears.
```angelscript
const string& in szModel = "models/mikk/misc/bloodpuddle.mdl"
```
if not set, this model will be used.
if set a custom one, your model will be used.

**SAMPLE:**
```angelscript
#include "mikk/env_bloodpuddle"

void MapInit()
{
	env_bloodpuddle::Register( true, "models/mymodelfolder/blood.mdl" );
}
```

# env_fog
env_fog_individual is a entity that expands env_fog features to show fog to activator only. created for the use of env_fog in xen maps only (displacer teleport)

**Download**
```angelscript
"scripts/maps/mikk/env_fog.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_fog"

void MapInit()
{
	env_fog::Register();
}
```

# env_geiger
env_fog_individual is a entity that simulates radiation sound in a small radius of its origin.

**Download**
```angelscript
"scripts/maps/mikk/env_geiger.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_geiger"

void MapInit()
{
	env_geiger::Register();
}
```

# env_render
env_render Allow env_render to gradually fade its target.

**Download**
```angelscript
"scripts/maps/mikk/env_render.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_render"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# env_spritehud
env_spritehud is a entity that shows a sprite on the player's HUD.

**Download**
```angelscript
"scripts/maps/mikk/env_spritehud.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_spritehud"

void MapInit()
{
	env_spritehud::Register();
}
```

# env_spritetrail
env_spritetrail is a entity that traces a sprite when the target entity moves

**Download**
```angelscript
"scripts/maps/mikk/env_spritetrail.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/env_spritetrail"

void MapInit()
{
	env_spritetrail::Register();
}
```

# game_debug
game_debug is a entity that shows debug messages if using ``g_Util.DebugMode( true );`` function in your map script.

**Download**
```angelscript
"scripts/maps/mikk/game_debug.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_debug"

void MapInit()
{
	game_debug::Register();
}
```

# game_stealth
game_stealth Allow mappers to make use of stealth mode in Co-op

**Download**
```angelscript
"scripts/maps/mikk/game_stealth.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_stealth"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# game_text_custom
game_text_custom is a entity replacemet for game_text and env_message with lot of new additions and language support.

**Download**
```angelscript
"scripts/maps/mikk/game_text_custom.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_text_custom"

void MapInit()
{
	game_text_custom::Register();
}
```

# game_time
game_time is a entity that allow mappers to make use of real time and custom time. create maps with timers n/or timelapse day/night fire entities depending the time etc.

**Download**
```angelscript
"scripts/maps/mikk/game_time.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_time"

void MapInit()
{
	game_time::Register();
}
```

# game_trigger_iterator
game_trigger_iterator is a entity that will fire its target with the activator and caller that it specifies.

**Download**
```angelscript
"scripts/maps/mikk/game_trigger_iterator.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_trigger_iterator"

void MapInit()
{
	game_trigger_iterator::Register();
}
```

# game_zone_entity
game_zone_entity is a entity similar to game_zone_player but now supports any entity in its volume not only players.

**Download**
```angelscript
"scripts/maps/mikk/game_zone_entity.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/game_zone_entity"

void MapInit()
{
	game_zone_entity::Register();
}
```

# item_oxygentank
item_oxygentank is a entity that will give oxygen to players that touch it.

**Download**
```angelscript
"scripts/maps/mikk/item_oxygentank.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/item_oxygentank"

void MapInit()
{
	item_oxygentank::Register();
}
```

# monster_damage_inflictor
monster_damage_inflictor is feature for passing a monster's Attacker/damage inflictor as a !activator via npc's TriggerTarget key.

**Download**
```angelscript
"scripts/maps/mikk/monster_damage_inflictor.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/monster_damage_inflictor"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# player_command
player_command is a entity that allow mappers to force players to execute a cmd onto their consoles.

**Download**
```angelscript
"scripts/maps/mikk/player_command.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/player_command"

void MapInit()
{
	player_command::Register();
}
```

# trigger_changecvar
trigger_changecvar is a entity alternative to trigger_setcvar but you can set more than one cvar per entity and can return them back to normal if fire with USE_OFF.

**Download**
```angelscript
"scripts/maps/mikk/trigger_changecvar.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_changecvar"

void MapInit()
{
	trigger_changecvar::Register();
}
```

# trigger_changevalue
trigger_changevalue Allow trigger_changevalue to change keyvalues from a specified weapon of the player activator

**Download**
```angelscript
"scripts/maps/mikk/trigger_changevalue.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_changevalue"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# trigger_individual
trigger_individual Allow Trigger-Type entities to fire its target only once per activator.

**Download**
```angelscript
"scripts/maps/mikk/trigger_individual.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_individual"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# trigger_multiple
trigger_multiple Allow trigger_multiple entity to fire its target for every one inside its volume.

**Download**
```angelscript
"scripts/maps/mikk/trigger_multiple.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_multiple"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

Create a list of entities supported for flag 8 (Everything else) if flag 64 (Iterate all occupants) is enabled as well
if you want to use this feature then register in map init the next function.
```angelscript
g_TriggerMultiple.LoadConfigFile( "scripts/maps/path to your file.txt" );
```
This text file will define wich entities can make trigger_multiple fire its target.

if nothing set. we'll use our default ``'scripts/maps/mikk/trigger_multiple.txt'``

# trigger_random
trigger_random Allow trigger_random to set a unique random value.

**Download**
```angelscript
"scripts/maps/mikk/trigger_random.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_random"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

# trigger_sound
trigger_sound is a entity like env_sound but as a brush entity

**Download**
```angelscript
"scripts/maps/mikk/trigger_sound.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_sound"

void MapInit()
{
	trigger_sound::Register();
}
```

# trigger_votemenu
trigger_votemenu is a entity that allow mapper to create a buymenu-like vote for one or all players.

**Download**
```angelscript
"scripts/maps/mikk/trigger_votemenu.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
#include "mikk/trigger_votemenu"

void MapInit()
{
	trigger_votemenu::Register();
}
```

# utils

# env_global
env_global entity is used to transport information between two or more maps. allowing you to do different triggers depending in what state the previus map did set the global state.

map 1test_global3

# numerical padlock

Creates a full customizable code **on-the-fly** for a numerical padlock. this system works using a game_counter and a trigger_random for randomizing the code needed, feel free to make a better randomizing system of 3 digits from number 0 to 9

once you fire the "randomizing button" 3 copyvalue will paste those random numbers into a trigger_condition.

then every numerical plate will add a value of their owns into another entity while the mentioned trigger_condition will check if the numbers was touched in order and if they're correct.

- If someone is using the camera then others players can't interfer

- using the plate bellow "8" will delete all your previus attempts, basically restore.

- next to player spawn there are some entities that they're only for DEBUG purpose. delete them.

map 1test_numpad

# Un-embed textures from a BSP

A tool that eliminates imported textures in the maps (``-wadinclude``) and thus reduce considerably BSP's file.

You'll need these tools [BSPTexR](https://github.com/Litude/BSPTexRM) and [wally](https://gamebanana.com/tools/4774) and Ripent wich is in Sven Co-op's SDK

You can extract the textures with ripent, Create a wad with wally and finally eliminate the textures imported with BSPTexR

- 1 Extract the textures of your map with ripent
```
ripent -textureexport mapname
```

- 2 Create a folder called ``Vanilla textures``

- 3 Export the textures by default (halflife, opfor, etc etc) a png, tga, jpg or any other format in the folder ``Vanilla textures``

- 4 Create a folder called ``New textures``

- 5 Export the textures of your map in the folder ``New textures``

- 6 Copy all textures from the ``Vanilla textures`` folder and paste inside the ``New textures`` folder and hit "Replace all"

- 7 Now you must press CONTROL+Z the textures in the ``Vanilla textures`` folder should be back that folder leaving ``New textures`` with only the exclusive textures of the map.

- 8 Create a new wad with wally and use all the new textures.

- 9 Use the tool BSPTexR to eliminate all textures of the map
```
bsptexrm mapname
```

- 10 Go to the properties of your map and include the new .wad in the "wad" properties of "worldspawn"

**NOTE:**
Since BSP has been modified it will differ from older versions but it will also lower considerably it's size.

# People who contributed in any way

[Gaftherman](https://github.com/Gaftherman)

Sparks

[KEZÆIV](https://www.youtube.com/channel/UCV5W8sCs-5EYsnQG4tAfoqg)

[Giegue](https://github.com/JulianR0)

[Duk0](https://github.com/Duk0)

[Outerbeast](https://github.com/Outerbeast)

[Cubemath](https://github.com/CubeMath)