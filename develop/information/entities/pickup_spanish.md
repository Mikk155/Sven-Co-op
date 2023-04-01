### pickup

Base de valores que otras entidades comparten.

| Key | Value | Descripción |
|-----|-------|-------------|
| model | string | Modelo de la entidad relativo a svencoop/ |
| m_flCustomRespawnTime | float | Tiempo que tardará este objeto en reaparecer, si se deja vacio entonces se basa en los cvars mp_item/ammo/weapon_respawndelay, un valor de "-1" hace que este objeto jamas vuelva a reaparecer |
| [movetype](movetype_spanish.md) | float | Tipo de comportamiento de desplazamiento |
| [$i_classic_mode_ignore](config_spanish.md#config_classic_mode) | integer | Tipo de comportamiento dependiente de Classic Mode (Angelscript) |
| [Render Settings](render_settings_spanish.md) | Varios | Todas las entidades visibles de el juego soportan este sistema de renderizado. |

### spawnflags
| flag | bit | descripción |
|------|-----|-------------|
| TOUCH Only | 128 | Activa, este objeto solo puede ser tomado tocandolo |
| USE Only | 256 | Activa, este item solo puede ser tomado presionando la tecla USAR (E) |
| Can Use without line of sight | 512 | Activa, se puede tomar el objeto con la tecla USAR sin necesidad de estar observando el objeto |
| 1024 | Disable Respawn | Activa, este objeto jamas va a reaparecer luego de ser tomado |

Notas:

- Dandole trigger directo, el item es añadido al inventario del activador.

- Usando la spawnflag 128 y la spawnflag 256 al mismo tiempo, el objeto solo puede ser tomado mediante Trigger directo.