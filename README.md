# Sven-Co-op Repository

An assortment of test maps, additional information for SC stuff, Angelscript plugins / map-scripts, new entities and anything related to SC.

[Tutorials](#tutorials)

[Plugins](#plugins)

[Scripts](#scripts)

[Credits](#people-who-contributed-in-any-way)

# Tutorials

[env_global](#env_global)

[numerical padlock](#numerical-padlock)


# Plugins

# Scripts

[ammo_custom](#ammo_custom)

[config_classic_mode](#config_classic_mode)

[config_map_precache](#config_map_precache)

[config_survival_mode](#config_survival_mode)

[entitymaker](#entitymaker)

[env_alien_teleport](#env_alien_teleport)

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


# People who contributed in any way

[Gaftherman](https://github.com/Gaftherman)

Sparks

[KEZÆIV](https://www.youtube.com/channel/UCV5W8sCs-5EYsnQG4tAfoqg)

[Giegue](https://github.com/JulianR0)

[Duk0](https://github.com/Duk0)

[Outerbeast](https://github.com/Outerbeast)

[Cubemath](https://github.com/CubeMath)
