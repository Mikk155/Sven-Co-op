# config_classic_mode

![image](../../images/angelscript.png)

config_classic_mode is an entity made in Angelscript that allows to replace models, weapons and items depending if classic mode is active or not. The focus of this entity is to allow mappers to change models and weapons that the classic mode does not change by default.

<details><summary>Install</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- scripts/maps/mikk/[config_classic_mode.as](../../../scripts/maps/mikk/config_classic_mode.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

- Behaviur of [activation](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Toggle classic mode | Deactivate classic mode | Activate classic mode | Toggle classic mode | !activator | USE_TOGGLE |

| key | Descripción |
|-----|-------------|
| spawnflags 1 (Restart now) | Activate, the map will restart to apply the changes. |
| delay | Time before triggering all the targets |
| m_iszTargetOnToggle | target to trigger after classic mode has been successfully alternated |
| m_iszTargetOnFail | target to trigger when classic mode recieves USE_OFF but it was already off, or when it recieves USE_ON but it was already on |
| m_iszTargetOnEnable | target to trigger when classic mode has been activated. (After map restart) |
| m_iszTargetOnDisable | target to trigger when classic has been deactivated. (After map restart) |
| m_iThinkTime | Thinking time of the entity, a high value will consume less CPU but players could see a HD model in classic mode for an instant. The time by default is 0.1 frames plus this keyvalue |

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

- Using (in any entity) a [Custom Key Value](custom_keyvalue.md) ``"$i_classic_mode_ignore"`` in a value of **1** will prevent replacing a weapon or model.

⚠️ Use only one entity per map

[Test map](../../../maps/1test_config_classic_mode.bsp)

---

# config_map_cvars

![image](../../images/angelscript.png)

config_map_cvars is an alternative entity in Angelscript for [trigger_setcvar](trigger_setcvar.md) that allows to change multiple [Cvars](../game/cfg.md) at the same time or even read them with [trigger_condition](trigger_condition.md) and execute actions depending on that.

<details><summary>Install</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- [config_map_cvars.as](../../../scripts/maps/mikk/config_map_cvars.as)
	- [utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

Add any Cvar(Supported ones listed in the FGD) and activate the entity, alternatively use spawnflag 1 to automatically activate.

In HAMMER/JACK/BSPGUY open Smart-Edit and add the desired cvars.

- The key is the cvar to update.

- The value is the new value to update.

Example:
```angelscript
"mp_allowplayerinfo" "0"
```

- Behaviur of [activation](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Update the specified cvars | Returns the original cvars that were changed | Update the specified cvars | Update the specified cvars | | |

- spawnflags 1 (Start On)
	- Active, The cvars will update automatically on map start |
- spawnflags 2 (Store Cvars)
	- Store in the entity the current values of the cvars inside of it, you read them with [trigger_condition](trigger_condition.md) and execute actions depending on the values |
	- These are stores in the [Custom Key Value](custom_keyvalue.md) format, The format is ``$s_( nombre del cvar)``

---

# config_map_precache

![image](../../images/angelscript.png)

config_map_precache is an alternative entity made in Angelscript for [custom_precache](custom_precache.md) that allows to precach models, sounds, sprites, tga, monsters etc.

<details><summary>Install</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- [config_map_precache.as](../../../scripts/maps/mikk/config_map_precache.as)
	- [utils.as](../../../scripts/maps/mikk/utils.as)

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

- Read [Install](../install.md)

- Requirements
	- [config_survival_mode.as](../../../scripts/maps/mikk/config_survival_mode.as)
	- [utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

- Behaviur of [activation](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Toggle survival mode | Desactivate survival mode | Activate survival mode | Toggle survival mode | !activator | USE_TOGGLE |

- If the entity is activated before it reaches its limit ``mp_survival_startdelay`` then its value will be forced to 0 and survival mode starts automatically.

| key | description |
|-----|-------------|
| delay | Time, in seconds, that this entity waits before activating all of its targets |
| m_iszTargetOnToggle | Target to activate when survival mode has been toggled |
| m_iszTargetOnFail | Target to activate when survival mode recieves an USE_ON but it is already active, or when it recieves an USE_OFF but it is already inactive |
| mp_survival_startdelay | Time, in seconds, that it takes for survival mode to activate, if it is empty, it will use the cvar mp_survival_startdelay |
| mp_respawndelay | Time, in seconds, that players have to wait to revive, if it is empty it will use the cvar mp_respawndelay |
| master | [multisource](multisource.md) that blocks this entity from being activated by its mp_survival_startdelay or by direct trigger |

⚠️ Only use one of this entity per map
