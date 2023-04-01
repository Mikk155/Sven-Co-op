### Installing Content

Para instalar cualquier script de este repositorio simplemente tienes que incluirlo en tu map_script o trigger_script, mis entidades y scripts normalmente se registran automaticamente.

map_script:
```angelscript
#include "mikk/script"
```
trigger_script:
```angelscript
"m_iszScriptFile" "mikk/script"
```
plugin:
```angelscript
	"plugin"
	{
		"name" "script"
		"script" "script"
	}
```