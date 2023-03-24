# env_explosion

env_explosion es una entidad que al ser activada, genera una exploción y hace daño en area.

| Key | Descripción |
|-----|-------------|
| iMagnitude | Magnitud de la exploción, mayor el valor significa mayor tamaño y daño de la exploción, Nota, valores de exploción mayores a 200 son conocidos por causar daño incluso a travez de paredes |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | No damage | Activa, La exploción no generará ningun daño. |
| 2 | Repeatable | Activa,  La entidad env_explosion no será eliminada luego de ser activada, asi que puedes usarla de nuevo. |
| 4 | No fireball | Activa, La exploción no mostrará bola de fuego. |
| 8 | No smoke | Activa,  La exploción no mostrará humo. |
| 16 | No decal | Activa, La exploción no dejará una pegatina. |
| 32 | No sparks | Activa, La exploción no creará chispas. |