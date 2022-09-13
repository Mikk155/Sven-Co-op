[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

A tool that eliminates imported textures in the maps (``-wadinclude``) and thus reduce considerably BSP's file.

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

**NOTE:**
Since BSP has been modified it will differ from older versions but it will also lower considerably it's size.

# SPANISH

Una herramienta que elimina texturas importadas en los mapas (``-wadinclude``) y asi reducir el tamaño del BSP considerablemente.

Necesitará las herramienta [BSPTexR](https://github.com/Litude/BSPTexRM) y [wally](https://gamebanana.com/tools/4774) y Ripent que se encuentra en el SDK de Sven Co-op

Podras extraer las texturas con ripent. crear un wad con wally y finalmente eliminar las texturas importadas con BSPTexR


- 1 Extraer las texturas de tu mapa con ripent
```
ripent -textureexport mapname
```

- 2 Crear una carpeta llamada ``Texturas vanilla``

- 3 Exportar las texturas por defecto (halflife, opfor, etc etc) a png, tga, jpg o cualquier otro formato en la carpeta ``Texturas vanilla``

- 4 Crear una carpeta llamada ``Nuevas texturas``

- 5 Exportar las texturas de tu mapa en la carpeta ``Nuevas texturas``

- 6 Copiar todas las texturas de la carpeta ``Texturas vanilla`` y pegarlas dentro de la carpeta ``Nuevas texturas`` y darle a "Reemplazar todo"

- 7 Ahora debes presionar CONTROL+Z las texturas de la carpeta ``Texturas vanilla`` deberian estar de nuevo en su carpeta dejandote ``Nuevas texturas`` con solo las exclusivas del mapa.

- 8 Crea un nuevo wad con wally y utiliza todas esas texturas nuevas.

- 9 usa la herramienta BSPTexR para eliminar las texturas del mapa
```
bsptexrm mapname
```

- 10 ve a las propiedades de tu mapa e incluye el nuevo .wad en las propiedades "wad" de "worldspawn"

**NOTA:**
Ya que el BSP ha sido modificado este va a diferir de versiones anteriores pero a su vez bajará considerablemente su tamaño.