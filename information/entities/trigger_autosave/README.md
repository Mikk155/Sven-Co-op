**game_save** New alternative to checkpoints, aimed to be similar to trigger_autosave from Half-Life SinglePlayer.

- Once a player joins the server (if a game_zone exist) the player will be respawned in a random (but actived) spawnpoint. even when survival mode is ON. this relies to SteamID so yes. rejoining will not revive you.

- game_save is a SolidBased entity that when a player touch it. his SteamID will be saved and when he die, he will be able to use E-key or MOUSE1 to spawn **once** at where he've touch the entity.

Script Author [Gaftherman](https://github.com/Gaftherman)