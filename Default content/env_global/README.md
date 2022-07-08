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
Documentation by Sparks.