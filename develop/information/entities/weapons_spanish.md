### weapons

Base de valores que todas las armas comparten.

Soportan la base [pickup](pickup_spanish.md).

| Key | Value | Descripción |
|-----|-------|-------------|
| dmg | integer | Daño personalizado independiente de sus cvars en [skill.cfg](../game/skill_spanish.md#player-weapons) |
| wpn_v_model | string | Modelo personalizado para la vista de primera persona |
| wpn_w_model | string | Modelo personalizado para la vista de el objeto en el mundo |
| wpn_p_model | string | Modelo personalizado para la vista de el objeto en las manos de otro jugador |
| soundlist | string | [GSR](../game/gsr_spanish.md) para esta arma |
| CustomSpriteDir | string | directorio personalizado para el archivo de sprite de esta arma. [directorios](../game/directory_spanish.md#sprite-config) |
| IsNotAmmoItem | 0/1 | 0 = se puede volver a recoger para tomar su municion, 1 = solo se puede tomar para recibir el arma |
| exclusivehold | 0/1 | 0 = funcion normal, 1 = al tomar el arma no puedes cambiar a otra arma a no ser que esta sea descartada (+drop) |

| classname | preview |
|-----------| :-----: |
[weapon_357](#weapon_357) | ![image](../../images/weapon_357.png)
[weapon_9mmAR](#weapon_9mmAR) | ![image](../../images/weapon_9mmAR.png)

---

### weapon_357

- CVars
	- weaponmode_357
		- 0 Se puede utilizar zoom con alternative fire.
		- 1 No se puede utilizar zoom con alternative fire.

	- sk_plr_357_bullet
		- Daño de el arma al disparar.

### Capacidad

Cantidad de munición: 6

Capacidad maxima: 36

### Tipo de municion

| [ammo_357](ammo_spanish.md#ammo_357) |
| :---: |
| ![image](../../images/ammo_357.png) |

---

### weapon_9mmAR

### CVars

	- weaponmode_mp5
		- 0 Se puede utilizar zoom con alternative fire.
		- 1 No se puede utilizar zoom con alternative fire.

	- sk_plr_9mmAR_bullet
		- Daño de el arma al disparar.

### Capacidad

Cantidad de munición: 30

Capacidad maxima: 250

### Tipo de municion
| [ammo_9mmAR](ammo_spanish.md#ammo_9mmAR) | [ammo_9mmbox](ammo_spanish.md#ammo_9mmbox) | [ammo_9mmclip](ammo_spanish.md#ammo_9mmclip) | [ammo_uziclip](ammo_spanish.md#ammo_uziclip) |
| :---: | :---: | :---: | :---: |
| ![image](../../images/ammo_9mmAR.png) | ![image](../../images/ammo_9mmbox.png) | ![image](../../images/ammo_9mmclip.png) | ![image](../../images/ammo_uziclip.png) |

- Esta arma tambien tiene por nombre ``weapon_mp5`` pero es recomendable registrarla como ``weapon_9mmAR``

---