# env_fade

env_fade is an entity that once activated, it shows in the player's screen a fading effect in a RGB color.

| Key | Description |
|-----|-------------|
| duration | Time, In seconds, That the starting/ending fade will affect |
| holdtime | Time, In seconds, That the opaque fading will affect |
| renderamt | Transparency of the fading in the holdtime peak |
| rendercolor | Color, RGB, Of the fading |

| Bit | Flag | Description |
|-----|------|-------------|
| 1 | Fade from | Instead of starting duration fisrt and then holdtime, this inverts the order and starts from holdtime and then duration |
| 2 | Modulate | Instead of showing the color on screen, this will create some sort of really cool filter where the screen will look like the specified color |
| 4 | Activator only | Only shows the effects to !activator, otherwise it is going to show it to all players |


### Issues

- Duration and holdtime have a maximum limit of 18 seconds.

- Any type of USE_TYPE starts the fading again, overlapping the previous active ones.

# env_fade_custom

![image](../../images/angelscript.png)

env_fade_custom is a custom entity that works similarly to env_fade with various different additions.

<details><summary>Install</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- scripts/maps/mikk/[env_fade_custom.as](../../../scripts/maps/mikk/env_fade_custom.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

| Key | Description |
|-----|-------------|
| m_ffadein | Time, In seconds, That the initial fading will affect |
| m_ffadeout | Time, In seconds, That the final fading will affect |
| m_fholdtime | Time, In seconds, That the opaque fading will affect |
| renderamt | Transparency of the fade in the holdtime's highest peak |
| rendercolor | Color, RGB, Of the fade |
| m_iall_players | To who we should assign the effect? See [m_iall_players](#m_iall_players) |
| m_ifaderadius | Distance, In units, that the player have to be, to see this effect, 0 = desactivated |
| target | Target, Will be fired after m_ffadein, m_ffadeout and m_fholdtime ends |

### m_iall_players

| Value | Description |
|-------|-------------|
| 0 | Activator only (Default), Only !activator is going to be affected |
| 1 | All Players, All players are going to be affected |
| 2 | Only players in radius, All players inside the range of m_ifaderadius will be affected |
| 3 | Only players touching, All players that are touching the entity will be affected, can be set by min/maxhullsize or by world model |

| Bit | Flag | Description |
|-----|------|-------------|
| 1 | Reverse Fading | Same as env_fade |
| 2 | Filtering | Same as env_fade |
| 4 | Stay Fade | The effect will stay infinitely until another env_fade/custom overlaps it|


- Behaviour of [activation](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|-------------------|-----------------|
| Start the fade | Suddenly remove the fade | Start the fade | Start the fade, If the previous fade did not finish, this will not affect the current one | !activator | USE_TOGGLE |

- Spawnflag 1 (fade from) changes the use of m_ffadeout making it start solid to visible and then visible to solid to finally end the effect instanly, I could have fixed it soo that it worked the same as if the spawnflag was not active, but i decided to leave it as a mechanic.

### Issues

- Using m_ffadeout, when giving trigger USE_OFF, if it did not reached the m_ffadein and m_fholdtime time, it is possible that m_ffadeout could reach to execute.
