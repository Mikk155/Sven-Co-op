[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

**trigger_inout** is a custom entity that will Fire its target when a monster/player is inside of it. at same time when this player/monster left the zone it will fire its netname.

**INSTALL:**
```angelscript
#include "mikk/entities/trigger_inout"

void MapInit()
{
	RegisterCBaseInOut("trigger_inout");
}
```

**Enum keys**
key | value | Description
----|-------|------------
target | TriggerThis | Trigger when someone is inside
netname | TriggerThis | Trigger cwhen someone is outside
message | barn | targetname of the monsters that can interact with this entity
maxhullsize | 10 10 10 | [BBOX](https://developer.valvesoftware.com/wiki/Bounding_box)
minhullsize | -10 -10 -10 | [BBOX](https://developer.valvesoftware.com/wiki/Bounding_box)
model | *200 | Use brush-model instead of BBOX
spawnflags | 1 | Start off
spawnflags | 2 | _the entity will self-turn-off when someone get outisde the zone. trigger again to enable
spawnflags | 4 | while its active all players can enter/exit the zone and active their respective target/netname. while its disabled players can enter and fire its target but to fire its netname no one should be inside the zone
spawnflags | 8 | Ignore players
spawnflags | 16 | allow monsters (use message)

trigger_inout has the exactly skill as multi_manager. add to the end of the value in target/netname the TriggerMode type you want to send

**Sample**
```angelscript
"target" "TriggerThis#0"
"netname" "TriggerThis#1"
```
in this case when you get inside. the target will fire with off state. and when you get outisde the netname will fire with on state

# SPANISH

**trigger_inout** es una entidad custom que va a hacer Fire a su target cuando algun jugador/monster se encuentre dentro. a su vez cuando este salga la entidad hará Fire a su netname.

**INSTALAR:**
```angelscript
#include "mikk/entities/trigger_inout"

void MapInit()
{
	RegisterCBaseInOut("trigger_inout");
}
```

**Enum keys**
key | value | Descripción
----|-------|------------
target | TriggerThis | Trigger cuando alguien entre a la zona
netname | TriggerThis | Trigger cuando alguien salga de la zona
message | barn | targetname del/los monsters que pueden interactuar con la entidad
maxhullsize | 10 10 10 | [BBOX](https://developer.valvesoftware.com/wiki/Bounding_box)
minhullsize | -10 -10 -10 | [BBOX](https://developer.valvesoftware.com/wiki/Bounding_box)
model | *200 | Usar brush-model en lugar de BBOX
spawnflags | 1 | inicia apagado
spawnflags | 2 | la entidad se apaga cuando alguien salga de la zona. darle trigger la re activa
spawnflags | 4 | Mientras esta activa todos los jugadores pueden entrar/salir y se activaran tanto target como netname respectivamente. Mientras esta desactivada un jugador puede entrar y activará el target pero para que se active el netmane no debe ver ningun jugador dentro
spawnflags | 8 | Ignorar jugadores
spawnflags | 16 | Permitir monsters (usar message)

trigger_inout tiene una habilidad exactamente igual a multi_manager. agregue al final del valor sobre target/netname el tipo de TriggerMode que quiere enviar

**Ejemplo**
```angelscript
"target" "TriggerThis#0"
"netname" "TriggerThis#1"
```
en este caso cuando se este dentro el target será apagado. y cuando se este fuera será encendido