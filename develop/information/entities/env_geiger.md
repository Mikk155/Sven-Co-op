### env_geiger

![image](../../images/angelscript.png)

env_geiger es una entidad custom que simula el sonido de radiación cuando el jugador se acerca a texturas con nombre ``!toxic``. en cambio, el sonido se escucha cuando el jugador se encuentra cerca de esta entidad.

<details><summary>Instalar</summary>
<p>

- Leer [Instalar](../install_spanish.md)

- Requisitos
	- scripts/maps/mikk/[env_geiger.as](../../../scripts/maps/mikk/env_geiger.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

### Values

| key | value | description |
|-----|-------|-------------|
| master | string | [multisource](multisource-md) |
| sound | string | define un sonido personalizado, utiliza # y un numero para sumar multiples keyvalues, un sonido aleatorio será ejecutado |
| health | float | intervalo minimo de actualización |
| max_health | float | intervalo maximo de actualización |

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON |
|------------|---------|--------|
| Alterna la entidad | Apaga la entidad | enciende la entidad |