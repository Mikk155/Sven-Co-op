[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Multi-Language offers to Scriptes and Mappers the hability of doing use of adding language support for player's choice that they can change on-the-fly dynamically.

game_text_custom is a custom entity aimed to replace game_text but adding support for languages and some other new features.

The original entity has been created by [kmkz](https://github.com/kmkz27)

Then modified by me and [Gaftherman](https://github.com/Gaftherman)

**Installation:**
```angelscript
#include "mikk/multi_language"
#include "mikk/entities/utils"
#include "mikk/entities/game_text_custom"

void MapInit()
{
	RegisterCustomTextGame();
	MultiLanguageInit();
}
```

for example this entity adds extensions for "effect" keyvalue. vanilla has only 3 ( 0, 1, 2 ) that's for game_text effects.

**the new effects are:**
| value | description |
|-------|-------------|
| 3 | it uses the same effect. color and &time as CTrigger entities keyvalue "message" |
| 4 | Shows a MOTD Page |
| 5 | Shows a chat message |
| 6 | Subtitle style (WIP) |

The fact of game_text_custom is that it goes in conjunction of multi_language.as (MapScript not Plugin) that adds a feature for Spawn game_text_custom via a external file. that mean you do not need to modify your or anyone else maps.

**the script will read a .ent file located at:**
``
scripts/maps/multi_language/(map name).ent
``

the syntax is the same as using ripent with the requirement that you need to write something every new entity. example:
```angelscript
"entity"
{
"classname" "game_text_custom"
"channel" "1"
"fxtime" "0.25"
"holdtime" "17"
"fadeout" "1.5"
"fadein" "0.05"
"color2" "100 100 100"
"spawnflags" "1"
"color" "53 119 240"
"effect" "2"
"y" "0.80"
"x" "-1"
"targetname" "offer_msg_1"
"message" "Gordon Freeman in the flesh. Or rather, in the hazard suit."
"message_spanish" "Gordon Freeman en carne y hueso. O mas bien, en carne y traje de proteccion."
}
```
that ``"entity"`` is what you need to specify every new entity to add. pretty simple. but will not stock game_text interfer?

no. once the file is loaded (or not) just 1.0 second after that. the multi_language.as will look for all game_text_custom, game_text and env_message entities in the world and compare them.
if env_message/game_text has the same targetnames as your spawned game_text_custom. they get removed from the world while only game_text_custom are preserved

There is a [list](https://github.com/Mikk155/AngelScript-Sven-Co-op/wiki/Translated-maps) of maps and series that uses this entity.

For using this entity see all [Supported-Languages](https://github.com/Mikk155/AngelScript-Sven-Co-op/wiki/Supported-Languages)

Then check [this directory](https://github.com/Mikk155/AngelScript-Sven-Co-op/tree/main/scripts/maps/multi_language) and see what map series has languages support and what languages are supported. if you do any translation please let me know by discord Mikk#3885 or doing a pull request

For using in your own scripts see [Multi-Language](https://github.com/Mikk155/AngelScript-Sven-Co-op/wiki/Multi-Language) and [Entity Utils](https://github.com/Mikk155/AngelScript-Sven-Co-op/wiki/Entity-Utils)

IMPORTANT NOTES: Some characters and any key with quotes will be shows as weird and nonsense letters due to limitations of HudMessage. so try to avoid any of them.