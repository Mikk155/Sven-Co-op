### Installing Content

To install any script from this repository you simply have to include it in your map_script or trigger_script, noramlly my entities and scripts register automatically.

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
