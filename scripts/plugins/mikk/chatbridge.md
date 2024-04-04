### Add your TOKEN

- Create a text (.txt) file within scripts/plugins/mikk/chatbridge/
- Rename it to "token"
- Insert in there your bot's Token

---

### install bot dependancy
- Open a cmd and install the packages we're going to use.
    ```
    pip install (package)
    ```

<details> <summary>View packages</summary>

- sys
- json
- discord
- unidecode

</details>

---

Open [chatbridge.json](chatbridge/chatbridge.json) and configure the plugin as you wish.

<details> <summary>View json commentary</summary>

```json
{
    // If true, the json will be loaded every time a map starts.
    // if false it is loaded only once when the plugin is loaded
    "json reload periodically": true,

    // interval of time (in seconds) at wich angelscript will open and read the text file generated by python
    "interval angelscript read": 20,

    // interval of time (in seconds) at wich angelscript will print the received messages on the server's chat
    "interval angelscript print": 2,

    // how many messages to print on the server's chat every "interval angelscript print"
    "angelscript print messages": 2,

    // interval of time (in seconds) at wich angelscript will store messages into the text that python will read
    "interval angelscript to python": 20,

    // interval of time (in seconds) at wich python script will read the data from the text file writted by angelscript
    "interval python read": 20,

    // Channel ID to send bridge messages
    "bridge channel": 1211204941490688030,

    // Prefix used for the discord bot
    "bot prefix": "!",

    // Contains the configuration for bridge messages
    "LOG":
    {
        // Delete user's message on chat bridge channel after they're send to the server
        "delete discord messages": false,

        // Print discord messages on discord when they have suscesfuly readed on the server
        "print discord messages": true,

        // Messages that players sent on the game's chat
        "game chat": true,

        // When a new map starts
        "map start": true,

        // When a player connected to the server
        "client connected": true,

        // When a player re-spawns
        "player spawn": true,

        // When a player disconnects from the server
        "client disconnect": true,

        // When survival mode starts
        "survival mode start": true,

        // When a player revive (METAMOD)
        "player revive": true,

        // When a player is killed
        "player killed": true,

        // after 25 seconds of map start, send how many players are connected if > 0
        "total players connected": true
    },

    // Commands to whitelist
    "commands":
    {
        // Name of the role allowed for using this command
        "role": "Sven Co-op Admin",

        // if false instead of a white list this will be a black list
        "whitelist": false,

        // Define a cvar to appear in this list
        "say": true
    },

    // Contains the configuration for players emotes, key is the player's steamID while value is the emote to show for him
    "emotes":
    {
        "STEAM_0:0:202010794": "<:gatasexo:1016127843928916068>"
    },

    // Contains the configuration for censuring words
    "bad words":
    {
        "nigga": true,
        "niga": true,
        "nigger": true,
        "niger": true,
        "wafn": true
    },

    // language to use, it's the name of a json's key, you can create your own
    "language": "english",

    // Contains the configuration for all the messages
    "english":
    {
    }
}
```

</details>

---

# Bot commands

| command | arguments | description |
|---|---|---|
| exe | anything surrounded by quotes | executes a command on the server |
| clear | none | clears the text files used for chatbridging, like a manual restart |