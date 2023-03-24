
### env_bloodpuddle

![image](../../images/angelscript.png)

env_bloodpuddle es un script automatico que crea un charco de sangre cuando un npc muere

<details><summary>Instalar</summary>
<p>

Requiere:
- env_bloodpuddle [map_script](../../../scripts/maps/mikk/env_bloodpuddle.as) O [plugin](../../../scripts/plugins/env_bloodpuddle.as)
- [bloodpuddle](../../../models/mikk/misc/bloodpuddle.mdl)
- [utils](../../../scripts/maps/mikk/utils.as)

[Descarga con un toque](../batch_english.md)

<details><summary>Batch</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils env_bloodpuddle
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 

set output2=models/mikk/misc/
curl -LJO %Main%%output2%bloodpuddle.mdl
if not exist %output2% (
  mkdir %output2:/=\%
)
move bloodpuddle.mdl %Output2%

set output2=scripts/plugins/
curl -LJO %Main%%output2%env_bloodpuddle.as
if not exist %output2% (
  mkdir %output2:/=\%
)
move env_bloodpuddle.as %Output2%
```

</p>
</details>

<details><summary>Como map_script</summary>
<p>

En tu map_script Agrega:
```angelscript
#include "mikk/env_bloodpuddle"

void MapInit()
{
	env_bloodpuddle::Register();
}
```

</p>
</details>

<details><summary>Como Plugin</summary>
<p>

En tu default_plugins.txt Agrega:
```angelscript
	"plugin"
	{
		"name" "env_bloodpuddle"
		"script" "env_bloodpuddle"
	}
```

</p>
</details>

La función ``Register`` tiene dos metodos adicionales y opcionales.

Primera función:
```angelscript
const bool& in blRemove = false
```

- Si se envia en ``false`` o no se envia en absoluto, los charcos de sangre creados no van a desaparecer cuando el npc lo haga.

- Si se envia en ``true`` los charcos de sangre desaparecerán en el momento en que el cadaver del npc desaparezca.

Ejemplo:
```angelscript
void MapInit()
{
	env_bloodpuddle::Register( true );
}
```

Segunda función:
```angelscript
const string& in szModel = "models/mikk/misc/bloodpuddle.mdl"
```

- Si no se especifica, el modelo ``models/mikk/misc/bloodpuddle.mdl`` será usado para los charcos de sangre.

- Si se utiliza, los charcos de sangre utilizaran tu modelo de elección.

Ejemplo:
```angelscript
void MapInit()
{
	env_bloodpuddle::Register( true, "models/mymodelfolder/blood.mdl" );
}
```

</p>
</details>

- Añade una [Custom Key Value](custom_keyvalue_english.md) en el monster que no quieras que genere un charco de sangre. ``$f_bloodpuddle`` en un valor de ``1``

- Usar skin personalizada por cada monster, Añade una [Custom Key Value](custom_keyvalue_english.md) en el monster que quieras que genere sangre de otro color. ``$i_bloodpuddle`` en un valor ecual a el indice de skin en el modelo. Si no se utiliza, el tipo de sangre del npc definirá el color del modelo, 0 por rojo, 1 por otros.