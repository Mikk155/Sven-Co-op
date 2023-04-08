### function_name

![image](../../images/angelscript.png)

``function_name`` es una keyvalue que [squadmaker](../entities/maker.md#squadmaker) soporta.

```angelscript
"function_name" "entcreated"
```

Esta función es llamada cada vez que squadmaker crea una entidad.

pSquadmaker@ es la entidad squadmaker y pMonster@ es el monster que ha sido creado.
```angelscript
void entcreated( CBaseMonster@ pSquadmaker, CBaseEntity@ pMonster )
```