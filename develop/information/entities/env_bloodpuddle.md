
### env_bloodpuddle

![image](../../images/angelscript.png)

env_bloodpuddle is an automatic script that creates a blood puddle after a npc dies.

<details><summary>Install</summary>
<p>

- Download [map_script](../../../scripts/maps/mikk/env_bloodpuddle.as) Or [plugin](../../../scripts/plugins/env_bloodpuddle.as)
- Download [bloodpuddle](../../../models/mikk/misc/bloodpuddle.mdl)
- Read [install](../install.md)


Additional functions:
```angelscript
const bool& in blRemove = false
```

- If a ``false`` is sent or nothing in absolute, the blood puddles will not disappear when the npc does.

- If a ``true`` is sent, the blood puddles will disapear the moment the npc's corpse disappears.

Example:
```angelscript
void MapInit()
{
    env_bloodpuddle::fade = false;
}
```

Additional functions:
```angelscript
const string& in szModel = "models/mikk/misc/bloodpuddle.mdl"
```

- If not especified, the model ``models/mikk/misc/bloodpuddle.mdl`` is going to be used for the blood puddles.

- If it is used, the blood puddles will use the selected model.

Example:
```angelscript
void MapInit()
{
    env_bloodpuddle::model( 'models/mikk/misc/bloodpuddle.mdl' );
}
```

- Alternatively via trigger_script you can change the model too.
 - 1 First make sure to precatch your model.
 - 2 Put trigger_script in think mode and give trigger or activate spawnflag 1 (start on)
 - 3 In ``m_iszScriptFunctionName`` you have to put ``env_bloodpuddle::model``
 - 4 In the key ``model`` of trigger_script you have to put the route of the model ``i.e models/scmod/blood.mdl``
 
</p>
</details>

- Add a [Custom Key Value](custom_keyvalue.md) in the monster that you don't want to generate a blood puddle. ``$f_bloodpuddle`` with a value of ``1``

- Use a personalized skin for each monster, add a [Custom Key Value](custom_keyvalue.md) in the monster that you want him to generate a different color blood . ``$i_bloodpuddle`` in a value equal to the index. If it is not used, the blood type of the npc will define the color of the model, 0 for red, 1 for others.

- You can create a ``env_bloodpuddle`` via trigger_createentity, squadmaker, monstermaker or entitymaker and it will start expanding as soon as it spawns.

- The entity as it is also supports a custom model.