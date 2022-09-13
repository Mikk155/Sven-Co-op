[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

A custom script that will add new ammunition to the game.

This ammunitions has a special feature.

Every item will equip all players once.

An attempt to play with the same ammo ammout given as HLSP campaigns.

**INSTALL**

- As a [Map-Script](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/gaftherman/misc/ammo_individual.as)
```angelscript
#include "gaftherman/misc/ammo_individual"

void MapInit()
{
	RegisterAmmoIndividual();
}

void MapActivate()
{
	AmmoIndividualRemap();
}
```
- As a [Plugin](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/Gaftherman/ammo_individual.as)
```angelscript
	"plugin"
	{
		"name" "HLSP Individually Ammunition"
		"script" "Gaftherman/ammo_individual"
	}
```
**If you're mapper then you can use this by 2 diferent ways.**
	
- 1 replace the classnames in your maps and do not use AmmoIndividualRemap()
- 2 use AmmoIndividualRemap() and exclude some items by adding custom keyvalue "$i_ignore_item" if needed

# SPANISH

Una entidad custom que agrega nueva municion al juego.

Estas municiones tienen una mecanica especial.

Cada item va a equipar a todos los jugadores una vez.

Un intento para jugar con la misma cantidad de munición que las campañas SP ofrecen.

**INSTALAR**

- Como [Map-Script](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/gaftherman/misc/ammo_individual.as)
```angelscript
#include "gaftherman/misc/ammo_individual"

void MapInit()
{
	RegisterAmmoIndividual();
}

void MapActivate()
{
	AmmoIndividualRemap();
}
```
- Como [Plugin](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/Gaftherman/ammo_individual.as)
```angelscript
	"plugin"
	{
		"name" "HLSP Individually Ammunition"
		"script" "Gaftherman/ammo_individual"
	}
```
**Si eres un mapper puedes usar esto de 2 maneras diferentes**

- 1 Reemplaza los classnames de las municiones en tus mapas y no utilices AmmoIndividualRemap()
- 2 Utiliza AmmoIndividualRemap() y excluye items añadiendoles la custom keyvalue "$i_ignore_item" si es necesario