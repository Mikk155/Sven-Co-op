# env_fade

env_fade es una entidad que una vez activada, muestra en la pantalla de los jugadores un efecto de desvanecimiento en color RGB.

| Key | Descripción |
|-----|-------------|
| duration | Tiempo, En segundos, Que el desvanecimiento inicial/final tendrá efecto |
| holdtime | Tiempo, En segundos, Que el desvanecimiento opaco tendrá efecto |
| renderamt | Transparencia de el desvanecimiento en su pico de holdtime |
| rendercolor | Color, RGB, De el desvanecimiento |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Fade from | En lugar de iniciar duration primero y holdtime luego, esto lo revierte e inicia holdtime primero y duration luego |
| 2 | Modulate | En lugar de mostrar el color en pantalla, esto creará una especie de filtro realmente cool en el que todo en la pantalla se verá del color especificado |
| 4 | Activator only | Muestra el efecto solo a !activator, de otra forma se muestra en todos los jugadores |


### Issues

- duration y holdtime tienen un limite maximo de 18 segundos.

- Cualquier tipo de USE_TYPE inicia el desvanecimiento nuevamente, sobre poniendose a activos anteriores.

# Angelscript

### env_fade_custom

env_fade_custom es una entidad custom que funciona igual que env_fade con la diferencia de varias adiciones.

<details><summary>Instalar</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- scripts/maps/mikk/[env_fade_custom.as](../../../scripts/maps/mikk/env_fade_custom.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

| Key | Descripción |
|-----|-------------|
| m_ffadein | Tiempo, En segundos, Que el desvanecimiento inicial tendrá efecto |
| m_ffadeout | Tiempo, En segundos, que el desvanecimiento final tendrá efecto |
| m_fholdtime | Tiempo, En segundos, Que el desvanecimiento opaco tendrá efecto |
| renderamt | Transparencia de el desvanecimiento en su pico de holdtime |
| rendercolor | Color, RGB, De el desvanecimiento |
| m_iall_players | a quienes deberiamos asignarle este efecto? Ver [m_iall_players](#m_iall_players) |
| m_ifaderadius | Distancia, En unidades, que el jugador debe encontrarse para poder ver este efecto, 0 = desactivado |
| target | Target, Será disparada una vez m_ffadein, m_ffadeout y m_fholdtime hayan finalizado |

### m_iall_players

| Value | Descripción |
|-------|-------------|
| 0 | Activator only (Default), Solo !activator será afectado |
| 1 | All Players, Todos los jugadores serán afectados |
| 2 | Only players in radius, Todos los jugadores que esten dentro del rango de m_ifaderadius serán afectados|
| 3 | Only players touching, Todos los jugadores que esten dentro de la entidad serán afectados, Puede ser por min/maxhullsize o por modelo del mundo |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Reverse Fading | Igual a env_fade |
| 2 | Filtering | Igual a env_fade |
| 4 | Stay Fade | El efecto se mantendra infinitamente hasta que se sobre escriba con otro env_fade/custom |


- Comportamiento de [activación](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|-------------------|-----------------|
| Inicia desvanecimiento | Remove repentinamente el desvanecimiento | Inicia desvanecimiento | Inicia desvanecimiento, Si el desvanecimiento anterior aun no termino, no tiene efecto sobre el actual | !activator | USE_TOGGLE |

- Spawnflag 1 (fade from) alterna el uso de m_ffadeout haciendo que inicie solido hacia visible y luego de visible a solido para finalmente terminar el efecto instantaneamente, Podria haberlo arreglado para que funcionará igual a si la spawnflag no estuviese activa, mas decidi dejarlo como mecanica.

### Issues

- Utilizando m_ffadeout, al dar trigger USE_OFF, si aun no se alcanzo el tiempo de m_ffadein y m_fholdtime, es posible que m_ffadeout aun se pueda llegar a ejecutar.
