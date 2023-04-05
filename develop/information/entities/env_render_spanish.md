# env_render

env_render es una entidad que permite modificar el rendering de otras entidades. Ver [Render Settings](render_settings_spanish.md)

- Key ``armorvalue``
	- Asigna en radio, Unidades, que env_render va a buscar a su objetivo, Si esta fuera de este radio entonces no afectaremos su rendering.
	- valor en 0 desactiva esta mecanica.

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | No render-fx | No se modificará renderfx |
| 2 | No render-amt | No se modificará renderamt |
| 4 | No render-mode | No se modificará rendermode |
| 8 | No render-color | No se modificará rendercolor |
| 16 | Auto apply | Aplica automaticamente en radio (armorvalue) el rendering cuando el objetivo se encuentre en rango, de otra manera la entidad necesita ser activada cada vez |

- Usando env_render por defecto, no importa el USE_TYPE que envies, siempre se activará.

# env_render_custom

![image](../../images/angelscript.png)

<details><summary>Install</summary>
<p>

- Read [Install](../install_spanish.md)

- Requirements
	- scripts/maps/mikk/[env_render_custom.as](../../../scripts/maps/mikk/env_render_custom.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

| Key | Descripción |
|-----|-------------|
| $i_angelscript | Explicitamente debes elegir si usar o no las siguientes funciones, 0 = no usar, 1 = usar |
| $s_target | Entidad a activar cuando el rendermode sea aplicado, la entidad cuyo render fue cambiado será el !activator |
| Spawnflags 64 | Explicitamente debes elegir si usar o no las siguientes funciones, Activa = usar |
| $f_gradual | Tiempo, intervalo (float) para cambiar gradualmente el renderamt de la entidad afectada |
| $i_gradual | renderamt, cantidad de valores de renderamt que vamos a modificar por cada intervalo, Se requiere un prefijo, usar (+) para sumar, usar (-) para restar |
| $s_gradual | renderamt, Cantidad maxima a la cual llegar, el renderamt de la entidad afectada se modificará hasta que lleguemos a este valor |

<details><summary>Ejemplo</summary>
<p>

```angelscript
"$f_gradual" "1.0"
"$i_gradual" "-10"
"$s_gradual" "0"
```
En este caso, Cada 1.0 segundo, vamos a bajar el renderamt del objetivo en 10 hasta que este llegue a 0
</p>
</details>

- Utilizando "Render gradually" el target ($s_target) será activado cuando el objetivo alcance el rendermode deseado.

- Comportamiento de [activación](triggering_system_spanish.md)

| USE_OFF | Otros | target USE_TYPE |
|---------|-------|-----------------|
| Asigna render settings original de la entidad | Asigna render settings | USE_TOGGLE |

- Radius y Auto Apply no funcionan mientras se usa las funciones de Angelscript.
