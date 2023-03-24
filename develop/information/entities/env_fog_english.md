# env_fog

env_fog is an entity that is used to create fog

### Keyvalues

| Key | Descripción |
|-----|-------------|
| rendercolor | fog color |
| iuser2 | Distance, in units, Where fog starts to be visible, must be higher than zero |
| iuser3 | Distance, in units, Where fog looks opaque, must be higher than iuser2 |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Start Off | Fog starts off and must be triggered |

- Behaviur of [activation](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON |
|------------|---------|--------|
| Toggles the fog | Turns off the fog | Turns on the fog |

### Issues

- Fog only works on OpenGL

- Entities with rendermode different from "normal" (including sprites) are not going to be affected by the fog

# env_fog_individual

![image](../../images/angelscript.png)

env_fog_individual is a script and custom entity that expand the entity in the game


<details><summary>Install</summary>
<p>

Requirements:
- [env_fog](../../../scripts/maps/mikk/env_fog.as)
- [utils](../../../scripts/maps/mikk/utils.as)

[Download with a clic](../batch_english.md)

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

In your map_script add:
```angelscript
#include "mikk/env_fog"
```
Or alternatively call the script with a trigger_script:
```angelscript
"m_iszScriptFile" "mikk/env_fog"
```

</p>
</details>

Adds to env_fog a new spawnflag called "Activator Only" wich is bit 2

If the spawnflag is selected, only players who trigger directly the entity being !activators are gonig to be able to see the fog.

- If the spawnflag 1 is not active, players that join the server will call USE_ON in this entity, you will have to deactivate it manually with USE_OFF