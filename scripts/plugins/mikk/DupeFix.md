[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

A script that will fix the ammo-duplication exploit while survival mode is disabled and re enable it when it is enabled. does a blip noise when ended and don't show countdown messages while working.

The third things are optional as well.

**INSTALL**

- As [map-script*(https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/DupeFix.as)
```angelscript
#include "mikk/DupeFix"

void MapInit()
{
	CSurvival::AmmoDupeFix( true, true, true );
}
```
- As a [plugin](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/DupeFix.as)
```angelscript
	"plugin"
	{
		"name" "DupeFix"
		"script" "mikk/DupeFix"
	}
```
Change the ``true`` to ``false`` for variate effects.

The first argument defines if show or hide the countdown messages.

The second argument defines if block or not the weapons drop while survival mode is off.

The third argument defines if do a blip noise when survival mode starts.

# SPANISH

Un script simple que arregla el exploit de duplicar municion mientras el modo de supervivencia esta desactivado y luego lo activa cuando este mismo esta activado. hace un sonido y tambien oculta la cuenta regresiva de survival mientras esta esta activa.

Las tres cosas son opcionales.

**INSTALAR**
- Como [map-script*(https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/DupeFix.as)
```angelscript
#include "mikk/DupeFix"

void MapInit()
{
	CSurvival::AmmoDupeFix( true, true, true );
}
```
- Como [plugin](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/plugins/mikk/DupeFix.as)
```angelscript
	"plugin"
	{
		"name" "DupeFix"
		"script" "mikk/DupeFix"
	}
```
Cambia el ``true`` por ``false`` para variar los efectos.

El primer argumento define si mostrar u ocultar los mensajes de cuenta regresiva.

El segundo argumento define si bloquear o no el exploit de duplicación.

El tercer argumento define si hacer o no un sonido cuando el survival este activado.