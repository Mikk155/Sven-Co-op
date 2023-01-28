# Sven-Co-op Repository

An assortment of test maps, additional information for SC stuff, Angelscript plugins / map-scripts, new entities and anything related to SC.

[Tutorials](tutorials)

[Plugins](plugins)

[Scripts](scripts)

[Credits](people-who-contributed-in-any-way)

# Tutorials

[env_global](env_global)

[numerical padlock](numerical-padlock)


# Plugins

# Scripts

[ammo_custom](ammo_custom)












# ammo_custom
ammo_custom is an ammo item customizable that gives a specified ammout of bullets that the mapper sets.

**Download**
```angelscript
"scripts/maps/mikk/ammo_custom.as"
"scripts/maps/mikk/utils.as"
```

**install:**
```angelscript
void MapInit()
{
	ammo_custom::Register();
}
```

# env_global
env_global entity is used to transport information between two or more maps. allowing you to do different triggers depending in what state the previus map did set the global state.

map 1test_global3

# numerical padlock

Creates a full customizable code **on-the-fly** for a numerical padlock. this system works using a game_counter and a trigger_random for randomizing the code needed, feel free to make a better randomizing system of 3 digits from number 0 to 9

once you fire the "randomizing button" 3 copyvalue will paste those random numbers into a trigger_condition.

then every numerical plate will add a value of their owns into another entity while the mentioned trigger_condition will check if the numbers was touched in order and if they're correct.

- If someone is using the camera then others players can't interfer

- using the plate bellow "8" will delete all your previus attempts, basically restore.

- next to player spawn there are some entities that they're only for DEBUG purpose. delete them.

map 1test_numpad


# People who contributed in any way

[Gaftherman](https://github.com/Gaftherman)

Sparks

[KEZÆIV](https://www.youtube.com/channel/UCV5W8sCs-5EYsnQG4tAfoqg)

[Giegue](https://github.com/JulianR0)

[Duk0](https://github.com/Duk0)

[Outerbeast](https://github.com/Outerbeast)

[Cubemath](https://github.com/CubeMath)