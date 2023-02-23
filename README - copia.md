
[game_stealth](#game_stealth) | Allow mappers to make use of stealth mode in Co-op.
[game_time](#game_time) | ntity that allow mappers to make use of real time and custom time. create maps with timers n/or timelapse day/night fire entities depending the time etc.
[game_trigger_iterator](#game_trigger_iterator) | Entity that will fire its target with the activator and caller that it specifies.
[game_zone_entity](#game_zone_entity) | Entity similar to game_zone_player but now supports any entity in its volume not only players.
[item_oxygentank](#item_oxygentank) | Entity that will give oxygen to players that touch it.
[monster_damage_inflictor](#monster_damage_inflictor) | Feature for passing a monster's Attacker/damage inflictor as a !activator via npc's TriggerTarget key.
[player_command](#player_command) | Entity that allow mappers to force players to execute a cmd onto their consoles.
[trigger_changevalue](#trigger_changevalue) | Allow trigger_changevalue to change keyvalues from a specified weapon of the player activator
[trigger_individual](#trigger_individual) | Allow Trigger-Type entities to fire its target only once per activator.
[trigger_multiple](#trigger_multiple) | Allow trigger_multiple entity to fire its target for every one inside its volume.
[trigger_random](#trigger_random) | Allow trigger_random to set a unique random value.
[trigger_sound](#trigger_sound) | Entity like env_sound but as a brush entity
[trigger_votemenu](#trigger_votemenu) | Entity that allow mapper to create a buymenu-like vote for one or all players.
[utils](#utils) | utils is a script that contains alot of useful features and code that is being shared with my other scripts so in most of the cases you have to include this script.


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









# utils
**Introduction:**

utils is a script that contains alot of useful features and code that is being shared with my other scripts so in most of the cases you have to include this script.






### Basically FireTargets but we use this for custom entities to allow them to do use of [USE_TYPE](#utils-use-type)
```angelscript
g_Util.Trigger( string& in key, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE& in useType = USE_TOGGLE, float& in flDelay = 0.0f )
```






### Send a string, replace the arguments sent, return the new string.
```angelscript
g_Util.StringReplace( string_t FullSentence, dictionary@ pArgs )
```
**Sample:**
```angelscript
g_Util.StringReplace( "this !number-st test for !activator", { { "!number", self.pev.frags }, { "!activator", pActivator.pev.netname }, } );
```
Then it will return a string like this
```angelscript
"this 1-st test for Mikk"
```






### Shows a motd to the given player.
```angelscript
g_Util.ShowMOTD( EHandle hPlayer, const string& in szTitle, const string& in szMessage )
```






### Shows a message to client's console if the next function is set.
```angelscript
g_Util.DebugMessage( const string& in szMessage )
```






### Set to true and messages will be shown.
```angelscript
g_Util.DebugMode( const bool& in blmode = false )
```






### Return as a string the value of the given custom keyvalue from the given entity.
```angelscript
g_Util.GetCKV( CBaseEntity@ pEntity, string szKey )
```






### Set a custom keyvalue for the given entity.
```angelscript
g_Util.SetCKV( CBaseEntity@ pEntity, string szKey, string szValue )
```






### Boolean that returns true if the given text file contains szComparator as a line. use as a blacklist by giving g_Engine.mapname
```angelscript
g_Util.IsStringInFile( const string& in szPath, string& in szComparator )
```






### Boolean that returns true if the given plugin name is installed.
```angelscript
g_Util.IsPluginInstalled( const string& in szPluginName )
```






### Set information for this map/script. will be shown when a player connects or type in chat "/info"
```angelscript
g_Util.ScriptAuthor.insertLast
    (
        "Map: "+ string( g_Engine.mapname ) +"\n"
        "Author: Mikk\n"
        "Github: github.com/Mikk155\n"
        "Description: Test almost of the scripts.\n"
    );
```












### Supported Languages
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
