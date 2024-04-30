## Changelog

### 29/04/2024

#### Added new json variables
```json
{
    "reload": false,
    "max afk time": 500,
    "respawn on exit": true,
    "Add afk to names": true,
    "protect admins": true
}
```
| variable | description |
|---|---|
| max afk time | time to "wait" until a player is considered AFK |
| respawn on exit | if the player were alive when he were moved to AFK we'll respawn him when get out of AFK |
| Add afk to names | Adds a (AFK) prefix before their names when they do talk on chat |
| protect admins | Admins are moved to AFK instead of being kicked when a server is full |

#### Added admin command
-  ``.afk (time)``
    - To modify ``"max afk time"`` on-the-fly, 0 or -1 to return as default