# env_blood

env_blood es una entidad que al ser activada, esta genera sangre en su posición, que tambien puede ser usada para crear una [pegatina](decals_english.md) en las apredes pisos y techos.

| Key | Descripción |
|-----|-------------|
| color | Elige el color de la sangr entre rojo o verde |
| amount | Cantidad de sangre, Tamaño de la pegatina y velocidad de la sangre, arriba de 255 ocacciónará que la velocidad ya no aumente, basicamente mayor el valor mayor el daño |
| angles | Dirección en que la sangre será salpicada |

| Bit | Flags | Descripción |
|-----|-------|-------------|
| 1 | Random Direction | Activa, En lugar de usar la direccion de "angles" de la entidad, una dirección aleatoria será utilizada |
| 2 | Blood Stream | en lugar de una salpicadura de sangre, un conjunto de multples particulas volara por los aires, basicamente esto significa mas sangre |
| 4 | On Player | Activa, la sangre será creada en la cabeza de el jugador !activator |
| 8 | Spray Decals | Activa, la sangre va a aparecer en el piso, techo o muro mas cercano |