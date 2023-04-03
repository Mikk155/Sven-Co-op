# Introduccion

Las entidades pueden activarse entre ellas con diferentes configuraciones.

La siguiente es una lista de configuraciones para cuando una entidad es activada.

# Activator

La primera entidad en una cadena de triggers.

- Ejemplo:
	- un jugador activa un [func_button](func_button_spanish.md), el activator seria el jugador.
	
- Activator puede, en la mayoria de casos, ser referido como ``!activator``

# Caller

La entidad anterior en una cadena de triggers.

- Ejemplo:
	- un [func_button](func_button_spanish.md) activa un [multi_manager](multi_manager_spanish.md). el caller de el multi_manager seria el func_button
	
- Caller puede, en algunos casos, ser referido como ``!caller``

# Use-type:

Le dice a la entidad activada que hacer.

Las entidades van a reaccionar respectivamente a su Use-Type.

Si el comportamiento de Use-Type fue explicitamente escrito en el codigo de el juego, que no es el caso de todas las entidades. lo siguiente explica la funcion de cinco Use-Types

- USE_OFF
	- Apaga la entidad

- USE_ON
	- Enciende la entidad

- USE_SET
	- Utilizado por [game_counter](game_counter_spanish.md) y otras pocas entidades

- USE_TOGGLE
	- Alterna

- USE_KILL
	- Elimina la entidad de el mundo

# Prefijos

Hay una posibilidad de activar varias entidades a la vez con un prefijo.

Agrega al final del target el prefijo ``*``

Cualquier entidad que tenga por nombre inicial tu target, va a ser activada.

Ejemplo:
```angelscript
"target" "door_*"
```
Esto va a activar todas las entidades que su nombre comiencen por "door_"

# Nombres especiales

El juego reconoce unos nombres especiales, entidades nombradas de esta forma serán activadas dependiendo los eventos que ocurran.

- !activator y !caller serán el jugador que ocacione estos eventos.

- game_playerkill
	- Un jugador mata a otro jugador
		- !activator y !caller son el jugador asesino

- game_playerdie
	- Un jugador muere
		- !activator y !caller son el jugador muerto

- game_playerjoin
	- Un jugador entra en el servidor
		- !activator y !caller son el jugador nuevo

- game_playerleave
	- Un jugador sale de el servidor
		- !activator y !caller son el jugador que abandono

- game_playerspawn
	- Un jugador resucita mediante un spawnpoint
		- !activator y !caller son el jugador que revivio

# Otras notas

- Las entidades no deben nunca iniciar su nombre con ``0``
