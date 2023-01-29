# Sven-Co-op Repository

An assortment of test maps, additional information for SC stuff, Angelscript plugins / map-scripts, new entities and anything related to SC.

Contact info [Discord](https://discord.gg/VsNnE3A7j8)

[Tutorials](#tutorials)

[Plugins](#plugins)

[Scripts](#scripts)

[Credits](#people-who-contributed-in-any-way)










# Tutorials

[env_global](#env_global)

[numerical padlock](#numerical-padlock)

[Un-embed textures from a BSP](#un-embed-textures-from-a-bsp)










# Plugins

[BloodPuddle](#bloodpuddle)

[NoAutoPick](#noautopick)

[PlayerDeadChat](#playerdeadchat)

[RenameServer](#renameserver)










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
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄ammo_custom.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

**Introduction:**

It has all the keyvalues that any ``item`` entity supports.

| key | value | description |
|-----|-------|-------------|
| w_model | string | defines a custom world model |
| p_sound | string | defines a custom sound to use when the item is taken |
| am_name | [choices](#ammo_custom-am_name) | defines the type of ammunition this item will give to players |
| am_give | integer | number of bullets that this item should give to the players |
| frags | integer | How many times player can take this item (affect only activator) 0 = infinite |

## ammo_custom am_name
- buckshot
- 9mm
- ARgrenades
- sporeclip
- rockets
- uranium
- bolts
- 556
- 357
- m40a1
- satchel
- Trip Mine
- Hand Grenade
- snarks

⚠️ The player must have already equiped the items that classifies as "weapons" the ammo will be added but the player won't be able to select them until collect a weapon.

List:
- satchel
- Trip Mine
- Hand Grenade
- snarks

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# config_classic_mode
config_classic_mode is a entity that customize classic mode for monsters, models and items that the game doesn't support.

it also allow the mapper to swap **any** model into a classic model if specified by the entity.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄config_classic_mode.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/config_classic_mode"

void MapInit()
{
	config_classic_mode::Register();
}
```

**Introduction:**

A custom entity that allow mappers to configure Classic Mode.

Trigger the entity by using USE_TYPE.

- USE_OFF Will disable classic mode.

- USE_ON Will enable Classic mode.

- USE_TOGGLE Will toggle Classic mode.

| key | value | description |
|-----|-------|-------------|
| spawnflags | 1 (Restart now) | if set. the current map will be restarted to apply the changes | 
| delay | float | delay before trigger any of its targets |
| target_toggle | target | trigger this target when the classic mode has been successfuly toggled [Supports USE_TYPE](#utils-use-type) |
| target_failed | target | trigger this target when the entity receive USE_ON but the classic mode is actually enabled or when the entity receive USE_OFF but the classic mode is actually disabled [Supports USE_TYPE](#utils-use-type) |
| target_enabled | target | trigger this target if the classic mode has been started enabled. it fires once the map starts [Supports USE_TYPE](#utils-use-type) |
| target_disabled | target | trigger this target if the classic mode has been started disabled. it fires once the map starts [Supports USE_TYPE](#utils-use-type) |
| health | float | this is the entity's think function. using higher value will consume less cpu but players may notice the HD model default is 0.1f + health |

In HAMMER/JACK/BSPGUY open Smart-Edit and add there the keyvalues.

- The key is equal to the classname of the weapon you want to replace when classic mode is enabled.

- The value is equal to the classname of the new weapon that will be set if classic mode is enabled.

**SAMPLE:**
```angelscript
"weapon_m16" "weapon_9mmAR"
```

The same way you can replace any entity's custom model. the syntax is the same.

- The key is equal to the model you want to replace when classic mode is enabled.

- The value is equal to the model that will replace the previus.

**SAMPLE:**
```angelscript
"models/hlclassic/scientist.mdl" "models/headcrab.mdl"
```
⚠️ Don't forget that since classic mode is enabled the model you need to replace is not "models/barney.mdl" it is "models/hlclassic/barney.mdl"

- Using (on any entity) custom keyvalue ``"$i_classic_mode_ignore"`` will prevent their model being changed or item being replaced.


**Additional and unnecesary comment:**

- This works by finding any entity that contains your key as a value for "model".

- so you can technically change brush models as well, Be wise. Be safe. Be aware.

⚠️ Use only **one** entity per map.

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# config_map_precache
config_map_precache is a entity that precache almost anything.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄config_map_precache.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/config_map_precache"

void MapInit()
{
	config_map_precache::Register();
}
```

**Introduction:**

A custom entity that allow mappers to precache almost anything

In HAMMER/JACK/BSPGUY open Smart-Edit and add there the keyvalues.

**syntax:**

- key -> thing to precache.
- value -> option to precache.

**Options:**
| value | description | sample |
|-------|-------------|--------|
| model | used to precache models and sprites. | "models/barney.mdl" "model" |
| entity | used to precache monsters and any other entities including custom entities. | "monster_zombie" "entity" |
| sound | used to precache a sound inside "sound/" folder. do not specify that folder! | "ambience/background_sex.wav" "sound" |
| generic | used to precache anything else. up to you for testing. for skybox you have to precache all files individually | "gfx/env/mysky_bk.tga" "generic" |

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# config_survival_mode
config_survival_mode is a entity that customize survival mode and make it better.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄config_survival_mode.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/config_survival_mode"

void MapInit()
{
	config_survival_mode::Register();
}
```

**Introduction:**

A custom entity that allow mappers to configure Survival Mode.

Trigger the entity by using USE_TYPE.

- USE_OFF Will disable survival mode.

- USE_ON Will enable survival mode.

- USE_TOGGLE Will toggle survival mode.

If the entity is triggered before it reach the limit of mp_survival_startdelay then it is set to 0 and survival is instantly enabled.

| key | value | description |
|-----|-------|-------------|
| delay | float | delay before trigger any of its target |
| target_toggle | target | trigger this target when the survival mode is toggled [Supports USE_TYPE](#utils-use-type) |
| target_failed | target | trigger this target when the entity receive USE_ON but survival is already ON, or when the entity receive USE_OFF but the survival is already OFF [Supports USE_TYPE](#utils-use-type) |
| mp_survival_startdelay | integer | delay before survival mode starts, if empty it will use the cvar mp_survival_startdelay |
| mp_respawndelay | integer | delay before players can re spawn in survival disabled, if empty it use the cvar mp_respawndelay |
| master | multisource | a multisource will lock the entity from being triggered n/or from start survival mode by its mp_survival_startdelay |

⚠️ Use only **one** entity per map.

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# entitymaker
entitymaker is a entity that when is fired it creates any entity on its origin and using the same keyvalues that entitymaker has.

basically trigger_createentity but we aimed to add a condition for it to spawn or not the entity depending the condition set.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄entitymaker.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/entitymaker"

void MapInit()
{
	entitymaker::Register();
}
```

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_alien_teleport
env_alien_teleport is a entity that randomly teleport in aliens on a random player.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_alien_teleport.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_alien_teleport"

void MapInit()
{
	env_alien_teleport::Register();
}
```

**Introduction:**

a custom entity that watch for alive players and then spawns a monster around a random alive player.


| key | value | description |
|-----|-------|-------------|
| target | target | trigger this target when an alien is spawned. the choosed player is the activator and the alien is the caller [Supports USE_TYPE](#utils-use-type) |
| noise | target | trigger this target when the monster can't spawn due to obstacles. the choosed player is the activator and the entity is the caller [Supports USE_TYPE](#utils-use-type) |
| delay | float | delay (seconds) between teleports |
| netname | string | classname of the alien that will spawns. can use trigger_changevalue on-demand |
| message | target | xenmaker template to use its effect when the alien spawns |

⚠️ Use only **one** entity per map.

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_bloodpuddle
env_bloodpuddle Generates a blood puddle when a monster die.

As a [Plugin](bloodpuddle)

**Download**
```
└── 📁svencoop_addon
    ├── 📁models
    |   └── 📁mikk
    |       └── 📁misc
    |           └── 📄bloodpuddle.mdl
    |
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_bloodpuddle.as
                └── 📄utils.as
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
if set to ``false`` or not set, the generated blood puddles won't disapear

if set to ``true``, the generated blood puddles will disapear as soon as the monster who generated it disapears.
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

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_fog
env_fog_individual is a entity that expands env_fog features to show fog to activator only. created for the use of env_fog in xen maps only (displacer teleport)

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_fog.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_fog"

void MapInit()
{
	env_fog::Register();
}
```

**Introduction:**

Adds to env_fog a new spawnflag that allows the fog to ve visible for activator only.

spawnflags -> 2 (Activator Only)

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_geiger
env_geiger is a entity that simulates radiation sound in a small radius of its origin.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_geiger.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_geiger"

void MapInit()
{
	env_geiger::Register();
}
```

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_render
env_render Allow env_render to gradually fade its target.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_render.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_render"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**

Render a entity progressivelly (fade in-out) by its renderamt until both (env_render and target entity) have the same renderamt

spawnflag -> 32 (Gradually Fade in/out)

health -> Think interval (default 0.045)

frags -> ammount of renderamt to change every time it thinks

netname -> Trigger this target when finish thinking [Supports USE_TYPE](#utils-use-type)

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_spritehud
env_spritehud is a entity that shows a sprite on the player's HUD.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_spritehud.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_spritehud"

void MapInit()
{
	env_spritehud::Register();
}
```

**Introduction:**

Shows a sprite on the hud of one or all players

This entity is kinda confuse even for me, i've include everything that HudSprite supports but no idea what all of those values does.

| key | value | description |
|-----|-------|-------------|
| spawnflags | flags | set flags See [enum spawnflags](#env_spritehud-spawnflags) |
| frags | 0/1 | 0 = show to activator only, 1 = show to all players |
| sprite | string | sprite file |
| x | string | Horizontal position on the screen. <0, 1.0> = left to right. (-1.0, 0) = right to left. -1.0 = centered |
| y | string | Vertical position on the screen. <0, 1.0> = top to bottom. (-1.0, 0) = bottom to top. -1.0 = centered |
| channel | 0/15 | Channel. Range: 0-15 (each module type has its own channel group). |
| color1 | [choices](#env_spritehud-color) | Set a color |
| color2 | [choices](#env_spritehud-color) | Set a color |
| effect | [choices](#env_spritehud-effect) | Set a color |
| frame | float | Show Frame number/s |
| top | integer | Sprite top offset. Range: 0-255 |
| left | integer | Sprite left offset. Range: 0-255 |
| width | integer | 0 = auto, use total width of the sprite |
| height | integer | 0 = auto, use total height of the sprite |
| numframes | integer | Number of frames |
| framerate | float | Speed of framerate |
| holdTime | float | Hold Time |
| fadeinTime | float | Fade In Time |
| fadeoutTime | float | Fade Out Time |

## env_spritehud spawnflags

| flag | bit | function |
|-----|------|----------|
| X position in pixels | 1 | HUD_ELEM_ABSOLUTE_X |
| Y position in pixels | 2 | HUD_ELEM_ABSOLUTE_Y |
| X-pos relative to the center | 4 | HUD_ELEM_SCR_CENTER_X |
| Y-pos relative to the center | 8 | HUD_ELEM_SCR_CENTER_Y |
| Ignore client border | 16 | HUD_ELEM_NO_BORDER (hud_bordersize) |
| Create a hidden element | 32 | HUD_ELEM_HIDDEN |
| Play the effect only once | 64 | HUD_ELEM_EFFECT_ONCE |
| client alpha | 128 | HUD_ELEM_DEFAULT_ALPHA (hud_defaultalpha) |
| client alpha | 256 | HUD_ELEM_DYNAMIC_ALPHA (flash when updated) |
| Draw opaque sprite | 65536 | HUD_SPR_OPAQUE |
| Draw masked sprite | 131072 | HUD_SPR_MASKED |
| Play anim only once | 262144 | HUD_SPR_PLAY_ONCE |
| Hide when anim stops | 524288 | HUD_SPR_HIDE_WHEN_STOPPED |

## env_spritehud color

| value | color |
|-------|-------|
| 0 | White |
| 1 | Black |
| 2 | Red |
| 3 | Green |
| 4 | Blue |
| 5 | Yellow |
| 6 | Orange |
| 7 | Sven Co-op |

## env_spritehud effect

| value | description | function |
|-------|-------------|----------|
| 0 | No effect | HUD_EFFECT_NONE |
| 1 | Linear ramp up from color1 to color2 | HUD_EFFECT_RAMP_UP |
| 2 | Linear ramp down from color2 to color1 | HUD_EFFECT_RAMP_DOWN |
| 3 | Linear up n down from color1 to color2 to color1 | HUD_EFFECT_TRIANGLE |
| 4 | Cosine ramp up from color1 to color2 | HUD_EFFECT_COSINE_UP |
| 5 | Cosine ramp down from color2 to color1 | HUD_EFFECT_COSINE_DOWN |
| 6 | Cosine up n down from color1 to color2 to color1 | HUD_EFFECT_COSINE |
| 7 | Toggle between color1 and color2 | HUD_EFFECT_TOGGLE |
| 8 | Sine pulse from color1 to zero to color2 | HUD_EFFECT_SINE_PULSE |

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# env_spritetrail
env_spritetrail is a entity that traces a sprite when the target entity moves

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_spritetrail.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_spritetrail"

void MapInit()
{
	env_spritetrail::Register();
}
```

**Introduction:**

Traces a trail sprite when the target entity moves.

| key | value | description |
|-----|-------|-------------|
| target | target | entity to target for trace. Blank = this entity (trigger_setorigin). "!activator" = player/monster activator. else just target something's name
| model | string | Sprite to show as a beam |
| frags | float | Think time |
| health | float | Life/fade time |
| renderamt | integer | FX Amount (1 - 255) |
| rendercolor | Vector | FX Color (R G B) |
| scale | integer | Texture Scale (0-255) |

⚠️ on monsters the trail is on its foots, use trigger_setorigin ( off-set ) instead.

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_debug
game_debug is a entity that shows debug messages if using ``g_Util.DebugMode( true );`` function in your map script.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_debug.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_debug"

void MapInit()
{
	game_debug::Register();
}
```

**Introduction:**
game_debug is a entity that when fired. it will show in players console the keyvalue ``message``

You can use commands like ``!netname`` it will be replaced with whatever "netname" keyvalue has.

**List**

- ``!netname`` netname keyvalue (string)

- ``!frags`` frags keyvalue (float)

- ``!iuser1`` iuser1 keyvalue (integer)

- ``!activator`` name of the entity's activator

- ``!caller`` name of the entity's caller

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_stealth
game_stealth Allow mappers to make use of stealth mode in Co-op

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_stealth.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_stealth"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**

all npc monster entities now supports a custom keyvalue called ``$i_stealth`` that if it is in a value of ``1`` this monster will now "Remove from world" the npc/player that is seen by this entity.

also another keyvalue is supported ``$i_stealthmode`` if set on a value of ``1`` this npc will ignore its enemy monsters and will only do this to players.

- If a monster die by this feature and it is using TriggerTarget then its trigger target is fired.

- Every time this monster sees a enemy and remove him then its own "target" keyvalue is fired.

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_text_custom
game_text_custom is a entity replacemet for game_text and env_message with lot of new additions and language support.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_text_custom.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_text_custom"

void MapInit()
{
	game_text_custom::Register();
}
```

**Introduction:**

| key | value | description |
|-----|-------|-------------|
| target | target | trigger this target when fired [Supports USE_TYPE](#utils-use-type)|
| killtarget | target | kill this target |
| delay | float | delay before kill or target |
| effect | [choices](#game_text_custom-effect) |
| spawnflags | [flags](#game_text_custom-spawnflags) |
| fadein | float | Fade in Time (or character scan time effect 2 ) ( effect 0/1/2 ) |
| fadeout | float | Fade Out Time ( effect 0/1/2 ) |
| holdtime | float | Hold Time for ( effect 0/1/2 ) |
| fxtime | float | Scan time ( effect 2 )
| x | float | X (0 - 1.0 = left to right) (-1 centers) ( effect 0/1/2 ) |
| y | float | Y (0 - 1.0 = top to bottom) (-1 centers) ( effect 0/1/2 ) |
| color | Vector | Color 1 (Add 4th number >0 for opaque) ( effect 0/1/2 ) |
| color2 | Vector | Color 2 (Add 4th number >0 for opaque) ( effect 0/1/2 ) |
| channel | integer | Channel to use for this message ( effect 0/1/2 ) range 0/8 |
| messagesound | string | sound to play |
| messagevolume | integer | volume of the sound |
| messageattenuation | choices | 0 = "Small Radius" 1 = "Medium Radius" 2 = "Large  Radius" 3 = "Play Everywhere" 4 = "Activator only"
| messagesentence | !sentence | Plays a sentence using this entity as a speaker |
| key_integer | integer | See [Replacing string](#game_text_custom-replace) |
| key_float | float | See [Replacing string](#game_text_custom-replace) |
| key_string | string | See [Replacing string](#game_text_custom-replace) |
| netname | string | See [Replacing string](#game_text_custom-replace) |
| focus_entity | target | See [Replacing string](#game_text_custom-replace) |
| key_from_entity | string | See [Replacing string](#game_text_custom-replace) |
| model | brushmodel | only allowed by the plugin. used to replace a trigger_multiple's message keyvalue into a own text apart |
| language | keyvalues |  See [Supported Languages](#supported-languages) |

# game_text_custom effect


| value | name | description |
|-------|------|-------------|
| 0 | Fade In/Out | fade in and out depending keyvalues fadein, fadeout
| 1 | Credits | used by env_message |
| 2 | Scan Out | scan out depending keyvalue fxtime |
| 3 | Print HUD | The same effect that trigger_once/multiple's "message" provides. |
| 4 | Print MOTD | Shows a MOTD pop up with the given message. See [MOTD](#game_text_custom-motd) |
| 5 | Print Chat | Shows a message on the chat. |
| 6 | Print Notify | Prints a notify at the top left side |
| 7 | Print Key-Bind | Prints a keybind print, the format is "Press +use to interact" and will be shown as "Press [e] to interact" |
| 8 | Print Console | Prints at the console ( set flag 2 or double message will be shown ) |
| 9 | Print Center | Prints at the center of the screen |
| 10 | Print scoreboard | Shows the text as the server's hostname but only apply to the score board popup |


# game_text_custom motd

To set a title you must write it like this
```angelscript
"This is the title# this is the text"
```
The ``"#"`` defines when the title ends and when the message starts

⚠ JACK/Bspguy has a limit on how many chars you can set so you have to learn ripent if you will use long-size motd.

# game_text_custom spawnflags
| flag | bit | description |
|------|-----|-------------|
| All Players | 1 | shows the message to all connected players. else just activator |
| No console echo | 2 | if set. no console message will be sent |
| Fire per player | 4 | If set. The target will be fired for every player that sees the message. Otherwise the target is fired once every time the entity is fired. |

# game_text_custom replace

We've added a function for replacing a string command into another string.

In this case you want the game_text_custom show a countdown with a message.

``key_integer`` will do the trick.
```angelscript
"message" "The bomb will explode in !integer seconds"
"key_integer" "5"
```
you can in any time update key_integer with trigger_copy/change/value and fire the game_text_custom after affect.
```angelscript
The bomb will explode in 5 seconds
```
``key_float`` is the same but it is a float. ``!float``

``key_string`` is the same but it is a string. ``!string``

``!activator`` will contain the nickname or classname of the player or monster that activated this entity.
```angelscript
"message" "The player !activator is trapped in sector C"
```

i've made this next keys by using it for my own purposes but probably they're useful to you as well.

``focus_entity`` is a target type key. you must target a entity's classname in this. if is empty we'll use the activator.

``key_from_entity`` must be a custom keyvalue that we want to find it in the target entity and get its value.

then its value will replace the command ``!value``

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_time
game_time is a entity that allow mappers to make use of real time and custom time. create maps with timers n/or timelapse day/night fire entities depending the time etc.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_time.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_time"

void MapInit()
{
	game_time::Register();
}
```

**Introduction:**

A custom entity that allow mappers to create maps with "real time" set.

meant to be used for changing map events or even light style (sun/moon)

the entity will start working as soon as the map starts. if not locked by a multisource.

| key | value | description |
|-----|-------|-------------|
| health | integer | "One minute is (IRL-seconds)" using a value of 60 mean that one minute (in-game) is equal to one minute (in real life) while using a value of 1  mean that one minute (in-game) is equal to one second (in real life)
| current_second | integer | Internal values that will be updated by the entity current time and can be set though changevalue. |
| trigger_second | target | Trigger when a second increase [Supports USE_TYPE](#utils-use-type) |
| current_minute | integer | Internal values that will be updated by the entity current time and can be set though changevalue. |
| trigger_minute | target | Trigger when a minute increase [Supports USE_TYPE](#utils-use-type) |
| current_hour | integer | Internal values that will be updated by the entity current time and can be set though changevalue. |
| trigger_hour | target | Trigger when a hour increase [Supports USE_TYPE](#utils-use-type) |
| current_day | integer | Internal values that will be updated by the entity current time and can be set though changevalue. |
| trigger_day | target | Trigger when a day increase [Supports USE_TYPE](#utils-use-type) |
| light_pattern | target | targetname of a light_spot to change its pattern depending the time. if "!world" it'll be a global change. |
| spawnflags | flags | 1 = Real Time, if set. the entity will start with the host's real time

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_trigger_iterator
game_trigger_iterator is a entity that will fire its target with the activator and caller that it specifies.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_trigger_iterator.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_trigger_iterator"

void MapInit()
{
	game_trigger_iterator::Register();
}
```

**Introduction:**

A custom ntity that will fire its target with the activator and caller that you set.

``"!activator"`` will pass the current activator.

``"!caller"`` will pass the current caller.

The current USE_TYPE is also passed through if not specified.

| key | value | description |
|-----|-------|-------------|
| target | target | Trigger this entity when fire [Supports USE_TYPE](#utils-use-type) |
| netname | target | Entity to set as activator |
| message | target | Entity to set as caller |
| frags | choices | TriggerState to send, 0 = "Current USE_TYPE" 1 = "USE_OFF" 2 = "USE_ON" 3 = "USE_TOGGLE"
| health | float | Delay before trigger the entity |

Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# game_zone_entity
game_zone_entity is a entity similar to game_zone_player but now supports any entity in its volume not only players.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄game_zone_entity.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/game_zone_entity"

void MapInit()
{
	game_zone_entity::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# item_oxygentank
item_oxygentank is a entity that will give oxygen to players that touch it.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄item_oxygentank.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/item_oxygentank"

void MapInit()
{
	item_oxygentank::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# monster_damage_inflictor
monster_damage_inflictor is feature for passing a monster's Attacker/damage inflictor as a !activator via npc's TriggerTarget key.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄monster_damage_inflictor.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/monster_damage_inflictor"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# player_command
player_command is a entity that allow mappers to force players to execute a cmd onto their consoles.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄player_command.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/player_command"

void MapInit()
{
	player_command::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# trigger_changecvar
trigger_changecvar is a entity alternative to trigger_setcvar but you can set more than one cvar per entity and can return them back to normal if fire with USE_OFF.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_changecvar.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_changecvar"

void MapInit()
{
	trigger_changecvar::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# trigger_changevalue
trigger_changevalue Allow trigger_changevalue to change keyvalues from a specified weapon of the player activator

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_changevalue.as
                └── 📄utils.as
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
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_individual.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_individual"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# trigger_multiple
trigger_multiple Allow trigger_multiple entity to fire its target for every one inside its volume.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_multiple.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_multiple"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)

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
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_random.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_random"
```
**OR**

Simply include the script once via a trigger_script entity. no need to call. just include.

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# trigger_sound
trigger_sound is a entity like env_sound but as a brush entity

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_sound.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_sound"

void MapInit()
{
	trigger_sound::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)










# trigger_votemenu
trigger_votemenu is a entity that allow mapper to create a buymenu-like vote for one or all players.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄trigger_votemenu.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/trigger_votemenu"

void MapInit()
{
	trigger_votemenu::Register();
}
```

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)







# utils
utils is a script that contains alot of useful features and code that is being shared with my other scripts so in most of the cases you have to include this script.

**Introduction:**


Make use of the [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)



# Utils Use Type



# Supported Languages
| key to show | value from player |
|-------------|-------------------|
| message | english or empty |
| message_spanish | spanish |
| message_spanish2 | spanish spain |
| message_portuguese | portuguese |
| message_german | german |
| message_french | french |
| message_italian | italian |
| message_esperanto | esperanto |
| message_czech | czech |
| message_dutch | dutch |
| message_indonesian | indonesian |
| message_romanian | romanian |
| message_turkish | turkish |
| message_albanian | albanian |











# BloodPuddle
BloodPuddle Generates a blood puddle when a monster die.

As a [Map-Script](env_bloodpuddle)

**Download**
```
└── 📁svencoop_addon
    ├── 📁models
    |   └── 📁mikk
    |       └── 📁misc
    |           └── 📄bloodpuddle.mdl
    |
    └── 📁scripts
        ├── 📁maps
        |   └── 📁mikk
        |       ├── 📄env_bloodpuddle.as
        |       └── 📄utils.as
        └── 📁plugins
            └── 📄BloodPuddle
```

**install:**
```angelscript
    "plugin"
    {
        "name" "BloodPuddle"
        "script" "BloodPuddle"
    }
```
in line 4
```angelscript
    env_bloodpuddle::Register( false );
```
if set to ``false``, the generated blood puddles won't disapear

if set to ``true``, the generated blood puddles will disapear as soon as the monster who generated it disapears.










# NoAutoPick
NoAutoPick Make items/weapons pick-able only if pressing E-key.

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄NoAutoPick
```

**install:**
```angelscript
    "plugin"
    {
        "name" "NoAutoPick"
        "script" "NoAutoPick"
    }
```










# PlayerDeadChat
PlayerDeadChat Make dead player's messages readable for dead players only

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄PlayerDeadChat
```

**install:**
```angelscript
    "plugin"
    {
        "name" "PlayerDeadChat"
        "script" "PlayerDeadChat"
    }
```










# RenameServer
RenameServer Changes your server's hostname dynamicaly depending the map playing

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄RenameServer
```

**install:**
```angelscript
    "plugin"
    {
        "name" "RenameServer"
        "script" "RenameServer"
    }
```










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

A tool that eliminates imported textures in the maps (``-wadinclude``) and this reduce considerably BSP's file.

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

⚠️ Since the BSP has been modified it will differ from older versions but it will also lower considerably it's size.










# People who contributed in any way

[Gaftherman](https://github.com/Gaftherman)

[Sparks]()

[KEZÆIV](https://www.youtube.com/channel/UCV5W8sCs-5EYsnQG4tAfoqg)

[Giegue](https://github.com/JulianR0)

[Duk0](https://github.com/Duk0)

[Outerbeast](https://github.com/Outerbeast)

[Cubemath](https://github.com/CubeMath)

[Rick](https://github.com/RedSprend)

[Litude](https://github.com/Litude)

[Wootguy](https://github.com/wootguy)