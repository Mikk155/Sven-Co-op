See in [english](#english)

Leer en [español](#spanish)

Script that requires the player that is touching it to press a certain key to trigger something.

Useful if you want to give information but don't actually spam it into their faces. and let them the possibility of re-read it.

Sample that you use one that need player to be inside a specified zone and press +USE so now give to that player a message or something.

Good combination is game_text_custom with MOTD message.

**INSTALL:**
```angelscript
#include "mikk/entities/utils"
#include "mikk/entities/zone_caller"

void MapInit()
{
	RegisterTriggerInButtons();
}
```

**Information:**

- As same as game_text_custom this entity supports multi-language messages as well. all supported by utils.as is included.

- If the message contains ``+`` it will be replaced with the needed key to press. it will show current player's binded key as well.

- key ``netname`` defines the key needed. in the FGD you can see them as a "Choices" keyvalue.

- Player that touch the key is the activator of course.

- The entity is Toggle-able mean by triggering it you can disable/enable it.

- If no key specified it will use **IN_USE** ( ``+use`` E-key )

- Spawnflag 1 ``1<<0`` will make the entity starts off.

- If not brush model asigned should use hullsizes bbox ``vuser1`` / ``vuser2``

# SPANISH

Un script simple que requiere que el jugador este tocando la entidad y presione un boton especificado para activar algo.

Util si quieres dar informacion sin lanzarla en la cara de los jugadores. y dejarles la posibilidad de Re-leer.

Ejemplo si tienes una y un jugador se encuentra dentro de una zona especifica y presiona +USE ahora el jugador vera un mensaje u otro de tu preferencia.

Una buena combinación es game_text_custom con el mensaje estilo MOTD.

**INSTALAR:**
```angelscript
#include "mikk/entities/utils"
#include "mikk/entities/zone_caller"

void MapInit()
{
	RegisterTriggerInButtons();
}
```

**Información**

- Igual a game_text_custom esta entidad soporta multiples lenguajes tambien. todos los que esten incluidos en el soporte de utils.as

- Si un mensaje contiene ``+`` esto será remplazado por la key necesaria a presionar. se mostrará la letra bindeada por el jugador tambien.

- key ``netname`` define la letra necesaria a presionar. en el FGD puedes verlas como una opcion de "Elecciones"

- El jugador que presione la tecla será el activador por supuesto.

- La entidad puede ser activada y desactivada mediante trigger.

- Si no se especifica una tecla entonces será usada **IN_USE** ( ``+use`` letra-E )

- Spawnflag 1 ``1<<0`` hará que la entidad inicie apagada.

- Si no se especifica un modelo de pincel se deberia asignar tamaño bbox ``vuser1`` / ``vuser2``