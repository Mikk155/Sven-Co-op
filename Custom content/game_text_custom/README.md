A entity & a plugin that will let players choose the language that they want to see in-game.

samples and supported languages:
key | value
----|------
"message" | "hello world. this is my english and default message"
"message_spanish" | "hola mundo. este es mi mensaje en español"
"message_portuguese" | "Ola Mundo. esta e minha mensagem em portugues"
"message_italian" | "Ciao mondo. questo e il mio messaggio in italiano"
"message_french" | "Bonjour le monde. c'est mon message italien"
"message_german" | "Hallo Welt. das ist meine italienische Botschaft"
"message_esperanto" | "Saluton mondo. jen mia mesago en esperanto"

Maps that uses this feature:
Multi-language support | download campaign | spanish | PT/BR | german | french | italian | esperanto
-----------------------|-------------------|---------|-------|--------|--------|---------|----------
[Restriction](https://github.com/Mikk155/Sven-Co-op/releases/download/svencoop/svencoop_addon.rar) | [scmapdb](http://scmapdb.com/map:restriction) | V | X | X | X | X | X

HOW TO INSTALL:
as any other plugin, add multi_language.as to your default_plugins.txt. 

should look like this:
```
	"plugin"
	{
		"name" "Multi-Language"
		"script" "multi_language"
	}
```

then register the game_text_custom on the campaigns/maps you want to have localizations. 

should look like this:
```
#include "multi_language"

void MapInit()
{
	MultiLanguageInit();
}

void MapActivate()
{
	MultiLanguageActivate();
}
```

please. if you do a localization for any maps, let me know so i add them on the list.

**Please do not repack this script**
Link them to this Github's Latest release.
if not, at least keep your page updated because more languages support could be added.


Doing localizations:

1-	create a .ent file with the name of the map you want to add localization.
		see scripts/maps/multi_language/localizations/ first before you do anything.

2-	add there all the game_text n/or env_messages that map uses like if it was a ent file.
	FORMAT:
```
"entity"
{
	"message" "damn"
	"message_spanish" "carajo"
	"message_portuguese" "caralho"
	"targetname" "scientist_die"
	"dont forget all the other values from the original text" ":p"
	"classname" "game_text_custom"
}
"entity"
{
	"more of the same" ":)"
	"classname" "game_text_custom"
}
```

-3 let me know that you did a localization.


once the script is in a certain map. it'll check if a .ent with the same name exist. if yes all game_text and env_message will be removed from the world and your game_text_custom in the .ent file will be generated.


Original idea and base entity by [kmkz](https://github.com/kmkz27)

Plugin and Improved entity by [Gaftherman](https://github.com/Gaftherman)

Localizations credits:
Translator | language | maps
-----------|----------|-----
Mikk | Spanish | Restriction
Teemo | Portuguese | Restriction
