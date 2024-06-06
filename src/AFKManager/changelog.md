<details><summary>06/06/24</summary><p>

- Now if there's only one player connected and survival mode is enabled we won't move him to afk state until a new player joins the server
- Added json value ``spectate a player``
    - type: ``boolean``
    - true: start spectating a player
    - false: start spectating on origin
- Added a message showing how long a player has been afk

---

</p></details>

<details><summary>29/04/24</summary><p>

<details><summary>Added new json variables</summary><p>

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

---

</p></details>

-  Added admin command ``.afk (time)``
    - To modify ``"max afk time"`` on-the-fly, 0 or -1 to return as default

---

</p></details>