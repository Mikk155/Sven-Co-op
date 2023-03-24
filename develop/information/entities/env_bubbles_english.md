# env_bubbles

A brush entity which creates bubbles at random positions inside it.

- The bubbles float up regardless of whether being in water or air.

- The bubbles only are removed when hitting a water surface or solid wall.

- The bubbles sizes and rising-speed will vary slightly randomly.

| Key | Description |
|-----|-------------|
| density | The amount of bubbles to create per interval |
| frequency | How often the amount of bubbles set by 'Density' shall be created per second. Maximum is 20 |
| current | Sets the horizontal movement speed of the bubbles, to simulate them being in a current. The direction is set by the env_bubble's keyvalue 'angles' |
| spawnflag = 1 | Start Off, The env_bubbles entity will start off and will not generate any bubbles until it is activated |