[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Multi-Language offers to Scripters and Mappers the hability to give use to multiple languages depending on the individual selection of each player.

this can be chosen on the go and by a prolonged time the selection of the player will be mantain during level changes or after leaving and reconecting to the server

The original idea was created by [Kmkz](https://github.com/kmkz27) and then developed by [Mikk](https://github.com/Mikk155) and [Gaftherman](https://github.com/Gaftherman)

This mechanic works for both mappers that want to add languages to their maps and people that simply want to translate existing mensages that use trigger_multiple, game_text or env_message.

But scripters can also use this mechanic in their own scripts simply verifying the player first, since the way to identify them was created using [Custom keyvalues](https://sites.google.com/site/svenmanor/entguide/custom-keyvalues)


**INSTALATION**

go to **svencoop/default_plugins.txt** and add the following:

```angelscript
    "plugin"
    {
        "name" "multi_language"
        "script" "mikk/multi_language"
    }
```
After installing separate packages these have to be located in **svencoop_addon/scripts/plugins/mikk/translations/**


This script will open a ".mlang" file with the name of the current map. that file is going to contain information about translations.

**LOCATE MAPS**

The synthesis is similar to ripent, starting and finishing the entity with brackets ( **{** / **}** )

Only that we are not going to use quotation marks ( **"** ) for the work.

We recommend installing the language enriched package to avoid confusion in the synthesis [multi_language.XML](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/multi_language.xml)

**INTALL XML IN NOTEPAD++**
![image1](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_1.png)

Create your own defined language

![image2](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_2.png)

![image3](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_3.png)

Name your language and finally loadNombra tu lenguaje load your language.

![image4](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_4.png)

NOTE: it may happen that when two or more defined language are created. make sure that you only have one loaded verifying that the values are not null.

we added additional mechanics to our entity aswell as to work exactly the same to game_text.

**ADDITIONAL KEYVALUES**

key "effect" was expanded and the additional effects do not require especifications of other keyvalues like color, position, etc.

value | description
------|------------
3 | use the same efect color and time of BaseTriggers with their keyvalue "message"
4 | Show a page of MOTD
5 | Show a message in chat
6 | show a subtitle [Work in Progress]
7 | Show a binded key on screen

"target" now supports the same mechanic that multi_manager to sent trigger types (ON/OFF/KILL)

To give use you havet o especify the amount of the final value.

Example: **"target" "TriggerThis#1"**
Value | type
------|-----
#0 | USE_OFF
#1 | USE_ON
#2 | USE_KILL

"messagesound" and "messagevolume" were added as support for env_message and work the same.

when assigning an existing brush-model to game_text_custom it will use the entity with the model especified as Touch() and will fire the text. in case of being a trigger_multiple game_text_custom will be renamed as the target of the multiple. if the multiple does not have a target then it will be the opposite case.

the netname of !activator is going to be saved in the "netname" of game_text_custom and can be used in any message's key as "!activator" 

Example: **"message" "The player !activator has activated the bomb"**

"frags" is mainly used to store numbers, however you can store strings aswell, the idea is use it in conjuction with trigger_copyvalue/changevalue and at the same time activate game_text_custom after the action.

Example: **"frags" "25"** -> **"message" " !frags seconds remaining to finish"** -> "25 seconds remaining to finish"

This way you can easily make a counter and modify it globally to all languages.



# SPANISH

Multi-Language ofrece a los Scripters y Mappers la habilidad de dar uso a multiples lenguajes dependiendo de la eleccion individual de cada jugador.

esto puede ser elegido sobre la marcha y por un tiempo prolongado la eleccion del jugador se mantendrá durante cambios de nivel o tras abandonar y reconectarte al servidor

La idea original fue creada por [Kmkz](https://github.com/kmkz27) y luego desarrollada por [Mikk](https://github.com/Mikk155) y [Gaftherman](https://github.com/Gaftherman)

Esta mecanica funciona tanto para mappers que quieren agregar lenguajes en sus mapas como para otras personas que simplemente quieren traducir mensajes ya existentes que utilicen trigger_multiple, game_text o env_message.

Pero los scripters tambien pueden utilizar esta mecanica en sus propios scripts simplemente verificando al jugador primero, ya que la manera de identificarlo fue creada utilizando [Custom keyvalues](https://sites.google.com/site/svenmanor/entguide/custom-keyvalues)


**INSTALACIÓN**

ir a **svencoop/default_plugins.txt** y añadir lo siguiente:

```angelscript
    "plugin"
    {
        "name" "multi_language"
        "script" "mikk/multi_language"
    }
```
Tras instalar paquetes separados estos deben ir localizados en **svencoop_addon/scripts/plugins/mikk/translations/**


Este script abrirá un archivo ".mlang" con el nombre del mapa actual. ese archivo contendrá informacion de traducciónes.

**LOCALIZAR MAPAS**

La sintesis es similar a ripent, iniciando y terminando entidad con brackets ( **{** / **}** )

Solo que no utilizaremos comillas ( **"** ) para el trabajo.

Recomendamos instalar el paquete de lenguaje enriquecido para evitar confusiones en la sintesis [multi_language.XML](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/multi_language.xml)

**INSTALAR XML EN NOTEPAD++**
![image1](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_1.png)

Crea tu propio lenguaje definido

![image2](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_2.png)

![image3](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_3.png)

Nombra tu lenguaje y finalmente carga tu lenguaje.

![image4](https://github.com/Mikk155/Sven-Co-op/blob/main/images/RichTextCode_4.png)

NOTA: puede susceder que se crean dos o mas lenguajes definidos. asegurate de tener solo uno cargado verificando que sus valores no sean nulos.

hemos añadido mecanicas adicionales a nuestra entidad ademas de que esta ya funciona exactamente igual a game_text.

**KEYVALUES ADICIONALES**

key "effect" fue ampliada y los efectos adicionales no requieren especificaciones de otras keyvalues tales como color, posicion etc.

value | descripción
------|------------
3 | usa el mismo efecto color y tiempo que BaseTriggers con su keyvalue "message"
4 | Muestra una pagina de MOTD
5 | Muestra un mensaje en el chat
6 | Muestra un subtitulo [Trabajo en progreso]
7 | Muestra una tecla bindeada en pantalla

"target" ahora soporta la misma mecanica que multi_manager para enviar tipos de trigger (ON/OFF/KILL)

Para dar uso se debe especificar el monto al final del valor.

Ejemplo: **"target" "TriggerThis#1"**
valor | tipo
------|-----
#0 | USE_OFF
#1 | USE_ON
#2 | USE_KILL

"messagesound" y "messagevolume" fueron añadidos como soporte de env_message y funcionan igual.

al asignarle un brush-model existente a game_text_custom este usara la entidad con el modelo especificado como Touch() y se disparará el texto. en caso de ser un trigger_multiple game_text_custom será renombrado como el target del multiple. si el multiple no tiene target entonces será el caso contrario.

el netname de !activator será guardado en la keyvalue "netname" de game_text_custom y puede utilizarse en cualquier key de mensaje como "!activator" 

Ejemplo: **"message" "El jugador !activator ha activado la bomba"**

"frags" se utiliza para almacenar numeros principalmente, aunque puedes almacenar strings tambien, la idea es utilizarlo en conjunto con trigger_copyvalue/changevalue y a su vez activar game_text_custom luego de la acción.

Ejemplo: **"frags" "25"** -> **"message" "quedan !frags segundos para terminar"** -> "quedan 25 segundos para terminar"

De esta forma puedes facilmente hacer un contador y modificarlo globalmente para todos los lenguajes.