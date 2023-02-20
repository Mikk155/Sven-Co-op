# Sven-Co-op Repository

An assortment of test maps, additional information for SC stuff, Angelscript plugins / map-scripts, new entities and anything related to SC.










<details><summary>People who contributed in any way 🛠️</summary>
<p>
	
[Gaftherman](https://github.com/Gaftherman)
---
Sparks Discord: [Sparks#1475]()
---
[KEZÆIV](https://www.youtube.com/channel/UCV5W8sCs-5EYsnQG4tAfoqg)
---
[Giegue](https://github.com/JulianR0)
---
[Duk0](https://github.com/Duk0)
---
[Outerbeast](https://github.com/Outerbeast)
---
[Cubemath](https://github.com/CubeMath)
---
[Rick](https://github.com/RedSprend)
---
[Litude](https://github.com/Litude)
---
[Wootguy](https://github.com/wootguy)
---

</p>
</details>

---




















<details><summary>Contact Info 📫</summary>
<p>

Username: ``Mikk#3885``
---
Username: ``Gaftherman#0231``
---
[Discord server invite](https://discord.gg/VsNnE3A7j8)
---
![server](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/images/limitless_potential.png)

</p>
</details>

![discord](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/images/discord.png)

---
























<details><summary>Tutorials 🖊️</summary>
<p>

[env_global](#env_global)

<details><summary>numerical padlock</summary>
<p>

Creates a full customizable code **on-the-fly** for a numerical padlock. this system works using a game_counter and a trigger_random for randomizing the code needed, feel free to make a better randomizing system of 3 digits from number 0 to 9

**Download**
```
└── 📁svencoop_addon
    └── 📁maps
        └── 📄1test_numpad.bsp
```

once you fire the "randomizing button" 3 copyvalue will paste those random numbers into a trigger_condition.

then every numerical plate will add a value of their owns into another entity while the mentioned trigger_condition will check if the numbers was touched in order and if they're correct.

- If someone is using the camera then others players can't interfer

- using the plate bellow "8" will delete all your previous attempts, basically restore.

- next to player spawn there are some entities that they're only for DEBUG purpose. delete them.

go to map ``1test_numpad``

Test map by Mikk

---

</p>
</details>

<details><summary>Un-embed textures from a BSP</summary>
<p>

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

---

</p>
</details>

</p>
</details>

---






























<details><summary>Plugins 🗂️</summary>
<p>

<details><summary>BloodPuddle</summary>
<p>

BloodPuddle Generates a blood puddle when a monster die.

<details><summary>Download</summary>
<p>


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

</p>
</details>

<details><summary>Install</summary>
<p>

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
if set to ``true``, the generated blood puddles will disapear as soon as the monster who generated it disapears.

if set to ``false``, the generated blood puddles won't disapear

</p>
</details>

---

</p>
</details>

<details><summary>NoAutoPick</summary>
<p>

NoAutoPick Make items/weapons pick-able only if pressing E-key.

<details><summary>Download</summary>
<p>

```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄NoAutoPick
```

</p>
</details>

<details><summary>Install</summary>
<p>

```angelscript
    "plugin"
    {
        "name" "NoAutoPick"
        "script" "NoAutoPick"
    }
```

</p>
</details>

---

</p>
</details>

<details><summary>PlayerDeadChat</summary>
<p>

PlayerDeadChat Make dead player's messages readable for dead players only

<details><summary>Download</summary>
<p>

```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄PlayerDeadChat
```

</p>
</details>

<details><summary>Install</summary>
<p>

```angelscript
    "plugin"
    {
        "name" "PlayerDeadChat"
        "script" "PlayerDeadChat"
    }
```

</p>
</details>

---

</p>
</details>

<details><summary>RenameServer</summary>
<p>

RenameServer Changes your server's hostname dynamicaly depending the map playing

<details><summary>Download</summary>
<p>

```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁plugins
            └── 📄RenameServer
```

</p>
</details>

<details><summary>Install</summary>
<p>

```angelscript
    "plugin"
    {
        "name" "RenameServer"
        "script" "RenameServer"
    }
```

</p>
</details>

<details><summary>Modify</summary>
<p>

line 18 should be your server's hostname:
```angelscript
// Name of your server
const string strHostname = "[US] Limitless Potential (Hardcore + Anti-Rush)";
```

Here you must add the new arguments, the first string in the array is the first chars of the map name while the second argument is the display name
```angelscript
// < name of your map        |        title of your hostname >

string[][] strMaps = 
{
    {"hl", "Half-Life"},

    {"rp", "Residual Point"},

    {"rl_", "Residual Life"},

    {"ast_", "A Soldier's Tale"},

    {"tln_", "The Long Night"},

    {"accesspoint", "Access Point"},

    {"bridge_the_gap", "Bridge The Gap"},

    {"bm_sts", "BM: Special Tactics"},

    {"ba", "Blue-Shift"},

    {"hcl", "Hardcore-Life"},

    {"of_utbm", "Under The Black Moon"},

    {"of", "Opposing-Force"}
};
```
Your server's hostname will look like this:
```angelscript
"[US] Limitless Potential (Hardcore + Anti-Rush) Playing Opposing-Force"
```

</p>
</details>

---

</p>
</details>

</p>
</details>

---



<details><summary>Scripts & Entities</summary>
<p>

Make use of our [FGD](https://github.com/Mikk155/Sven-Co-op/blob/main/develop/forge%20game%20data/sven-coop.fgd)

| Entity / Script | Description | is Angelscript | has Angelscript feature |
|-----------------|-------------| :------------: | :---------------------: |
[ambient_generic](#ambient_generic) | Entity for reproduce a sound | ❌ | ❌ 
[ambient_music](#ambient_music) | Entity for reproduce a music song. | ❌ | ❌ 
[ammo_custom](#ammo_custom) | Entity that gives a specified ammout of bullets that the entity sets. | ✔️ | ✔️ 
[ammo_](#ammo_) | Ammunition entities. | ❌ | ✔️ 
[config_classic_mode](#config_classic_mode) | Entity that allow mapper to customize classic mode. | ✔️ | ✔️ 
[config_map_precache](#config_map_precache) | Entity that precache almost anything. | ✔️ | ✔️ 
[config_survival_mode](#config_survival_mode) | Entity that allow mapper to customize survival mode. | ✔️ | ✔️ 
[entitymaker](#entitymaker) | Entity that when is fired it creates any entity on its origin and using the same keyvalues that entitymaker has. | ✔️ | ✔️ 
[cycler](https://sites.google.com/site/svenmanor/entguide/cycler) | Entity used to display models in your map. | ❌ | ❌ 
[cycler_sprite](https://sites.google.com/site/svenmanor/entguide/cycler_sprite) | Entity used to display sprites in your map. | ❌ | ❌ 
[cycler_weapon](https://sites.google.com/site/svenmanor/entguide/cycler_weapon) | Entity that appears to be an unfinished entity originally by Valve. | ❌ | ❌ 
[env_alien_teleport](#env_alien_teleport) | Entity that spawns (with xen FX) a specified monster around a random player. | ✔️  | ✔️  
[env_beam](https://sites.google.com/site/svenmanor/entguide/env_beam) | The env_beam entity is used to create a bolt between two entities. | ❌ | ❌ 
[env_beverage](https://sites.google.com/site/svenmanor/entguide/env_beverage) | Spawns a can. used for black mesa dispensers. | ❌ | ❌ 
[env_blood](https://sites.google.com/site/svenmanor/entguide/env_blood) | Entity which, when triggered, creates a blood splash at its origin, which can cause blood decals on nearby walls, ceiling and floor. | ❌ | ❌ 
[env_bloodpuddle](#env_bloodpuddle) | Generates a blood puddle when a monster die. | ✔️ | ✔️   
[env_effect](#env_effect) | Entity used for showing various effects. | ✔️ | ✔️  
[env_explosion](https://sites.google.com/site/svenmanor/entguide/env_explosion) | Entity which, when triggered, creates an explosion which damages everything damageable around it. | ❌ | ❌ 
[env_fade](https://sites.google.com/site/svenmanor/entguide/env_fade) | Entity that causes the players' screens to have an in- or out-fading color to be drawn over them. | ❌ | ❌ 
[env_fog](#env_fog) | Entity which creates a fog effect within a specific area around it. | ❌ | ✔️  
[env_fog_individual](#env_fog_individual) | Expands env_fog features to show fog to activator only.| ✔️  | ✔️  
[env_funnel](https://sites.google.com/site/svenmanor/entguide/env_funnel) | Creates a large portal funnel particle effect of green particles | ❌ | ❌ 
[env_geiger](#env_geiger) | Entity that simulates radiation sound in a small radius of its origin. | ✔️ | ✔️ 
[env_global](#env_global) | Entity used to transport information between two or more maps. | ❌ | ❌ 


</p>
</details>

---

# End of lists

### ambient_generic

<details><summary>Introduction</summary>
<p>

General information in [svenmanor](https://sites.google.com/site/svenmanor/entguide/ambient_generic)

- Using the spawnflag 64 ( User Only ) and the spawnflag 1 ( Play everywhere ) will make the flag 64 useless and the sound will be played for everyone and the activator will hear it twice.

</p>
</details>

---

### ambient_music

<details><summary>Introduction</summary>
<p>

General information in [svenmanor](https://sites.google.com/site/svenmanor/entguide/ambient_music)

- For each client. the volume of this entity depends on their configuration for MP3 Volume (Cvar ``MP3Volume`` and ``MP3FadeTime`` ) some players has this always muted. so setting ambient_generic instead would be fine but keep in mind that hearing a song always for each map-restart is annoying at some point.

</p>
</details>

---

### ammo_custom

<details><summary>Introduction</summary>
<p>

ammo_custom is an ammo item customizable that gives a specified ammout of bullets that the entity sets.

</p>
</details>

<details><summary>Download</summary>
<p>

```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄ammo_custom.as
                └── 📄utils.as
```


</p>
</details>

<details><summary>Install</summary>
<p>

```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

</p>
</details>

<details><summary>Usage</summary>
<p>

Supports all [ammo_](https://sites.google.com/site/svenmanor/entguide/ammo) keyvalues.

| key | value | description |
|-----|-------|-------------|
| w_model | string | defines a custom world model |
| p_sound | string | defines a custom sound to use when the item is taken |
| am_name | [choices](#values-am_name) | defines the type of ammunition this item will give to players |
| am_give | integer | number of bullets that this item should give to the players |
| frags | integer | How many times player can take this item (affect only activator) 0 = infinite ( if set and player is above the count, the item is render invisible for that player and he can't pickup it anymore |

### Values am_name

<details><summary>See Values</summary>
<p>

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

</p>
</details>


<details><summary>Notes</summary>
<p>

⚠️ The player must have already equiped the items that classifies as "weapons" the ammo will be added but the player won't be able to select them until collect a weapon.

List:
- satchel
- Trip Mine
- Hand Grenade
- snarks

</p>
</details>

</p>
</details>

---

### ammo_

<details><summary>Introduction</summary>
<p>

General information in [svenmanor](https://sites.google.com/site/svenmanor/entguide/ammo)

- This entity supports the expansion of [trigger_individual](#trigger_individual)

</p>
</details>

---

### config_classic_mode

<details><summary>Introduction</summary>
<p>

config_classic_mode is a entity that allow you to customize classic mode for monsters, models and items that the game doesn't support.

it also allows you to swap **any** model into a classic model if specified by the entity.

</p>
</details>

<details><summary>Installation</summary>
<p>

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

</p>
</details>

<details><summary>Usage</summary>
<p>

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
| health | float | this is the entity's think function. using higher value will consume less cpu but players may notice the HD model changing to a classic mode. default is 0.1f + health |

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

### Additional information:

⚠️ Don't forget that since classic mode is enabled the model you need to replace is not "models/barney.mdl" it is "models/hlclassic/barney.mdl"

- Using (on any entity) custom keyvalue ``"$i_classic_mode_ignore"`` will prevent their model being changed or item being replaced.

⚠️ Use only **one** entity per map. if there is more than one, one random entity will be removed.

</p>
</details>

---

### config_map_precache

<details><summary>Description</summary>
<p>

config_map_precache is a entity that precache almost anything.

</p>
</details>


<details><summary>Installation</summary>
<p>

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

</p>
</details>

<details><summary>General information</summary>
<p>

A custom entity that allow mappers to precache almost anything

In HAMMER/JACK/BSPGUY open Smart-Edit and add there the keyvalues.

**syntax:**

- key -> option to precache.
- value -> thing to precache.

**Options:**
| key | description | sample |
|-------|-------------|--------|
| model | used to precache models and sprites. | "model#1" "models/barney.mdl" |
| entity | used to precache monsters and any other entities including custom entities. | "entity#4" "monster_zombie" |
| sound | used to precache a sound inside "sound/" folder. do not specify that folder! | "sound#0" "ambience/background_sex.wav" |
| generic | used to precache anything else. up to you for testing. for skybox you have to precache all files individually | "generic#20" "gfx/env/mysky_bk.tga" |

</p>
</details>

---

### config_survival_mode

<details><summary>Description</summary>
<p>

config_survival_mode is a entity that customize survival mode and make it better.

</p>
</details>

<details><summary>Installation</summary>
<p>

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

</p>
</details>

<details><summary>Introduction</summary>
<p>

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

</p>
</details>

<details><summary>Notes</summary>
<p>

⚠️ Use only **one** entity per map. if there is more than one, one random entity will be removed.


</p>
</details>

---

### entitymaker

<details><summary>Description</summary>
<p>

entitymaker is a entity that when is fired it creates any entity on its origin and using the same keyvalues that entitymaker has.

basically trigger_createentity but we aimed to add a condition for it to spawn the entity or not, depending the condition set.

</p>
</details>

<details><summary>Installation</summary>
<p>

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

</p>
</details>

<details><summary>Introduction</summary>
<p>

</p>
</details>

---

### env_alien_teleport

<details><summary>Description</summary>
<p>

env_alien_teleport is a entity that randomly teleport in aliens on a random player.

</p>
</details>

<details><summary>Installation</summary>
<p>

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

</p>
</details>

<details><summary>Introduction</summary>
<p>

a custom entity that watch for alive players and then spawns a monster around a random alive player.


| key | value | description |
|-----|-------|-------------|
| target | target | trigger this target when an alien is spawned. the choosed player is the activator and the alien is the caller [Supports USE_TYPE](#utils-use-type) |
| noise | target | trigger this target when the monster can't spawn due to obstacles. the choosed player is the activator and the entity is the caller [Supports USE_TYPE](#utils-use-type) |
| delay | float | delay (seconds) between teleports |
| netname | string | classname of the alien that will spawns. can use trigger_changevalue on-demand, don't forget to precache them first. |
| message | target | xenmaker template to use its effect when the alien spawns. not blacklisted to a env_xenmaker classname, you can make your own effects. |

<details><summary>Notes</summary>
<p>

⚠️ Use only **one** entity per map. if there is more than one, one random entity will be removed.

</p>
</details>

- Original code by [Rick](https://github.com/RedSprend/svencoop_plugins/blob/master/svencoop/scripts/plugins/atele.as)


</p>
</details>

---

### env_bloodpuddle

<details><summary>Introduction</summary>
<p>

Generates a blood puddle when a monster die.

</p>
</details>

<details><summary>Installation</summary>
<p>

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
The function ``Register`` has two optional calls.

<details><summary>First function</summary>
<p>

```angelscript
const bool& in blRemove = false
```
if set to ``false`` or not set, the generated blood puddles won't disapear

if set to ``true``, the generated blood puddles will disapear as soon as the monster who generated it disapears.

**SAMPLE:**
```angelscript
#include "mikk/env_bloodpuddle"

void MapInit()
{
	env_bloodpuddle::Register( true );
}
```

</p>
</details>

<details><summary>Second function</summary>
<p>

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

</p>
</details>

</p>
</details>

<details><summary>Usage</summary>
<p>

Add [Custom KeyValues](https://sites.google.com/site/svenmanor/entguide/custom-keyvalues) to the monsters for the next features:

1.- Prevent monsters from generating blood puddles with ``$f_bloodpuddle`` -> ``1``

2.- Use custom skins for blood puddles with ``$i_bloodpuddle`` -> model skin value. if not set, the skin rely on monster's blood color (green/red/none)

</p>
</details>

---

### env_effect

<details><summary>Installation</summary>
<p>

**Download**
```
└── 📁svencoop_addon
    └── 📁scripts
        └── 📁maps
            └── 📁mikk
                ├── 📄env_effect.as
                └── 📄utils.as
```

**install:**
```angelscript
#include "mikk/env_effect"

void MapInit()
{
	env_effect::Register();
}
```

</p>
</details>

<details><summary>General information</summary>
<p>

</p>
</details>



<details><summary>Additional information</summary>
<p>

</p>
</details>

---

### env_fog

<details><summary>Introduction</summary>
<p>

General information in [svenmanor](https://sites.google.com/site/svenmanor/entguide/env_fog)

- This entity supports the expansion of [env_fog_individual](#env_fog_individual)

</p>
</details>

---

### env_fog_individual

<details><summary>Introduction</summary>
<p>

env_fog_individual is a entity that expands env_fog features to show fog to activator only. created for the use of env_fog in xen maps only (displacer teleport)

</p>
</details>

<details><summary>Installation</summary>
<p>


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

</p>
</details>

<details><summary>General information</summary>
<p>

Adds to env_fog a new spawnflag that allows the fog to be visible for activator only.

spawnflags -> 2 (Activator Only)

</p>
</details>

<details><summary>Additional information</summary>
<p>

- if spawnflag 1 is not set. joining players will fire this entity with USE_ON mean to disable you must pass all of them to fire the entity with USE_OFF.

</p>
</details>

---

### env_geiger

<details><summary>General information</summary>
<p>

env_geiger is a entity that simulates radiation sound in a small radius of its origin.

Send USE_OFF/ON/TOGGLE respectivelly.

</p>
</details>

<details><summary>Installation</summary>
<p>

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

</p>
</details>

---

### env_global

<details><summary>Introduction</summary>
<p>

env_global entity is used to transport information between two or more maps. allowing you to do different triggers depending in what state the previus map did set the global state.

General information: [svenmanor](https://sites.google.com/site/svenmanor/entguide/env_global)

### Test map:
**Download**
```
└── 📁svencoop_addon
    └── 📁maps
        ├── 📄1test_global3.bsp
        ├── 📄1test_global3.cfg
        ├── 📄1test_global3_motd.txt
        ├── 📄1test_global4.bsp
        ├── 📄1test_global4.cfg
        └── 📄1test_global4_motd.txt
```

go to map ``1test_global3``

Test map by Sparks

</p>
</details>

























---

### Utils Use Type

<details><summary>Description</summary>
<p>

Entities that supports this feature can send different Use Type depending what the value is. the same method as [multi_manager](https://sites.google.com/site/svenmanor/entguide/multi_manager) ( Triggering type On, Off, Toggle or Kill )

The default use-type is 'Toggle'. For other use-types, you must add a token to the value:

- For 'Off', add ``#0``

- For 'On', add ``#1``

- For 'Kill', add ``#2``

</p>
</details>

---