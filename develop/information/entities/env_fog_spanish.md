# env_fog

env_fog es una entidad usada para crear niebla

### Keyvalues

| Key | Descripción |
|-----|-------------|
| rendercolor | Color de la niebla |
| iuser2 | Distancia, En unidades, En que la niebla inicia a ser visible, Esto tiene que ser mayor a cero |
| iuser3 | Distancia, En unidades, En que la niebla luce opaca, Esto tiene que ser mayor a iuser2 |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Start Off | La niebla inicia desactivada y necesita ser triggereada |

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON |
|------------|---------|--------|
| Alterna la niebla | Apaga la niebla | Enciende la niebla |

### Issues

- La niebla solo funciona con OpenGL

- Entidades con otro rendermode que no sea "normal" (incluye sprites) no se verán afectados por la niebla

# env_fog_individual

![image](../../images/angelscript.png)

env_fog_individual es un script y entidad custom que expanden la entidad de el juego


<details><summary>Instalar</summary>
<p>

Requiere:
- [env_fog](../../../scripts/maps/mikk/env_fog.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_spanish.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils env_fog
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
#include "mikk/env_fog"
```
O alternativamente llama el script mediante un trigger_script:
```angelscript
"m_iszScriptFile" "mikk/env_fog"
```

</p>
</details>

Añade a env_fog una nueva spawnflag llamada "Activator Only" la cual es el bit 2

Si la spawnflag esta seleccionada, solamente jugadores que den trigger directamente a la entidad siendo el !activator van a poder ver la niebla.

- Si la spawnflag 1 no esta activa, jugadores que entren al servidor van a llamar USE_ON en esta entidad, vas a tener que desactivarselas manualmente con USE_OFF