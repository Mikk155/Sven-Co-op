# config_classic_mode

![image](../../images/angelscript.png)

config_classic_mode es una entidad hecha en Angelscript que permite reemplazar modelos, armas e items dependiente de si classic mode esta activo o no. el foco de esta entidad es permitir al mapper poder cambiar modelos y armas que el classic mode por defecto del juego no cambia.

<details><summary>Instalar</summary>
<p>

Requiere:
- [config_classic_mode](../../../scripts/maps/mikk/config_classic_mode.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_classic_mode
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
#include "mikk/config_classic_mode"

void MapInit()
{
	config_classic_mode::Register();
}
```

</p>
</details>

Activa la entidad dandole Trigger con el [USE_TYPE](triggering_system_english.md) respectivo.

- USE_OFF
	- Desactiva el classic mode

- USE_ON
	- Activa el classic mode

- USE_TOGGLE
	- Alterna el classic mode


| key | Descripción |
|-----|-------------|
| spawnflags 1 (Restart now) | Activa, el mapa se reinciará para efectuar los cambios. |
| delay | Tiempo antes de disparar todos sus targets |
| target_toggle | target a disparar cuando el classic mode haya sido exitosamente alternado |
| target_failed | target a disparar cuando el classic mode haya recibido USE_OFF pero esta actualmente desactivado o haya recibido USE_ON pero esta actualmente activado |
| target_enabled | target a disparar cuando el classic mode haya sido activado. (Cuando el mapa inicia) |
| target_disabled | target a disparar cuando el classic mode haya sido desactivado (Cuando el mapa inicia) |
| health | Tiempo de pensamiento de la entidad, un valor alto consumirá menos CPU pero los jugadores podrian llegar a ver el modelo HD en classic mode por un instante. el tiempo por defecto es 0.1 frames mas esta keyvalue |

En HAMMER/JACK/BSPGUY abre Smart-Edit y agrega ahi las keyvalues de tu elección.

- La key es el classname de un arma en el mapa que reemplazar.

- El value es el classname de el arma que reemplazará a la actual.

Ejemplo:
```angelscript
"weapon_rpg" "weapon_rpg_classic"
```

De la misma manera se utiliza para cambiar modelos.

- La key es el modelo en el mapa que reemplazar.

- El value es el modelo nuevo que utilizar.

Ejemplo:
```angelscript
"models/hlclassic/scientist.mdl" "models/headcrab.mdl"
```

⚠️ No te olvides que desde que el classic mode esta activo, algunos modelos son reemplazados por el juego y cambiarian. por ejemplo seria ``models/hlclassic/barney.mdl`` y no ``models/barney.mdl``

### Ignore entity

- Usando (en cualquier entidad) una [Custom Key Value](custom_keyvalue_english.md) ``"$i_classic_mode_ignore"`` en un valor de **1** va a prevenir que el arma o modelo sean reemplazados.

⚠️ Usa solo una entidad por mapa

[Mapa de pruebas](../../../maps/1test_config_classic_mode.bsp)

---

# config_map_cvars

![image](../../images/angelscript.png)

config_map_cvars es una entidad hecha en Angelscript alternativa a [trigger_setcvar](trigger_setcvar_english.md) que permite cambiar multiples [Cvars](../game/cfg_english.md) a la vez o incluso leerlos con [trigger_condition](trigger_condition_english.md) y efectuar acciones dependiendo en ello.

<details><summary>Instalar</summary>
<p>

Requiere:
- [config_map_cvars](../../../scripts/maps/mikk/config_map_cvars.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_map_cvars
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
#include "mikk/config_map_cvars"

void MapInit()
{
	config_map_cvars::Register();
}
```

</p>
</details>

Agrega cualquier Cvar (Soportados enlistados en el FGD) y activa la entidad o alternativamente activa la spawnflag 1 para automaticamente activarlos.

Activa la entidad dandole Trigger con el [USE_TYPE](triggering_system_english.md) respectivo.

En HAMMER/JACK/BSPGUY abre Smart-Edit y agrega ahi los cvars de tu elección.

- La key es el cvar a actualizar.

- El value es el valor a actualizar.

Ejemplo:
```angelscript
"mp_allowplayerinfo" "0"
```

- USE_OFF
	- Retorna los cvars originales que fueron cambiados

- USE_ON / USE_TOGGLE
	- Activa los cvars especificados

- spawnflags 1 (Start On)
	- Activa, Los cvars se actualizarán automaticamente apenas empieze el mapa |
- spawnflags 2 (Store Cvars)
	- almacena en la entidad el valor actual de los cvars que esten en ella, los lees con [trigger_condition](trigger_condition_english.md) y efectuas tus acciones dependiendo sus valores |
	- Estos se almacenan en formato de [Custom Key Value](custom_keyvalue_english.md), El formato es ``$s_( nombre del cvar)``

---

# config_map_precache

![image](../../images/angelscript.png)

config_map_precache es una entidad hecha en Angelscript alternativa a [custom_precache](custom_precache_english.md) que permite Hacer precache a modelos, sonidos, sprites, tga, monsters etc.

<details><summary>Instalar</summary>
<p>

Requiere:
- [config_map_precache](../../../scripts/maps/mikk/config_map_precache.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_map_precache
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
#include "mikk/config_map_precache"

void MapInit()
{
	config_map_precache::Register();
}
```

</p>
</details>

En HAMMER/JACK/BSPGUY abre Smart-Edit y agrega ahi las keyvalues de tu elección.

- La key es el metodo para precachar.

- El value es el objeto a precachar.

| key | Descripción | Ejemplo |
|-------|-----------|---------|
| model | Utilizado para precachar modelos y sprites | "model#1" "models/barney.mdl" |
| entity | Utilizado para precachar archivos que utilizan entidades, por ejemplo monsters | "entity#4" "monster_zombie" |
| sound | Utilizado para precachar sonidos dentro de la carpeta "sounds/" ( No especifique esa carpeta, ya estamos en el directorio ) | "sound#0" "ambience/background_sex.wav" |
| generic | Utilizado para precachar cualquier otra cosa, para skyboxs tienes que precachar todos manualmente | "generic#20" "gfx/env/mysky_bk.tga" |

---

# config_survival_mode

![image](../../images/angelscript.png)

config_survival_mode es una entidad hecha en Angelscript que modifica el survival mode y lo hace mejor.

<details><summary>Instalar</summary>
<p>

Requiere:
- [config_survival_mode](../../../scripts/maps/mikk/config_survival_mode.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils config_survival_mode
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
#include "mikk/config_survival_mode"

void MapInit()
{
	config_survival_mode::Register();
}
```

</p>
</details>

Activa la entidad dandole Trigger con el [USE_TYPE](triggering_system_english.md) respectivo.

- USE_OFF
	- Desactiva el survival mode

- USE_ON
	- Activa el survival mode

- USE_TOGGLE
	- Alterna el survival mode

- Si la entidad es activada antes de que alcance su limite en ``mp_survival_startdelay`` entonces su valor es forzado a 0 y el survival mode inicia automaticamente.

| key | description |
|-----|-------------|
| delay | Tiempo, En segundos, que esta entidad tarda en activar todas sus targets |
| target_toggle | Target a activar cuando el survival mode haya sido alternado |
| target_failed | Target a activar cuando el survival mode haya recibido USE_ON pero actualmente esta activo, o haya recibido USE_OFF pero actualmente esta inactivo |
| mp_survival_startdelay | Tiempo, En segundos, Que tarda el survival mode en activarse, si esta vacio se utilizará el cvar mp_survival_startdelay |
| mp_respawndelay | Tiempo, En segundos, que los jugadores deben esperar antes de revivir, si esta vacio se utilizará el cvar mp_respawndelay |
| master | [multisource](multisource_english.md) que bloquea esta entidad de ser activada mediante su mp_survival_startdelay o por trigger directo |

⚠️ Usa solo una entidad por mapa