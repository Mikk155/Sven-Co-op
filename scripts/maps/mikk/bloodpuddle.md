[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Simple script that creates a blood puddle when a monster die.

![bloodpuddle_01](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_01.jpg)

![bloodpuddle_02](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_02.jpg)

![bloodpuddle_03](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_03.jpg)

![bloodpuddle_04](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_04.jpg)

Script by [Gaftherman](https://github.com/Gaftherman)

Model taken from [Spirinity](https://www.moddb.com/mods/spirinity)

**INSTALL:**

-As a mapscript

```angelscript
#include "mikk/bloodpuddle"

void MapInit()
{
	RegisterBloodPuddle();
}
```

**Directory:**
```
└───📁svencoop
    ├──📁scripts
    │   └──📁maps
    │      └──📁mikk
    │         └── 📄bloodpuddle.as
    └──📁models  
       └───📁mikk  
           └───📁misc  
               └───📄bloodpuddle.mdl
```

- As a plugin
```angelscript
	"plugin"
	{
		"name" "Blood-Puddle"
		"script" "mikk/bloodpuddle"
	}
```

**Directory:**
```
└──📁svencoop
    ├───📁scripts
    │   ├───📁maps
    │   │   └───📁mikk
    │   │       └───📄bloodpuddle.as
    │   └───📁plugins
    │       └───📁mikk
    │           └───📄bloodpuddle.as
    │
    └──📁models  
       └───📁mikk  
           └───📁misc  
               └───📄bloodpuddle.mdl
```

Download the [model](https://github.com/Mikk155/Sven-Co-op/blob/main/models/mikk/misc/bloodpuddle.mdl)

# SPANISH

Script simple que crea un charco de sangre cuando un npc muere.

![bloodpuddle_01](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_01.jpg)

![bloodpuddle_02](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_02.jpg)

![bloodpuddle_03](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_03.jpg)

![bloodpuddle_04](https://github.com/Mikk155/Sven-Co-op/blob/main/images/bloodpuddle_04.jpg)

Script por [Gaftherman](https://github.com/Gaftherman)

Modelo tomado de [Spirinity](https://www.moddb.com/mods/spirinity)

**INSTALAR:**

- Como script

```angelscript
#include "mikk/bloodpuddle"

void MapInit()
{
	RegisterBloodPuddle();
}
```

**Directorio:**
```
└───📁svencoop
    ├──📁scripts
    │   └──📁maps
    │      └──📁mikk
    │         └── 📄bloodpuddle.as
    └──📁models  
       └───📁mikk  
           └───📁misc  
               └───📄bloodpuddle.mdl
```

- Como plugin

```angelscript
	"plugin"
	{
		"name" "Blood-Puddle"
		"script" "mikk/bloodpuddle"
	}
```

**Directorio:**
```
└──📁svencoop
    ├───📁scripts
    │   ├───📁maps
    │   │   └───📁mikk
    │   │       └───📄bloodpuddle.as
    │   └───📁plugins
    │       └───📁mikk
    │           └───📄bloodpuddle.as
    │
    └──📁models  
       └───📁mikk  
           └───📁misc  
               └───📄bloodpuddle.mdl
```
Download the [model](https://github.com/Mikk155/Sven-Co-op/blob/main/models/mikk/misc/bloodpuddle.mdl)