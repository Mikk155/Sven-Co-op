### env_beam

env_beam is an entity used to create a line between two entities.

### Keyvalues

| Key | Descripción |
|-----|-------------|
| LightningStart | Entity where the trace stars 
| LightningEnd | Entity where the trace ends
| [Render Settings](render_settings_english.md) | All visible entities in the game support this render system
| Radius | Maximum distance from the LightningStart entity or the env_beam, depending on how you set it up, to the destination of a random strike
| life | Time, In seconds, where the trace will be visible after being activated, value 0 will make it permanent.
| BoltWidth | With of the sprite, in inches 0.25 (is only visual, the damage vector will still be 1 pixel wide)
| NoiseAmplitude | Amount of noise distortion applied to the beam in the scale from 0 (none) to 255(a lot)
| texture | Name of the sprite
| TextureScroll | Scrolling speed of the sprite from LightningStart to LightningEnd 0 (slow) to 100 (fast)
| framerate | Frecuency on wich the sprite's texture update each 10 seconds
| framestart | Frame number where the sprite animation starts
| StrikeTime | Time, In seconds, where the entity waits after the previous trace ends before striking again
| damage | Damage, Per second, que el trazo hará a quien lo toque.

### Spawnflags

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Start on | Active, The entity starts on after map load
| 2 | Toggle | Active, env_beam can toggle instear of striking each time it triggers
| 4 | Random strike | Active, in conjuction with flag 2, makes it soo the time after each strike becomes a random number between 0 and StrikeTime
| 8 | Ring | Active, Creates a circle between two entities, these entities must be brush entities with an origin point
| 16 | Start sparks | Active, Spawn sparks in the start point 
| 32 | End sparks | Active, Spawn sparks in the end point
| 64 | Decal end | Active, leaves a [decal](decals_english.md) if the beam hits a surface
| 128 | Shade start | Active, fades the beam near the start
| 256 | Shade end | Active, fades the beam near the end

### Notes 

- IF LightningStart and LightningEnd are not specified, env_beam creats beams randomly hiting to a nearby a solid surface withing the radious range

- In case of many entities having the same name as LightningStart / LightningEnd, the entity will randomly choose one of each and draw the beam

- You must only use either flag 128 or 256 at the same time, using both will only make one work

- Flag 8 can't use 128 and/or 256

- The key NoiseAmplitude doesn't define the area where damage is applied, that area only depends on LightningStart, LightningEnd and is always 1 pixel wide

- You can use a combination of a wide beam without damage, and a trigger hurt ontop to simulate a wide damage area for the laser

- When you turn off the entity, all of its traces will remain alive until their lifetime is over

- When you reactivate the entity, the next trace is going to be created immediately no matter what

- StrikeTime with a negative value will strike another beam before the last one ends
	- Creating a trace instanly after another will cause infinite traces and eventually generating a crash

- Flag 8 in conjuction with life 0 will not react to a trigger OFF

- Flag 8 active, Damage is stil going to be generated as a straight line between LightningStart and LightningEnd

- Flag 8 in conjuction with life 0 might occasionally disapear by client reasons

- Flag 8 Always applies damage on the moment it is created ???

- Traces with a life time higher than 0 can't use 128 and 256

- Flag 2 desactivated acts like if it was activated, it just cant be deactivated again

- Renderfx has no use

- Behaviur of [activation](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| toggles the beam | turns off the beam | turns on the beam | toggles the beam |  |  |

### Kezaeiv's experience

- Setting low values for beam life will cause a crash (0.1 seems to be the lowest safe value)

- If you wish to use moving targets (func_trains, npcs, etc) as either LightningStart or LightningEnd, the beam must not be permanent since it only updates the location of the targets each time it creates a beam. Soo you have to set up a short timed beam with a low or 0 delay.
	- Since beam lifetime can't be lower than 0.1, the beam updates somewhat slow, the faster the targets move, the more obvious it is