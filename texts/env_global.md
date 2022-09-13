[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

**Env_global**

Globals are used to transport information between maps. 

They are stored in server memory and will persist between maps unless changed by env_global or **(listenserver only)** cleared by a survival restart or by changing maps without first setting mp_keep_globalstate 1 .

**(dedicated servers)** the changelevel ConCMD or trigger_changelevel entity use will both preserve globalstates between maps.

Globals can have three states, on, off or kill.

Kill is for func_breakables so that their state is correctly carried between maps.

Globals are set by env_global and are read by only two entities, [trigger_auto](https://sites.google.com/site/svenmanor/entguide/trigger_auto) and [multisource](https://sites.google.com/site/svenmanor/entguide/multisource)

[trigger_auto](https://sites.google.com/site/svenmanor/entguide/trigger_auto) determines what happens at map start and [multisource](https://sites.google.com/site/svenmanor/entguide/multisource) can be used to disable/lock various entities, in this case the global acts as an on/off control for multisource which in turn acts as on/off control for doors, trigger, buttons etc.

Globals are only on (1) or off (0), they can't be used to transfer numerical values or text in the way that [trigger_save](https://sites.google.com/site/svenmanor/entguide/trigger_save) or/and [trigger_load](https://sites.google.com/site/svenmanor/entguide/trigger_load) can.
However because they are read by multisource, using them to control entities between maps is much easier than using trigger_save/load which requires several additional entities in order to make use of the saved data. (It's more flexible though.)

**Example**
1test_global3.bsp lets you set the global via the left, red button (sprite turns on) and clear it via the right, grey button. Walking forward triggers the changelevel to 1test_global4.bsp where the sprite should have the same state as the previous map.

Additionally in 1test_global3 there is a yellow button which uses multisource to test the global state as an "on demand" function. (Note that the multisource is triggered twice per test, the second time to "reset" it for the next test.)

1test_global4 has a green button which restarts the map via trigger_changelevel. This should preserve the global state

1test_global4 has survival mode enabled. **In listenerver** you can see that a survival restart (or console restart or map vote) wipes the global state.
Unless you set mp_keep_globalstate 1 in console before the map changes.

Unfortunately this CVAR isn't whitelisted in trigger_changecvar and so it must be applied by means of map cfg, script or manually for listenserver. Dedicated servers don't have this bug. 

Entities that obey a multisource Master (and can therefore be controlled by global states)
```
info_player_deathmatch
doors
triggers (that include baseclass Trigger)
button_target
buttons
game_counter
game_end
game_player_hurt
game_score
game_text
trigger_counter (use game_counter instead)
trigger_hurt
trigger_monsterjump
```

Author Sparks

**INSTALL:**
```
└── 📁svencoop
    └── 📁maps
        └── 📁maps
            └── 📄1test_global3.bsp
            └── 📄1test_global3_motd.txt
            └── 📄1test_global3.map
            └── 📄1test_global4.bsp
            └── 📄1test_global4_motd.txt
            └── 📄1test_global4.map
```

# SPANISH

**Env_global**

Globals son usados para transportar informacion entre mapas.

Estos son guardados en la memoria del servidor y van a persistir entre los mapas a menos que sea cambiado por otro env_global o **(Solo en listenrserver)** limpiados por un restart de survival o variando de mapas sin usar mp_keep_globalstate 1 antes.

**(dedicated servers)** El cambio de nivel con ConCMD o trigger_changelevel no afectara el estado de los globals.

Globals pueden tener tres estados, on, off, kill.

Kill es para func_breakables entonces su estado es apropiadamente llevado sobre los mapas.

Globals son definidos por un env_global y son leidos por solo dos entidades, [trigger_auto](https://sites.google.com/site/svenmanor/entguide/trigger_auto) y [multisource](https://sites.google.com/site/svenmanor/entguide/multisource)

[trigger_auto](https://sites.google.com/site/svenmanor/entguide/trigger_auto) determina que sucede cuando el mapa inicia y [multisource](https://sites.google.com/site/svenmanor/entguide/multisource) puede ser usado para activar/desactivar otras varias entidades, en este caso el global actua como un control entre encendido/apagado para el multisource que al ser activado actua como encendido/apagado por puertas, triggers, botones etc.

Globals esta solamente en encendido (1) o apagados (0), ellos no pueden ser usados para transferir valores o texto como lo hacen [trigger_save](https://sites.google.com/site/svenmanor/entguide/trigger_save) o/y [trigger_load](https://sites.google.com/site/svenmanor/entguide/trigger_load)
Pero gracias a que este es leido por multisource,usandolos para controlar entidades durante diferentes mapas es mucho mas facil que trigger_load/save los cuales necesitan severas entidades adicionales en orden para hacer uso de la informacion guardada. ( Es mas flexible por supuesto )

**Ejamplo**
1test_global3.bsp te dejara asignar el global por el boton izquierdo, el boton rojo (enciende el sprite) y limpia el estado con el derecho, el boton gris. caminando al frente se activara el cambio de nivel hacia 1test_global4.bsp donde el sprite deberia tener el mismo estado que en el mapa anterior.

Adicionalmente en 1test_global3 hay un boton amarillo que usa multisource para probar el estado de "en demanda". (Nota ese multisource necesita ser activado 2 veces por prueba, la segunda vez para "restaurarlo" para la siguiente prueba)

1test_global4 tiene un boton verde que va a reiniciar el mapa por trigger_changelevel. esto deberia mantener el estado del global

1test_global4 tiene survival mode activado **In listenerver** puedes ver que al reiniciar el mapa (o en consola o votacion) esto rompe el estado de los globals. a no ser que tengas mp_keep_globalstate 1 en consola antes de que se reinicie el mapa cada vez.
Desafortunadamente este CVAR no esta en la whitelist de trigger_changecvar asi que deberá ser aplicado por medio del cfg del mapa o en el script. o manualmente en listenserver. dedicated server no tienen este problma.

Entidades que obedecen master de multisource ( y pueden ser controladas por el estado de un global)
```
info_player_deathmatch
doors
triggers (cualquiera que incluya la BaseClass Trigger)
button_target
buttons
game_counter
game_end
game_player_hurt
game_score
game_text
trigger_counter (usar game_counter en lugar)
trigger_hurt
trigger_monsterjump
```

Author Sparks

**INSTALAR:**
```
└── 📁svencoop
    └── 📁maps
        └── 📁maps
            └── 📄1test_global3.bsp
            └── 📄1test_global3_motd.txt
            └── 📄1test_global3.map
            └── 📄1test_global4.bsp
            └── 📄1test_global4_motd.txt
            └── 📄1test_global4.map
```