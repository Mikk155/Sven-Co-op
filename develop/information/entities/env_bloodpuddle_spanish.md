
### env_bloodpuddle

![image](../../images/angelscript.png)

env_bloodpuddle es un script automatico que crea un charco de sangre cuando un npc muere

<details><summary>Instalar</summary>
<p>

- Descargue [map_script](../../../scripts/maps/mikk/env_bloodpuddle.as) O [plugin](../../../scripts/plugins/env_bloodpuddle.as)
- Descargue [bloodpuddle](../../../models/mikk/misc/bloodpuddle.mdl)
- Lease [instalar](../install_spanish.md)


Funciones adicionales:
```angelscript
const bool& in blRemove = false
```

- Si se envia en ``false`` o no se envia en absoluto, los charcos de sangre creados no van a desaparecer cuando el npc lo haga.

- Si se envia en ``true`` los charcos de sangre desaparecerán en el momento en que el cadaver del npc desaparezca.

Ejemplo:
```angelscript
void MapInit()
{
    env_bloodpuddle::fade = false;
}
```

Funciones adicionales:
```angelscript
const string& in szModel = "models/mikk/misc/bloodpuddle.mdl"
```

- Si no se especifica, el modelo ``models/mikk/misc/bloodpuddle.mdl`` será usado para los charcos de sangre.

- Si se utiliza, los charcos de sangre utilizaran tu modelo de elección.

Ejemplo:
```angelscript
void MapInit()
{
    env_bloodpuddle::model( 'models/mikk/misc/bloodpuddle.mdl' );
}
```

- Alternativamente mediante trigger_script puedes cambiar el modelo tambien.
	- 1 Primero asegurate de precachar tu modelo.
	- 2 Pon trigger_script en think mode y dale trigger o activa la spawnflag 1 (start on)
	- 3 en ``m_iszScriptFunctionName`` debes poner ``env_bloodpuddle::model``
	- 4 en la key ``model`` del trigger_script debes poner la ruta de el modelo i.e ``models/scmod/blood.mdl``

</p>
</details>

- Añade una [Custom Key Value](custom_keyvalue_spanish.md) en el monster que no quieras que genere un charco de sangre. ``$f_bloodpuddle`` en un valor de ``1``

- Usar skin personalizada por cada monster, Añade una [Custom Key Value](custom_keyvalue_spanish.md) en el monster que quieras que genere sangre de otro color. ``$i_bloodpuddle`` en un valor ecual a el indice de skin en el modelo. Si no se utiliza, el tipo de sangre del npc definirá el color del modelo, 0 por rojo, 1 por otros.

- Puedes crear un ``env_bloodpuddle`` mediante trigger_createentity, squadmaker, monstermaker o entitymaker y se empezará a expandir apenas la entidad sea creada.

- La entidad de por si tambien soporta modelo personalizado.