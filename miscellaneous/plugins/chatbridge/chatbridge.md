
- Open [chatbridge.json](chatbridge.json) and configure the plugins as you wish.

| Label | Description |
|---|---|
| [BOT](#bot) | Bot-related configuration |
| [COMMANDS](#commands) | White-listed commands for executing in the server by the discord bridge channel |
| [LOG](#log) | Type of messages to receive |
| [EMOTES](#emotes) | Display emotes next to player names |
| [REPLACE](#replace) | Replace words with another |

### BOT
| Key | Value |
|---|---|
| PREFIX | Prefix for your BOT |
| LANGUAGE | Language of your BOT, this is required to exist in the json data, see labels ENGLISH or SPANISH |
| INTERVAL_READ_SERVER | Interval of time that the BOT will read the server messages |
| INTERVAL_STATUS | Interval of time that the bot will update the server state (Rely on INTERVAL_ANGESCRIPT too ) |
| INTERVAL_ANGESCRIPT | Interval of time that the plugin will open the files for reading and writting, setting to a lower value is unsafe! |
| IP | This is used only for showing in the server status, sadly there's no API to get the IP of the server |
| CHANNEL_BRIDGE | Channel's ID for chatbridge |
| CHANNEL_STATUS | Channel's ID for server status |
| MODERATOR_ROLE | Role name of a moderator that can send CMD to the server by using the prefix followed by the cmd |
| TOKEN | BOT Token |

### COMMANDS
| Key | Value |
|---|---|
| command | by setting a command in "true" it will be added to the white list |

### LOG
| Key | Value |
|---|---|
| SERVER_MAPSTART | Map starts |
| PLAYERS_START | How many players when map starts |
| PLAYER_CONNECT | When a player connects |
| PLAYER_TALK | When a player writtes in chat |
| PLAYER_RESPAWN | When a player re-spawns |
| PLAYER_KILLED | When a player is killed |
| SURVIVAL_START | When survival mode starts |
| BRIDGE_RELOG | Send to discord when a message reaches the server, mostly for knowing When the server sees your messages |
| PLAYER_REVIVED | When a player revives |
| ADMIN_COMMAND | When a moderator sents a CMD |

### EMOTES
| Key | Value |
|---|---|
| Player STEAMID | emote name or ID |

### REPLACE
| Key | Value |
|---|---|
| Server string to replace | New string replaced |