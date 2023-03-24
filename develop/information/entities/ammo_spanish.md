### ammo_

Entidades de munición y armas de Sven Co-op

Todas soportan la base [pickup](pickup_spanish.md)

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Añade item a !activator | | Añade item a !activator | Añade item a !activator | !activación | USE_TOGGLE |

---

### ammo_357

![image](../../images/ammo_357.png)

- Otorga por item: 6

- Capacidad maxima: 36

Armas que utilizan esta munición:
| [weapon_357](weapons_spanish.md#weapon_357) | [weapon_eagle](weapons_spanish.md#weapon_eagle) |
| :---: | :---: |
| ![image](../../images/weapon_357.png) | ![image](../../images/weapon_eagle.png) |

---

### ammo_556

![image](../../images/ammo_556.png)

- Otorga por item: 100

- Capacidad maxima: 600

Armas que utilizan esta munición:
| [weapon_m16](weapons_spanish.md#weapon_m16) | [weapon_m249](weapons_spanish.md#weapon_m249) | [weapon_minigun](weapons_spanish.md#weapon_minigun) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_m16.png) | ![image](../../images/weapon_m249.png) | ![image](../../images/weapon_minigun.png) |

---

### ammo_556clip

![image](../../images/ammo_9mmAR.png)

- Otorga por item: 30

- Capacidad maxima: 600

Armas que utilizan esta munición:
| [weapon_m16](weapons_spanish.md#weapon_m16) | [weapon_m249](weapons_spanish.md#weapon_m249) | [weapon_minigun](weapons_spanish.md#weapon_minigun) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_m16.png) | ![image](../../images/weapon_m249.png) | ![image](../../images/weapon_minigun.png) |

---

### ammo_762

![image](../../images/ammo_762.png)

- Otorga por item: 5

- Capacidad maxima: 15

Armas que utilizan esta munición:
| [weapon_sniperrifle](weapons_spanish.md#weapon_sniperrifle) |
| :---: |
| ![image](../../images/weapon_sniperrifle.png) |

---

### ammo_9mmAR

![image](../../images/ammo_9mmAR.png)

- Otorga por item: 50

- Capacidad maxima: 250

Armas que utilizan esta munición:
| [weapon_uzi](weapons_spanish.md#weapon_uzi) | [weapon_9mmhandgun](weapons_spanish.md#weapon_9mmhandgun) | [weapon_9mmAR](weapons_spanish.md#weapon_9mmAR) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_uzi.png) | ![image](../../images/weapon_9mmhandgun.png) | ![image](../../images/weapon_9mmAR.png) |

---

### ammo_9mmbox

![image](../../images/ammo_9mmbox.png)

- Otorga por item: 200

- Capacidad maxima: 250

Armas que utilizan esta munición:
| [weapon_uzi](weapons_spanish.md#weapon_uzi) | [weapon_9mmhandgun](weapons_spanish.md#weapon_9mmhandgun) | [weapon_9mmAR](weapons_spanish.md#weapon_9mmAR) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_uzi.png) | ![image](../../images/weapon_9mmhandgun.png) | ![image](../../images/weapon_9mmAR.png) |

---

### ammo_9mmclip

![image](../../images/ammo_9mmclip.png)

- Otorga por item: 17

- Capacidad maxima: 250

Armas que utilizan esta munición:
| [weapon_uzi](weapons_spanish.md#weapon_uzi) | [weapon_9mmhandgun](weapons_spanish.md#weapon_9mmhandgun) | [weapon_9mmAR](weapons_spanish.md#weapon_9mmAR) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_uzi.png) | ![image](../../images/weapon_9mmhandgun.png) | ![image](../../images/weapon_9mmAR.png) |

- Para equiparla mediante [CFG](../game/cfg_spanish.md#equipment) se debe utilizar ``ammo_9mm``

---

### ammo_ARgrenades

![image](../../images/ammo_ARgrenades.png)

- Otorga por item: 2

- Capacidad maxima: 10

Armas que utilizan esta munición:
| [weapon_m16](weapons_spanish.md#weapon_m16) |
| :---: |
| ![image](../../images/weapon_m16.png) |

---

### ammo_buckshot

![image](../../images/ammo_buckshot.png)

- Otorga por item: 12

- Capacidad maxima: 126

Armas que utilizan esta munición:
| [weapon_shotgun](weapons_spanish.md#weapon_shotgun) |
| :---: |
| ![image](../../images/weapon_shotgun.png) |

---

### ammo_crossbow

![image](../../images/ammo_crossbow.png)

- Otorga por item: 5

- Capacidad maxima: 50

Armas que utilizan esta munición:
| [weapon_crossbow](weapons_spanish.md#weapon_crossbow) |
| :---: |
| ![image](../../images/weapon_crossbow.png) |

---

### ammo_custom

![image](../../images/angelscript.png)

- Otorga por item: Elegida

- Capacidad maxima: Dependiente

ammo_custom es una entidad hecha en Angelscript que permite elegir cuanta munición darle a el jugador y no siempre la cantidad por defecto del juego que los items otorgan.

<details><summary>Instalar</summary>
<p>

Requiere:
- [ammo_custom](../../../scripts/maps/mikk/ammo_custom.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_spanish.md)

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

### Values

| key | value | description |
|-----|-------|-------------|
| model | string | define un modelo |
| p_sound | string | define un sonido personalizado para cuando el item es tomado |
| am_name | [choices](#am_name) | define el tipo de munición que este item dará |
| am_give | integer | cantidad de munición que este item dará |
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

---

### ammo_gaussclip

![image](../../images/ammo_gaussclip.png)

- Otorga por item: 20

- Capacidad maxima: 100

Armas que utilizan esta munición:
| [weapon_egon](weapons_spanish.md#weapon_egon) | [weapon_gauss](weapons_spanish.md#weapon_gauss) | [weapon_displacer](weapons_spanish.md#weapon_displacer) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_egon.png) | ![image](../../images/weapon_gauss.png) | ![image](../../images/weapon_displacer.png) |

---

### ammo_rpgclip

![image](../../images/ammo_rpgclip.png)

- Otorga por item: 1

- Capacidad maxima: 5

Armas que utilizan esta munición:
| [weapon_rpg](weapons_spanish.md#weapon_rpg) |
| :---: |
| ![image](../../images/weapon_rpg.png) |

---

### ammo_spore

![image](../../images/ammo_spore.png)

- Otorga por item: 1

- Capacidad maxima: 30

Armas que utilizan esta munición:
| [weapon_sporelauncher](weapons_spanish.md#weapon_sporelauncher) |
| :---: |
| ![image](../../images/weapon_sporelauncher.png) |

---

### ammo_sporeclip

![image](../../images/ammo_sporeclip.png)

- Otorga por item: 1

- Capacidad maxima: 30

Armas que utilizan esta munición:
| [weapon_sporelauncher](weapons_spanish.md#weapon_sporelauncher) |
| :---: |
| ![image](../../images/weapon_sporelauncher.png) |

---

### ammo_uziclip

![image](../../images/ammo_uziclip.png)

- Otorga por item: 32

- Capacidad maxima: 250

Armas que utilizan esta munición:
| [weapon_uzi](weapons_spanish.md#weapon_uzi) | [weapon_9mmhandgun](weapons_spanish.md#weapon_9mmhandgun) | [weapon_9mmAR](weapons_spanish.md#weapon_9mmAR) |
| :---: | :---: | :---: |
| ![image](../../images/weapon_uzi.png) | ![image](../../images/weapon_9mmhandgun.png) | ![image](../../images/weapon_9mmAR.png) |