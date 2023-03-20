# config_classic_mode

![image](../../images/angelscript.png)

config_classic_mode is an entity made in Angelscript that allows to replace models, weapons and items depending if classic mode is active or not. The focus of this entity is to allow mappers to change models and weapons that the classic mode does not change by default.

<details><summary>Install</summary>
<p>

Requirements:
- [config_classic_mode](../../../scripts/maps/mikk/config_classic_mode.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Download with a clic](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_classic_mode
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

En tu map_script Agrega:
```angelscript
#include "mikk/config_classic_mode"

void MapInit()
{
	config_classic_mode::Register();
}
```

</p>
</details>

Activate the entity giving trigger with the respective [USE_TYPE](triggering_system_english.md) .

- USE_OFF
	- Deactivate classic mode

- USE_ON
	- Activate classic mode

- USE_TOGGLE
	- Toggle classic mode


| key | Descripción |
|-----|-------------|
| spawnflags 1 (Restart now) | Activate, the map will restart to apply the changes. |
| delay | Time before triggering all the targets |
| target_toggle | target to trigger after classic mode has been successfully alternated |
| target_failed | target to trigger when classic mode recieves USE_OFF but it was already off, or when it recieves USE_ON but it was already on |
| target_enabled | target to trigger when classic mode has been activated. (After map restart) |
| target_disabled | target to trigger when classic has been deactivated. (After map restart) |
| health | Thinking time of the entity, a high value will consume less CPU but players could see a HD model in classic mode for an instant. The time by default is 0.1 frames plus this keyvalue |

In HAMMER/JACK/BSPGUY open Smart-Edit and add there the keyvalues of your selection.

- The key is the classname of a weapon in the map that is going to be replaced.

- The value is the classname of the weapon that will replace the current one.

Example:
```angelscript
"weapon_rpg" "weapon_rpg_classic"
```

In the same way, it is used to change models.

- The key is the model in the map to replace.

- The value is the new model to use.

Example:
```angelscript
"models/hlclassic/scientist.mdl" "models/headcrab.mdl"
```

⚠️ Dont forget that since classic mode is active, some models will be replaced by the game and will change. For example ``models/hlclassic/barney.mdl`` instead of ``models/barney.mdl``

### Ignore entity

- Using (in any entity) a [Custom Key Value](custom_keyvalue_english.md) ``"$i_classic_mode_ignore"`` in a value of **1** will prevent replacing a weapon or model.

⚠️ Use only one entity per map

[Test map](../../../maps/1test_config_classic_mode.bsp)

---

# config_map_cvars

![image](../../images/angelscript.png)

config_map_cvars is an alternative entity in Angelscript for [trigger_setcvar](trigger_setcvar_english.md) that allows to change multiple [Cvars](../game/cfg_english.md) at the same time or even read them with [trigger_condition](trigger_condition_english.md) and and execute actions depending on that.

<details><summary>Install</summary>
<p>

Requirements:
- [config_map_cvars](../../../scripts/maps/mikk/config_map_cvars.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Download with a clic](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_map_cvars
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

En tu map_script Agrega:
```angelscript
#include "mikk/config_map_cvars"

void MapInit()
{
	config_map_cvars::Register();
}
```

</p>
</details>

Add any Cvar(Supported ones listed in the FGD) and activate the entity, alternatively use spawnflag 1 to automatically activate.

Activate an entity with the respective trigger [USE_TYPE](triggering_system_english.md) .

In HAMMER/JACK/BSPGUY open Smart-Edit and add the desired cvars.

- The key is the cvar to update.

- The value is the new value to update.

Example:
```angelscript
"mp_allowplayerinfo" "0"
```

- USE_OFF
	- Returns the original cvars that were changed

- USE_ON / USE_TOGGLE
	- Update the specified cvars

- spawnflags 1 (Start On)
	- Active, The cvars will update automatically on map start |
- spawnflags 2 (Store Cvars)
	- Store in the entity the current values of the cvars inside of it, you read them with [trigger_condition](trigger_condition_english.md) and execute actions depending on the values |
	- These are stores in the [Custom Key Value](custom_keyvalue_english.md) format, The format is ``$s_( nombre del cvar)``

---

# config_map_precache

![image](../../images/angelscript.png)

config_map_precache is an alternative entity made in Angelscript for [custom_precache](custom_precache_english.md) that allows to precach models, sounds, sprites, tga, monsters etc.

<details><summary>Install</summary>
<p>

Requirements:
- [config_map_precache](../../../scripts/maps/mikk/config_map_precache.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Download with a clic](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_map_precache
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

En tu map_script Agrega:
```angelscript
#include "mikk/config_map_precache"

void MapInit()
{
	config_map_precache::Register();
}
```

</p>
</details>

In HAMMER/JACK/BSPGUY open Smart-Edit and add there the desired keyvalues.

- The key is the method to precach.

- The value is the object to precach.

| key | Descripción | Ejemplo |
|-------|-----------|---------|
| model | Used to precach models and sprites | "model#1" "models/barney.mdl" |
| entity | Used to precach files that are used by entites, for example monsters | "entity#4" "monster_zombie" |
| sound | Used to precach sounds inside the folder "sounds/" ( Don't specify that folder, since we are inside the directory ) | "sound#0" "ambience/background_sex.wav" |
| generic | Used to precach anything, for skyboxs you have to precach all manually | "generic#20" "gfx/env/mysky_bk.tga" |

---

# config_survival_mode

![image](../../images/angelscript.png)

config_survival_mode is an entity made in Angelscript that modifies survival mode and does it better.

<details><summary>Install</summary>
<p>

Requirements:
- [config_survival_mode](../../../scripts/maps/mikk/config_survival_mode.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Download with a clic](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_survival_mode
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

In your map_script add:
```angelscript
#include "mikk/config_survival_mode"

void MapInit()
{
	config_survival_mode::Register();
}
```

</p>
</details>

Activate the entity giving trigger with the respective [USE_TYPE](triggering_system_english.md) .

- USE_OFF
	- Desactivate survival mode

- USE_ON
	- Activate survival mode

- USE_TOGGLE
	- Toggle survival mode

- If the entity is activated before it reaches its limit ``mp_survival_startdelay`` then its value will be forced to 0 and survival mode starts automatically.

| key | description |
|-----|-------------|
| delay | Time, in seconds, that this entity waits before activating all of its targets |
| target_toggle | Target to activate when survival mode has been toggled |
| target_failed | Target to activate when survival mode recieves an USE_ON but it is already active, or when it recieves an USE_OFF but it is already inactive |
| mp_survival_startdelay | Time, in seconds, that it takes for survival mode to activate, if it is empty, it will use the cvar mp_survival_startdelay |
| mp_respawndelay | Time, in seconds, that players have to wait to revive, if it is empty it will use the cvar mp_respawndelay |
| master | [multisource](multisource_english.md) that blocks this entity from being activated by its mp_survival_startdelay or by direct trigger |

⚠️ Only use one of this entity per map
