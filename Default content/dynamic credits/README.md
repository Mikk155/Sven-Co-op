a simple sistem for getting a "credits" effect, you know, those scrolling down-to-top.

this system i've made consist in 6 different entities. 

[func_breakable](https://sites.google.com/site/svenmanor/entguide/func_breakable) (or any entity that can be hurt)

[trigger_hurt_remote](https://sites.google.com/site/svenmanor/entguide/trigger_hurt)

[trigger_copyvalue](https://sites.google.com/site/svenmanor/entguide/trigger_copyvalue)

[trigger_changevalue](https://sites.google.com/site/svenmanor/entguide/trigger_changevalue)

[trigger_condition](https://sites.google.com/site/svenmanor/entguide/trigger_condition)

[game_text](https://sites.google.com/site/svenmanor/entguide/game_text)

the multi_manager will trigger their targets in order to make the trigger_hurt_remote change the func_breakable's health keyvalue every (0.2) frames. the trigger_hurt_remote's delay value will define how much speed the credits will have. greater value grater speed.

trigger_copyvalue named "valveis_*_Think" will read func_breakable's health and paste it into game_counter's target value (you could use any entity. game_counter actually is only used for set/read a value only) while it preservers the first string "0." 

after that operation, a new trigger_copyvalue will be fired to read the game_counter's target value and paste it into the game_text's "y" value

once the second trigger_copyvalue finish it fires a trigger_changevalue that will return to "0." the value "target" of the game_counter and suscesivelly, this sistem will be looping until func_breakable's health is 110.

then a trigger_condition will read <= Less 110 and will delete the game_text and counter of the func_breakable column.

**NOTES:**

- the map is actually using 8 channels for game_text. make sure a player is not blocking another's player vision. in that case chanel 8 (i think) will flicke.

- make sure place the func_breakables far away from the players unless you want them to hear a glass breaking.