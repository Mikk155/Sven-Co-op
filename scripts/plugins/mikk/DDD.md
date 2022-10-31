
[See in english](#english)

[Leer en español](spanish)

# ENGLISH

Dynamic Difficulty Deluxe o DDD para abreviar es un plugin inspirado en el famoso DynamicDifficulty de Cubemath pero a diferencia de este ultimo. Este plugin NO simplemente modifica los valores de daño y vida de los enemigos. he decidido centrarme en aumentar la dificultad por otros metodos que no sean el artificial "1HP" de siempre. si. tambien se activará pero lo mejor de este plugin es que principalmente esta basado en otros factores que veras a continuación o dirigiendote a la lista de cambios directamente.

Listas:

[Instalacion](#install)

[Diferentes dificultades](#difficulty-changes)

[Traducciones](#localizations)

[Comandos](#commands)

[mecanicas](#features)

# INSTALL

# DIFFICULTY CHANGES

[diff 0-10](diff-0)

[diff 10-20](diff-10)

[diff 10-20](diff-20)

# diff 0

- Dificultad 0 es exactamente vanilla como el servidor que la utiliza. desde este punto los valores de vida de los npcs son multiplicados en 1 por cada porcentaje. por lo cual en 100% los npcs tendran el doble de vida. afecta tanto a aliados como a enemigos. este cambio solo afecta tras cambiar/reiniciar el nivel. para evitar el bug reciente del DD10 donde cambiar la dificultad sobre la marcha ajustaba la vida de los enemigos dandole un valor alto si estos recibieron daño de antemano. los mappers deberan utilizar una custom keyvalue llamada ``$i_ddd_ignore``

- El cvar 'mp_weaponfadedelay' es dividido desde 100 hasta 1. este cvar significa el tiempo que tarda un item en desaparecer (lanzados por entidades/jugadores)

- El cvar 'mp_respawndelay' es multiplicado desde 1 hasta 20. este cvar significa el tiempo que debes esperar para RE-Aparecer.

- Dependiendo la eleccion de los mappers. el plugin creara nuevos enemigos dependiendo la difficultad selecta. hemos creado una entidad que funciona exactamente igual que un monster con todas sus keyvalues y solo si la difficultad actual es mayor a la que la entidad quiere. este monster aparecerá o no en el mapa. mas informacion [entitymaker](#entity-maker)

# diff 10

- A partir de la dificultad 10 los mensajes de "El survival iniciará en X segundos" ya no se mostrarán en pantalla. por lo que ten cuidado al rushear. se escuchará un sonido y se avisara en el chat cuando survival mode este activado.

- A partir de la difficultad 10 se activara una mecanica de teleportar enemigos (aliens) cerca de un jugador random. script por [Rick](https://github.com/RedSprend). El Cooldown es aleatorio de un minimo de 2400 segundos (40 minutos) y un maximo de 12000 segundos (200 minutos) en difficultad 0 mientras que en difficultad 100 el minimo seria 24 segundos y el maximo 120 segundos.

# diff 20
- A partir de la difficultad 20 ya no se podran tirar armas mientras el survival mode aun no esta activado. por lo que ya no podran farmear munición suicidandose.

# diff 50
- A partir de la difficultad 50 ya no se podran tirar armas y/o munición en ningun momento.

# LOCALIZATIONS

# COMMANDS

# FEATURES

# ENTITY MAKER
