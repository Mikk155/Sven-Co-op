[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

a custom entity that will make survival mode (DISABLED) better.

This will let players join spec mode for some seconds until they get respawned.

**INSTALL:**
- As a mapscript:

Download:

- [survival_manager](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/survival_manager.as)

- [respawndead_keepweapons](https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as)

```angelscript
#include "mikk/entities/survival_manager"

void MapInit()
{
    RegisterSurvivalManager();
}
```
**Directory:**
```
└───📁svencoop
    └──📁scripts
       └──📁maps
          ├──📁mikk
          │  └──📁entities
          │     └── 📄survival_manager.as
          │
          └── 📄respawndead_keepweapons.as
```

- As a plugin:

Download:

- [survival_manager](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/survival_manager.as)

- [respawndead_keepweapons](https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as)

- [SpecOnDead](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/SpecOnDead.as)

```angelscript
	"plugin"
	{
		"name" "SpecOnDead"
		"script" "mikk/SpecOnDead"
	}
```
**Directory:**
```
└───📁svencoop
    ├──📁scripts
    │  └──📁maps
    │     ├──📁mikk
    │     │  └──📁entities
    │     │     └── 📄survival_manager.as
    │     │
    │     └── 📄respawndead_keepweapons.as
    │  
    └──📁scripts
       └──📁plugins
          └──📁mikk
             └── 📄SpecOnDead.as
```

**About the entity**
key | value | Description
----|-------|------------
classname | survival_manager | yeah. didn't a better name x[
targetname | name | fire entity to toggle state
target | target | Fire target when survival mode get disabled
netname | target | Fire target when survival mode get enabled
spawnflags | 1 | Keep inventory. when a player die save their inventory and set it when respawn
spawnflags | 2 | Hide messages when survival toggle its state don't show any message
frags | 25 | time in seconds that survival will wait until get enabled. (-1 disabled always)
health | 5 | time in seconds that players must wait to reswpawn
iuser1 | 0 | players can't drop weapons while survival is disabled (1 = they can)
iuser2 | 0 | the same but aplies for survival enabled.

# SPANISH

Una entidad custom que hace del modo supervivencia (DESACTIVADO) mucho mejor.

Este modo hará que los jugadores entren al modo espectador por algunos segundos antes de re aparecer.

**INSTALAR:**

- Como mapscript:

Descarga:

- [survival_manager](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/survival_manager.as)

- [respawndead_keepweapons](https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as)

```angelscript
#include "mikk/entities/survival_manager"

void MapInit()
{
    RegisterSurvivalManager();
}
```
**Directorio:**
```
└───📁svencoop
    └──📁scripts
       └──📁maps
          ├──📁mikk
          │  └──📁entities
          │     └── 📄survival_manager.as
          │
          └── 📄respawndead_keepweapons.as
```

- Como plugin:

Descarga:

- [survival_manager](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/survival_manager.as)

- [respawndead_keepweapons](https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as)

- [SpecOnDead](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/SpecOnDead.as)

```angelscript
	"plugin"
	{
		"name" "SpecOnDead"
		"script" "mikk/SpecOnDead"
	}
```
**Directorio:**
```
└───📁svencoop
    ├──📁scripts
    │  └──📁maps
    │     ├──📁mikk
    │     │  └──📁entities
    │     │     └── 📄survival_manager.as
    │     │
    │     └── 📄respawndead_keepweapons.as
    │  
    └──📁scripts
       └──📁plugins
          └──📁mikk
             └── 📄SpecOnDead.as
```

**About the entity**
key | value | Description
----|-------|------------
classname | survival_manager | sep. no se me ocurrio un mejor nombre x[
targetname | name | activa la entidad para variar su estado
target | target | Activar cuando el survival se active
netname | target | Activar cuando el survival se desactive
spawnflags | 1 | Mantener inventario. cuando un jugador muere guarda su inventario y equipalo cuando este reaparezca
spawnflags | 2 | Ocultar mensajes cuando el survival varie de estado. no mostrar ningun mensaje.
frags | 25 | Tiempo en segundos que el survival tardará en ser activado. (-1 nunca será activado)
health | 5 | Tiempo en segundos que los jugadores deberán esperar para reaparecer
iuser1 | 0 | Los jugadores no pueden lanzar armas mientras el survival esta desactivado (1 = ellos pueden)
iuser2 | 0 | Lo mismo pero aplica para cuando esta activado.