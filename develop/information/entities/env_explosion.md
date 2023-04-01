# env_explosion

env_explosion is a entity that when triggered, will generate a explosion and do damage in area.

| Key | Description |
|-----|-------------|
| iMagnitude | Explosion magnitude. Greater values mean bigger explosion size and damage. Note that explosion damage values above 200 are known to cause damage even through walls.

| Bit | Flag | Description |
|-----|------|-------------|
| 1 | No damage | If set, the explosion deals no damage. |
| 2 | Repeatable | If set, the env_explosion entity won't be removed after being triggered, so you can use it again. |
| 4 | No fireball | If set, the explosion shows no fireball. |
| 8 | No smoke | If set, the explosion shows no smoke. |
| 16 | No decal | If set, the explosion causes no decal. |
| 32 | No sparks | If set, the explosion creates no sparks. |