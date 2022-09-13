[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Custom titles.txt sadly is not a feature and probably will never be. but do not worry. we have the perfect "tool" (if it can be called like that) for lazy people like you!

a simple script that [Gaftherman](https://github.com/Gaftherman) did within two hours. this will help you to take all text references that are present in the titles.txt of the mod you're porting and paste them in another text file as a ripent format. or if your preferance is a format for using with ``g_EntityLoader.LoadFromFile`` you can do it as well.

Download the script [ReadTitles.as](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/gaftherman/ReadTitles.as) and the text files [titles.txt](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/store/titles/titles.txt) and [newtitles.txt](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/store/titles/newtitles.txt)

titles.txt should be the mod's titles.txt while newtitles.txt is only needed to be present. could be empty as well.

**INSTALL:**
```
└── 📁svencoop
    └── 📁scripts
        └── 📁maps
            ├── 📁gaftherman
            │   └── 📄ReadTitles.as
            └── 📁store
                └── 📁titles
                    ├── 📄titles.txt
                    └── 📄newtitles.txt     
```

⚠️**NOTE:** It is important to place it into "svencoop/" and not svencoop_addon or else. because the function will not work.

Once there. pick any map for do this. sample get to hl_c04.cfg and go to the line...
```
map_script HLSP
```
And now replace with this...
```
map_script gaftherman/ReadTitles
```

Then run Sven Co-op and now run hl_c04. that's it. now go to...
```
svencoop/scripts/maps/store/titles/newtitles.txt
```

then it now contains a bunch of game_text that all of them has the proper keyvalues in order from the titles.txt

now you only have to set targetnames and put them into your maps.

The script contains three customizable things.
```angelscript
string EntityName = "game_text";
bool RipentStyle = true;
bool DebugMode = true;
```

``EntityName`` defines the classname of the entity generated.

``DebugMode`` defines if show the original titles.txt in your console or not.

``RipentStyle`` defines how to generate the text file. if turn true it will adopt ripent style. 

Preview:
```angelscript
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "OK"
"name" "Menu_OK"
}
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "Cancel"
"name" "Menu_Cancel"
}
```

if turn to false it will generate the text with the adittion of ``"entity"\n`` that's for Angelscript function ``g_EntityLoader.LoadFromFile`` that's present in our multi_language MapScript

Preview:
```angelscript
"entity"
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "OK"
"name" "Menu_OK"
}
"entity"
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "Cancel"
"name" "Menu_Cancel"
}
```
Imagine a tool into a game🦃



# SPANISH

La posibilidad de añadir tu propio titles.txt lamentablemente no es una mecanica y probablemente jamas lo sea. pero no te preocupes. tenemos la correcta "Herramienta" (Si podemos llamarla asi)

Un script simple que [Gaftherman](https://github.com/Gaftherman) hizo alrededor de 2 horas. este script tomará todas las referencias presentes en un titles.txt de tu mod que estes portando y los pegará en otro texto como formato ripent. o si lo prefieres el formato de ``g_EntityLoader.LoadFromFile``

Descarga el script [ReadTitles.as](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/gaftherman/ReadTitles.as) y los textos [titles.txt](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/store/titles/titles.txt) y [newtitles.txt](https://github.com/Mikk155/AngelScript-Sven-Co-op/blob/main/scripts/maps/store/titles/newtitles.txt)

titles.txt deberia ser el archivo del mod mientras que newtitles.txt es un archivo vacio que necesita estar presente para ser re escrito.

**INSTALAR:**
```
└── 📁svencoop
    └── 📁scripts
        └── 📁maps
            ├── 📁gaftherman
            │   └── 📄ReadTitles.as
            └── 📁store
                └── 📁titles
                    ├── 📄titles.txt
                    └── 📄newtitles.txt     
```

⚠️**NOTA:** Es importante ponerlos dentro de "svencoop/" y no "svencoop_addon" u otros. de lo contrario no funcionará

Una vez hecho. toma cualquier mapa para usar la herramienta. por ejemplo hl_c04.cfg y ve a la linea...
```
map_script HLSP
```
y reemplaza con esto...
```
map_script gaftherman/ReadTitles
```

Luego inicia el juego y ve al mapa hl_c04. eso es todo. ahora ve a...
```
svencoop/scripts/maps/store/titles/newtitles.txt
```

y ahora este texto contendrá un monton de game_text con las keyvalues correctas del titles.txt

Ahora solo debes asignarles nombres y ponerlos en tus mapas.

El script contiene 3 opciones a elección.
```angelscript
string EntityName = "game_text";
bool RipentStyle = true;
bool DebugMode = true;
```

``EntityName`` define el classname de las entidades que serán creadas.

``DebugMode`` define si mostrar debugs en la consola o no.

``RipentStyle`` define como generar el texto si usar la syntax de ripent o la de g_EntityLoader.LoadFromFile

Preview:
```angelscript
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "OK"
"name" "Menu_OK"
}
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "Cancel"
"name" "Menu_Cancel"
}
```

Si eliges "false" una linea ``"entity"\n`` va a ser generada. eso es para la función de Angelscript ``g_EntityLoader.LoadFromFile`` Que nosotros usamos en nuestro game_text_custom.

Preview:
```angelscript
"entity"
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "OK"
"name" "Menu_OK"
}
"entity"
{
"classname" "game_text"
"x" "-1"
"y" "0.67"
"effect" "0"
"color" "100 100 100"
"color2" "240 110 0"
"fadein" "1.5"
"fadeout" "0.5"
"fxtime" "0.25"
"holdtime" "1.2"
"message" "Cancel"
"name" "Menu_Cancel"
}
```
Imagina una herramienta dentro de un juego🦃