# Introduction

The entities can be activated between them with different configurations.

The following is a list of configurations for when an entity is activated.

# Activator

The first entity in a chain of triggers.

- Example:
	- a player activates a [func_button](func_button.md), the activator is the player.
	
- Activator can, in the mayority of cases, be referred as ``!activator``

# Caller

The previous entity in a chain of triggers.

- Example:
	- a [func_button](func_button.md) activates a [multi_manager](multi_manager.md). the caller for multi_manager would be the func_button
	
- Caller can, in some cases, be referred as ``!caller``

# Use-type:

It says to the activated entity what to do.

The entities will react respectively to their Use-Type.

If the behavior of Use-Type was explicitly writen in the code, wich is not the case for all entities. the next explains the function of 5 Use-Types

- USE_OFF
	- Turn off the entity

- USE_ON
	- turn on the entity

- USE_SET
	- Used for [game_counter](game_counter.md) and other few entities

- USE_TOGGLE
	- Toggles

- USE_KILL
	- Eliminates the entity from the world

# Prefijos

There is the posibility to activate multiple entities at the same time with a prefix.

Add at the end of the target the prefix ``*``

Any entity whose initial name is your target will be activated.

Example:
```angelscript
"target" "door_*"
```
This will activate all the entities that their names start with "door_"

# Special names

The game recognizes some special names, entities named like this will be activated depending on the events that occur.

- !activator and !caller are going to be the player that causes these events.

- game_playerkill
	- A player kills another player
		- !activator and !caller are the killer player

- game_playerdie
	- A player dies
		- !activator and !caller are the dead player

- game_playerjoin
	- A player joins the server
		- !activator and !caller are the new player

- game_playerleave
	- A player exits the server
		- !activator and !caller are the player that left

- game_playerspawn
	- A player respawns by a spawnpoint
		- !activator and !caller are the revived player

# Other notes

- The entities do not have to start their names with ``0``
