[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Simple pre-fab that will let you know how many players alive, dead or total are in the server and do your things in base of that.

- 1 Copy+paste the entities bellow or re-create them

- 2 trigger the entity named ``get_players`` will make [trigger_entity_iterator](https://sites.google.com/site/svenmanor/entguide/trigger_entity_iterator) verify for all dead players, alive players and total players connected in the server.

-3 That value will be written into a game_counter ``frags`` key. use [trigger_condition](https://sites.google.com/site/svenmanor/entguide/trigger_condition) to read that value and do your things with that.

targetname | description
-----------|------------
alive_players | how many alive players in the server at the moment of trigger
dead_players | how many dead players in the server at the moment of trigger
all_players | how many players in the server at the moment of trigger

NOTE: you must trigger manually the entity ``get_players`` every time you want to update the value. or you could do trigger_entity_iterator in think mode but is not really recomended if you can just trigger it when you need.

**PREFAB:**
```angelscript
{
"classname" "trigger_entity_iterator"
"origin" "0 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "alive_players_verify"
"classname_filter" "player"
"status_filter" "1"
"delay_between_triggers" "0.0"
"target" "alive_players"
"triggerstate" "1"
"trigger_after_run" "test1"
}
{
"classname" "game_counter"
"origin" "0 100 30"
"targetname" "alive_players"
"health" "32"
"frags" "0"
}
{
"classname" "trigger_changevalue"
"origin" "30 70 0"
"health" "32"
"frags" "0"
"target" "dead_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "dead_players_verify"
"targetname" "dead_players_get"
}
{
"classname" "trigger_entity_iterator"
"origin" "30 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "dead_players_verify"
"classname_filter" "player"
"status_filter" "2"
"delay_between_triggers" "0.0"
"target" "dead_players"
"triggerstate" "1"
"trigger_after_run" "test3"
}
{
"classname" "trigger_changevalue"
"origin" "0 70 0"
"health" "32"
"frags" "0"
"target" "alive_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "alive_players_verify"
"targetname" "alive_players_get"
}
{
"classname" "game_counter"
"origin" "30 100 30"
"targetname" "dead_players"
"health" "32"
"frags" "0"
}
{
"classname" "game_counter"
"origin" "-30 100 30"
"targetname" "all_players"
"health" "32"
"frags" "0"
}
{
"classname" "trigger_entity_iterator"
"origin" "-30 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "all_players_verify"
"classname_filter" "player"
"status_filter" "0"
"delay_between_triggers" "0.0"
"target" "all_players"
"triggerstate" "1"
"trigger_after_run" "test2"
}
{
"classname" "trigger_changevalue"
"origin" "-30 70 0"
"health" "32"
"frags" "0"
"target" "all_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "all_players_verify"
"targetname" "all_players_get"
}
{
"classname" "multi_manager"
"origin" "0 40 0"
"targetname" "get_players"
"alive_players_get" "0"
"dead_players_get" "0"
"all_players_get" "0"
}
```

# SPANISH

Simple pre-fab que te ayudará a saber cuantos jugadores vivos, muertos o en total hay en el servidor y hacer cosas en tu mapa a base de ello.

- 1 Copy+paste a las entidades del final dentro de tu mapa o re crealas manualmente.

- 2 Darle trigger a ``get_players`` hará que [trigger_entity_iterator](https://sites.google.com/site/svenmanor/entguide/trigger_entity_iterator) verifique a todos los jugadores. a todos los jugadores vivos y finalmente a todos los jugadores muertos.

-3 El valor será escrito en un game_counter en el que podrás utilizar [trigger_condition](https://sites.google.com/site/svenmanor/entguide/trigger_condition) para crear tus logicas a base de la cantidad de jugadores en el mapa. deberás leer la keyvalue ``frags`` de cada game_counter. 

nombre | descripción
-------|------------
alive_players | cantidad exacta de jugadores vivos en este momento
dead_players | cantidad exacta de jugadores muertos en este momento
all_players | cantidad exacta de jugadores conectados en el servidor en este momento

NOTA: deberás actualizar manualmente simplemente dando trigger a ``get_players`` cada vez que quieras actualizar el valor. podrias hacer que trigger_entity_iterator este en modo constante pero no es realmente recomendable si puedes simplemente llamarlo cuando lo necesitas.

**PREFAB:**
```angelscript
{
"classname" "trigger_entity_iterator"
"origin" "0 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "alive_players_verify"
"classname_filter" "player"
"status_filter" "1"
"delay_between_triggers" "0.0"
"target" "alive_players"
"triggerstate" "1"
"trigger_after_run" "test1"
}
{
"classname" "game_counter"
"origin" "0 100 30"
"targetname" "alive_players"
"health" "32"
"frags" "0"
}
{
"classname" "trigger_changevalue"
"origin" "30 70 0"
"health" "32"
"frags" "0"
"target" "dead_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "dead_players_verify"
"targetname" "dead_players_get"
}
{
"classname" "trigger_entity_iterator"
"origin" "30 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "dead_players_verify"
"classname_filter" "player"
"status_filter" "2"
"delay_between_triggers" "0.0"
"target" "dead_players"
"triggerstate" "1"
"trigger_after_run" "test3"
}
{
"classname" "trigger_changevalue"
"origin" "0 70 0"
"health" "32"
"frags" "0"
"target" "alive_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "alive_players_verify"
"targetname" "alive_players_get"
}
{
"classname" "game_counter"
"origin" "30 100 30"
"targetname" "dead_players"
"health" "32"
"frags" "0"
}
{
"classname" "game_counter"
"origin" "-30 100 30"
"targetname" "all_players"
"health" "32"
"frags" "0"
}
{
"classname" "trigger_entity_iterator"
"origin" "-30 100 0"
"delay_between_runs" "0.5"
"maximum_runs" "0"
"run_mode" "0"
"targetname" "all_players_verify"
"classname_filter" "player"
"status_filter" "0"
"delay_between_triggers" "0.0"
"target" "all_players"
"triggerstate" "1"
"trigger_after_run" "test2"
}
{
"classname" "trigger_changevalue"
"origin" "-30 70 0"
"health" "32"
"frags" "0"
"target" "all_players"
"m_iszValueName" "frags"
"m_iszValueType" "0"
"m_trigonometricBehaviour" "0"
"m_iszNewValue" "0"
"message" "all_players_verify"
"targetname" "all_players_get"
}
{
"classname" "multi_manager"
"origin" "0 40 0"
"targetname" "get_players"
"alive_players_get" "0"
"dead_players_get" "0"
"all_players_get" "0"
}
```