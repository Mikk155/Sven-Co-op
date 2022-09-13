[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

trigger_once_mp es una entidad nueva creada por [Cubemath](https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/trigger_multiple_mp.as).

Su proposito es demorar a los jugadores que avanzan demasiado rapido dejado a los demas detras. entonces la experiencia de la mayoria estará balanceada y no se tratará de un camina-camina-y-camina sin nada mas que hacer

**Como instalar?**
Incluye la entidad y el archivo de codigo compartido en tu map-script

**Ejemplo:**
```angelscript
#include "mikk/entities/utils"
#include "mikk/entities/trigger_once_mp"

void MapInit()
{
	RegisterAntiRushEntity();
}
```

**Utilidades que hemos agregado a esta entidad:**

Primero que nada. hemos agregado una "zona customizable" para sus preferencias. Visite el archivo y modifique a sus preferencias.

Especifique un porcentaje global de jugadores necesarios para completar la zona. ( Solo afectara a los mapas que no tengan porcentaje especificado en la entidad )

```angelscript
float flPercentagePeople = 0.66;
```

Este script mostrará mensajes en la pantalla HUD a todos los jugadores que se encuentren dentro de la zona. por ejemplo este dirá
```
"ANTI-RUSH: 66% Of players needed to continue. Current: 25%"
```

si el mapa necesita que mates ciertos enemigos primero entonces ese mensaje dirá algo como
```
"ANTI-RUSH: Kill remaining 5 enemies for progress."
```
Etc etc.

Los mensajes estan ligados a nuestro plugin [Multi-Language](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/multi_language.as) el cual te permitirá ver mensajes en el lenguaje especificado por el Cliente.

Ya que estos mensajes estan ligados a las limitaciónes de Sven Co-op el script esta hecho para usar uno de los pocos canales que el juego ofrece. asi que deberas elegir uno que no este siendo usado por plugins u otros que tengas en tu servidor. personalmente elegiria el canal 3 ya que este es usado para mostrar información de npcs en el juego y pocas veces un plugin o mapa utilizan ese canal.
```angelscript
float flChannel = 6;
```

Una de las mejores cosas que hemos agregado es la posibilidad de desactivar y activar el Anti-Rush mientras estas en una partida. Gracias a Sparks por la increible idea de auto-activación y Re-activación.

Nos hemos asegurado de que al volver a activar el Anti-Rush este no deje a los jugadores atascados en un mapa.

**como funciona?**

Bastante simple la verdad. mientras este esta desactivado el script observará por un solo jugador y entonces este auto-activara la zona sin necesidad de matar enemigos o tener cierto porcentaje de jugadores en la zona.

simplemente escribiendo en el chat ``"/antirush"`` y saldrá una votación para activarlo o desactivarlo.

si prefieres deshabilitar esta función de votación simplemente ve a la linea que contiene el siguiente texto y cambia el ``false`` por ``true``
```angelscript
bool DisableVotes = false;
```

Bien explicado arriba. en esta linea podrás modificar el tiempo que dura una votación.
```angelscript
float flVoteTime = 15;
```

Y en esta otra el porcentaje necesario para activar/desactivar el Anti-Rush. aqui hay un pequeño truco. ya que el boton de "Activar" y "Desactivar" siempre estarán en el mismo lugar. el porcentaje para activar siempre será el mismo. mientras que el desactivar será el opuesto restante.

en este ejemplo se necesita 49% para activarlo mientras que 51% para desactivarlo.
```angelscript
float flPercentage = 49;
```

La mejor mecanica que hemos introducido es la posibilidad de añadir soporte de Anti-Rush sin la necesidad de modificar los mapas en ningun sentido.

**Como hacerlo?**

Eso es bastante simple si sabes usar ripent ya que el metodo es exactamente el mismo.

Usando la misma funcion que hemos utilizado en [game_text_custom](https://github.com/Mikk155/Sven-Co-op/wiki/game_text_custom---Spanish) puedes observar como funciona esa wiki y replicarlo para el Anti-Rush.

Los archivos estan en formato ``.txt`` y estan localizados en ``scripts/maps/mikk/antirush/(mapname).txt``

Los he localizado en mi directorio para evitar diferencias del script con versiones antiguas como residual point entonces estas siguen funcionando con un script alterno.

Ahora hablemos de la entidad en si misma.
| Key | Ejemplo de valor | Descripción | Utilidad |
|-----|--------------|-------------|---------|
| targetname | percent_lock_1 | Nombre de tu entidad. | Usar en conjunto con flag 1 y health. no utilizar de lo contrario. |
| target | percent_lock_1_blocker | Entidad a activar cuando todas las condiciones se cumplan. | Esta entidad crea un env_render_individual como intermediario. la forma de utilizarlo es nombrar tus efectos env_beam/item_generic como el target de esta entidad y agregarle al final "_FX" y solo los jugadores dentro de la zona veran la entidad. |
| rendermode | 5 | Rendermode a aplicar a las entidades explicadas arriba. | Util si quieres variar de renderización. |
| renderamt | 255 | Exactamente lo explicado arriba | nota que tus entidades "FX" deberian ser invisibles por defecto |
| killtarget | percent_lock_1_blocker2 | Simplemente elimina una entidad del mundo. | Util si tus logicas incluyen muchos trigger_once_mp y simplemente quieres librarte de algunos en orden. |
| percent | 0.66 | Porcentaje de jugadores que necesitan estar dentro de la zona para activarla (0.01/0.99) | Los mappers estan libres para forzar un porcentaje sin que los administradores de servers modifiquen el porcentaje especificado. no utilizar si realmente no quieres obligarlo. |
| m_flPercentage | 0.66 | Lo mismo. | Solo por legacy. no utilizar mas usa el de arriba en lugar. |
| health | 15 | Cuantas veces esta entidad necesita ser triggereada para comenzar a pensar por jugadores. | utilizar de la misma manera que un game_counter. |
| frags | 15 | Una cuenta regresiva se mostrará en pantalla con el valor especificado. cuando termine la entidad triggereara su target. | Usar si un evento importante esta por ocurrir asi los jugadores estan preparados. nota si el porcentaje es menor al especificado mientras el conteo avanza este simplemente se pausa hasta que el porcentaje se amayor de nuevo. |
| netname | *255 | el brush model de una entidad solida que quieras eliminar del mundo. | puedes buscar por func_door/button y eliminarlas del mundo. luego recrearlas en tu .txt mas informacion al final. |
| model | *255 | esta entidad utilizara un brush-model como zona. | Si estas en tu propio mapa usa tie-to-entity y ya. |
| vuser1| -10 -10 -10 | minimo tamaño de la zona. ver [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) |
| minhullsize | -10 -10 -10 | Ditto. | legacy. | 
| vuser2 | 10 10 10 | maximo tamaño de la zona. ver [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) |
| maxhullsize | 10 10 10 | Ditto. | legacy. |
| spawnflags | 1 | **SF_AR_IS_OFF** La entidad estará completamente apagada hasta ser triggereada. | util para mapas de estilo ir/y/volver. |
| spawnflags | 2 | **SF_AR_NOTEXT** No mostrara mensajes. | Util si simplemente quieres forzar una tarea en lugar de matar enemigos. |
| spawnflags | 4 | **SF_AR_NOSOUN** No hará ningun sonido. | - |
| spawnflags | 8 | **SF_AR_USEVEC** Si no se asigna un modelo. el rango de detección de la zona dependerá de la entidad y no del mundo. |

Sobre "netname" es util para "bloquear" entidades usando multisource. el metodo aqui es simple. elimina una entidad con trigger_once_mp y luego recreala tu mismo en el .txt con la exepción que deberás agregar una keyvalue custom para prevenir que tu entidad sea eliminada tambien. 
```
"$i_ignore" "Cualquier valor"
```

Aun necesitamos añadir una funcion sobre el metodo de eliminación de enemigos sin modificar los mapas. ya tengo algunas ideas pero no serán incluidas pronto. si creas .txt sobre Anti-Rush por favor dejamelo saber para subirlos en la carpeta store de este repositorio.

Agradecimientos especiales a Gaftherman y Sparks por ayudarme con el script y sugerencias.

# SPANISH

trigger_once_mp es una entidad nueva creada por [Cubemath](https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/trigger_multiple_mp.as).

Su proposito es demorar a los jugadores que avanzan demasiado rapido dejado a los demas detras. entonces la experiencia de la mayoria estará balanceada y no se tratará de un camina-camina-y-camina sin nada mas que hacer

**Como instalar?**
Incluye la entidad y el archivo de codigo compartido en tu map-script

**Ejemplo:**
```angelscript
#include "mikk/entities/utils"
#include "mikk/entities/trigger_once_mp"

void MapInit()
{
	RegisterAntiRushEntity();
}
```

**Utilidades que hemos agregado a esta entidad:**

Primero que nada. hemos agregado una "zona customizable" para sus preferencias. Visite el archivo y modifique a sus preferencias.

Especifique un porcentaje global de jugadores necesarios para completar la zona. ( Solo afectara a los mapas que no tengan porcentaje especificado en la entidad )

```angelscript
float flPercentagePeople = 0.66;
```

Este script mostrará mensajes en la pantalla HUD a todos los jugadores que se encuentren dentro de la zona. por ejemplo este dirá
```
"ANTI-RUSH: 66% Of players needed to continue. Current: 25%"
```

si el mapa necesita que mates ciertos enemigos primero entonces ese mensaje dirá algo como
```
"ANTI-RUSH: Kill remaining 5 enemies for progress."
```
Etc etc.

Los mensajes estan ligados a nuestro plugin [Multi-Language](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/multi_language.as) el cual te permitirá ver mensajes en el lenguaje especificado por el Cliente.

Ya que estos mensajes estan ligados a las limitaciónes de Sven Co-op el script esta hecho para usar uno de los pocos canales que el juego ofrece. asi que deberas elegir uno que no este siendo usado por plugins u otros que tengas en tu servidor. personalmente elegiria el canal 3 ya que este es usado para mostrar información de npcs en el juego y pocas veces un plugin o mapa utilizan ese canal.
```angelscript
float flChannel = 6;
```

Una de las mejores cosas que hemos agregado es la posibilidad de desactivar y activar el Anti-Rush mientras estas en una partida. Gracias a Sparks por la increible idea de auto-activación y Re-activación.

Nos hemos asegurado de que al volver a activar el Anti-Rush este no deje a los jugadores atascados en un mapa.

**como funciona?**

Bastante simple la verdad. mientras este esta desactivado el script observará por un solo jugador y entonces este auto-activara la zona sin necesidad de matar enemigos o tener cierto porcentaje de jugadores en la zona.

simplemente escribiendo en el chat ``"/antirush"`` y saldrá una votación para activarlo o desactivarlo.

si prefieres deshabilitar esta función de votación simplemente ve a la linea que contiene el siguiente texto y cambia el ``false`` por ``true``
```angelscript
bool DisableVotes = false;
```

Bien explicado arriba. en esta linea podrás modificar el tiempo que dura una votación.
```angelscript
float flVoteTime = 15;
```

Y en esta otra el porcentaje necesario para activar/desactivar el Anti-Rush. aqui hay un pequeño truco. ya que el boton de "Activar" y "Desactivar" siempre estarán en el mismo lugar. el porcentaje para activar siempre será el mismo. mientras que el desactivar será el opuesto restante.

en este ejemplo se necesita 49% para activarlo mientras que 51% para desactivarlo.
```angelscript
float flPercentage = 49;
```

La mejor mecanica que hemos introducido es la posibilidad de añadir soporte de Anti-Rush sin la necesidad de modificar los mapas en ningun sentido.

**Como hacerlo?**

Eso es bastante simple si sabes usar ripent ya que el metodo es exactamente el mismo.

Usando la misma funcion que hemos utilizado en [game_text_custom](https://github.com/Mikk155/Sven-Co-op/wiki/game_text_custom---Spanish) puedes observar como funciona esa wiki y replicarlo para el Anti-Rush.

Los archivos estan en formato ``.txt`` y estan localizados en ``scripts/maps/mikk/antirush/(mapname).txt``

Los he localizado en mi directorio para evitar diferencias del script con versiones antiguas como residual point entonces estas siguen funcionando con un script alterno.

Ahora hablemos de la entidad en si misma.
| Key | Ejemplo de valor | Descripción | Utilidad |
|-----|--------------|-------------|---------|
| targetname | percent_lock_1 | Nombre de tu entidad. | Usar en conjunto con flag 1 y health. no utilizar de lo contrario. |
| target | percent_lock_1_blocker | Entidad a activar cuando todas las condiciones se cumplan. | Esta entidad crea un env_render_individual como intermediario. la forma de utilizarlo es nombrar tus efectos env_beam/item_generic como el target de esta entidad y agregarle al final "_FX" y solo los jugadores dentro de la zona veran la entidad. |
| rendermode | 5 | Rendermode a aplicar a las entidades explicadas arriba. | Util si quieres variar de renderización. |
| renderamt | 255 | Exactamente lo explicado arriba | nota que tus entidades "FX" deberian ser invisibles por defecto |
| killtarget | percent_lock_1_blocker2 | Simplemente elimina una entidad del mundo. | Util si tus logicas incluyen muchos trigger_once_mp y simplemente quieres librarte de algunos en orden. |
| percent | 0.66 | Porcentaje de jugadores que necesitan estar dentro de la zona para activarla (0.01/0.99) | Los mappers estan libres para forzar un porcentaje sin que los administradores de servers modifiquen el porcentaje especificado. no utilizar si realmente no quieres obligarlo. |
| m_flPercentage | 0.66 | Lo mismo. | Solo por legacy. no utilizar mas usa el de arriba en lugar. |
| health | 15 | Cuantas veces esta entidad necesita ser triggereada para comenzar a pensar por jugadores. | utilizar de la misma manera que un game_counter. |
| frags | 15 | Una cuenta regresiva se mostrará en pantalla con el valor especificado. cuando termine la entidad triggereara su target. | Usar si un evento importante esta por ocurrir asi los jugadores estan preparados. nota si el porcentaje es menor al especificado mientras el conteo avanza este simplemente se pausa hasta que el porcentaje se amayor de nuevo. |
| netname | *255 | el brush model de una entidad solida que quieras eliminar del mundo. | puedes buscar por func_door/button y eliminarlas del mundo. luego recrearlas en tu .txt mas informacion al final. |
| model | *255 | esta entidad utilizara un brush-model como zona. | Si estas en tu propio mapa usa tie-to-entity y ya. |
| vuser1| -10 -10 -10 | minimo tamaño de la zona. ver [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) |
| minhullsize | -10 -10 -10 | Ditto. | legacy. | 
| vuser2 | 10 10 10 | maximo tamaño de la zona. ver [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) |
| maxhullsize | 10 10 10 | Ditto. | legacy. |
| spawnflags | 1 | **SF_AR_IS_OFF** La entidad estará completamente apagada hasta ser triggereada. | util para mapas de estilo ir/y/volver. |
| spawnflags | 2 | **SF_AR_NOTEXT** No mostrara mensajes. | Util si simplemente quieres forzar una tarea en lugar de matar enemigos. |
| spawnflags | 4 | **SF_AR_NOSOUN** No hará ningun sonido. | - |
| spawnflags | 8 | **SF_AR_USEVEC** Si no se asigna un modelo. el rango de detección de la zona dependerá de la entidad y no del mundo. |

Sobre "netname" es util para "bloquear" entidades usando multisource. el metodo aqui es simple. elimina una entidad con trigger_once_mp y luego recreala tu mismo en el .txt con la exepción que deberás agregar una keyvalue custom para prevenir que tu entidad sea eliminada tambien. 
```
"$i_ignore" "Cualquier valor"
```

Aun necesitamos añadir una funcion sobre el metodo de eliminación de enemigos sin modificar los mapas. ya tengo algunas ideas pero no serán incluidas pronto. si creas .txt sobre Anti-Rush por favor dejamelo saber para subirlos en la carpeta store de este repositorio.

Agradecimientos especiales a Gaftherman y Sparks por ayudarme con el script y sugerencias.