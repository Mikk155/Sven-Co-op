<details><summary>English</summary>
<p>

### ammo_custom

ammo_custom es una entidad hecha en Angelscript que permite elegir cuanta munición darle a el jugador y no siempre la cantidad por defecto del juego que los items otorgan.

<details><summary>Instalar</summary>
<p>

Requiere:
- [ammo_custom](../../../../scripts/maps/mikk/ammo_custom.as)
- [utils](../../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../../batch.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils ammo_custom
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

En tu map_script Agrega:
```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

</p>
</details>

### Valores

Soporta la base de [ammo](ammo.md).

| key | value | description |
|-----|-------|-------------|
| model | string | define un modelo |
| p_sound | string | define un sonido personalizado para cuando el item es tomado |
| am_name | [choices](#am_name) | define el tipo de municion que este item dará |
| am_give | integer | cantidad de municion que este item dará |
| frags | integer | cuantas veces este item puede ser tomado por cada jugador, si es 0 se puede tomar infinitamente, si es 1 todos los jugadores podrán tomarlo una vez cada uno ( El objeto se hace invisible para el jugador que lo haya tomado esa cantidad de veces ) |

### am_name

- buckshot
- 9mm
- ARgrenades
- sporeclip
- rockets
- uranium
- bolts
- 556
- 357
- m40a1
- satchel
- Trip Mine
- Hand Grenade
- snarks

</p>
</details>

<details><summary>Español</summary>
<p>

### ammo_custom

ammo_custom es una entidad hecha en Angelscript que permite elegir cuanta munición darle a el jugador y no siempre la cantidad por defecto del juego que los items otorgan.

<details><summary>Instalar</summary>
<p>

Requiere:
- [ammo_custom](../../../../scripts/maps/mikk/ammo_custom.as)
- [utils](../../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../../batch.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils ammo_custom
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

</p>
</details>

En tu map_script Agrega:
```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

</p>
</details>

### Valores

Soporta la base de [ammo](ammo.md).

| key | value | description |
|-----|-------|-------------|
| model | string | define un modelo |
| p_sound | string | define un sonido personalizado para cuando el item es tomado |
| am_name | [choices](#am_name-es) | define el tipo de municion que este item dará |
| am_give | integer | cantidad de municion que este item dará |
| frags | integer | cuantas veces este item puede ser tomado por cada jugador, si es 0 se puede tomar infinitamente, si es 1 todos los jugadores podrán tomarlo una vez cada uno ( El objeto se hace invisible para el jugador que lo haya tomado esa cantidad de veces ) |

### am_name es

- buckshot
- 9mm
- ARgrenades
- sporeclip
- rockets
- uranium
- bolts
- 556
- 357
- m40a1
- satchel
- Trip Mine
- Hand Grenade
- snarks

</p>
</details>