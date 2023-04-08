### ondestroyfn

![image](../../images/angelscript.png)

``ondestroyfn`` es una keyvalue que **todas** las entidades soportan. esta función es llamada cuando una entidad es eliminada de el mundo.

```angelscript
"ondestroyfn" "entkilled"
```

CBaseEntity@ es la entidad eliminada en cuestión, ten en cuenta que algunas funciones de esta misma no estarán disponibles para este punto.
```angelscript
void entkilled( CBaseEntity@ pEntity )
```