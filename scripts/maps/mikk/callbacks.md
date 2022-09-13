[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

[callbacks.as](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/callbacks.as) es un script con un monton de utilidades que he decidido combinar en un solo archivo a los que encontré utiles para uso común. todos ellos son accesibles con el uso de [trigger_script](https://sites.google.com/site/svenmanor/entguide/trigger_script). A continuación verás sus funciones y como usar estos scripts.

[Pasar asesino como activador a travez de TriggerTarget](#getkiller)

[Activar y desactivar el modo supervivencia](#survival)

[Implementa modo de sigilo en co-op](#stealth)

[Renderiza progresivamente una entidad](#render-progresive)

[Muestra un contador de tu eleccion en la pantalla](#timer)

# GetKiller

El uso de ``!activator`` es algo escencial a la hora de crear un mapa en un juego MP si quieres lograr efectuar acciones al respectivo jugador.

Sin embargo en Sven Co-op los monsters que hacen Fire a sus acciones a base de TriggerTarget y TriggerCondition no pueden pasar al asesino/atacante como el ``!activator`` entonces aqui entra este script. al atacar/matar o cualquier especificado. podras obtener como ``!activator`` al atacante. pero debes preparar algunas cosas antes.
```angelscript
"classname" "trigger_script"
"netname" "entidad a pasar el atacante como activador"
"targetname" "la victima debe encender el script"
"m_iszScriptFunctionName" "CTriggerScripts::GetKillerTriggerTarget"
"m_iMode" "1"
```
tu monster va a activar el trigger_script. luego el script hará un proceso en el que terminara activando su propio netname con el atacante como ``!activator``
 
```mermaid
graph TD;
    MONSTER-->SCRIPT;
    SCRIPT-->KILLER;
    KILLER-->SCRIPT;
    SCRIPT-->NEWACTIVATOR;
```

# Survival

No existe ningun metodo para deshabilitar/habilitar el modo de supervivencia desde mapping con entidades stock. asi que esta función puede ser utilizada.

Esta función es bastante simple. si el modo de supervivencia esta activado este se desactivará y visceversa
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::ToggleSurvivalMode"
"m_iMode" "1"
```

# Stealth

Te has preguntado alguna vez como seria un mapa de sigilo en un juego MP?

Bastante extraño para ser sincero. pero si aun asi lo quieres intentar nos hemos aseguramos de que puedas implementarlo.
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::Stealth"
"m_iMode" "2"
"target" "monster"
"netname" "targetspot"
"message" "targetrelease"
```

``target`` Define el monster que va a desencadenar los eventos en el momento en que este vea a un jugador.

``netname`` Define una entidad en donde teleportaras a el jugador que fue visto.

``message`` Define una entidad a activar cuando el jugador sea teleportado. el será el ``!activator``

Notas:

-  Ya que no es un teleport en si. es mas bien un cambio de origin. ten en cuenta la posicion del jugador.

# Render progresive

Quieres crear un efecto de desvanecimiento pero eres demasiado perezoso como para crear alrededor de 100 env_renders?

Con esta función puedes cambiar el renderizado (renderamt) progresivamente con un simple trigger.
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::RenderProgressive"
"m_iMode" "2"
"target" "entity to affect"
"renderamt" "value to change progressively"
```
``target`` Define entidad a afectar

``renderamt`` Define valor a establecer progresivamente.

Notas:

- El valor será cambiado en +1/-1 por cada vez. variar el tiempo de pensamiento del script variará el tiempo de renderizado.

- Multiples entidades pueden ser afectadas.

- Su valor renderamt puede ser cambiado durante el juego con changevalue.

# Timer

Si no quieres que un jugador se rushee medio mapa o los demas se pierdan cinematicas puedes hacer un contador facilmente con este script.

Muestra un contador en pantalla. util para crear salas de esperas asi mas jugadores se unen a la partida antes de comenzar el mapa. ejemplo ``El juego comenzará en X segundos.``
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::ShowTimer"
"m_iMode" "2"
"m_flThinkDelta" "1.0"
"health" "tiempo en segundos"
"netname" "Activar tras terminar de contar"
```
Notas: 

- El mensaje soporta multi-lenguaje y estos ya estan definidos internamente en el script.

- No cambiar ``m_flThinkDelta`` ya que si deja de ser 1.0 un segundo ya no será un segundo.

# SPANISH

[callbacks.as](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/callbacks.as) es un script con un monton de utilidades que he decidido combinar en un solo archivo a los que encontré utiles para uso común. todos ellos son accesibles con el uso de [trigger_script](https://sites.google.com/site/svenmanor/entguide/trigger_script). A continuación verás sus funciones y como usar estos scripts.

[Pasar asesino como activador a travez de TriggerTarget](#getkiller-spanish)

[Activar y desactivar el modo supervivencia](#survival-spanish)

[Implementa modo de sigilo en co-op](#stealth-spanish)

[Renderiza progresivamente una entidad](#render-progresive-spanish)

[Muestra un contador de tu eleccion en la pantalla](#timer-spanish)

# GetKiller SPANISH

El uso de ``!activator`` es algo escencial a la hora de crear un mapa en un juego MP si quieres lograr efectuar acciones al respectivo jugador.

Sin embargo en Sven Co-op los monsters que hacen Fire a sus acciones a base de TriggerTarget y TriggerCondition no pueden pasar al asesino/atacante como el ``!activator`` entonces aqui entra este script. al atacar/matar o cualquier especificado. podras obtener como ``!activator`` al atacante. pero debes preparar algunas cosas antes.
```angelscript
"classname" "trigger_script"
"netname" "entidad a pasar el atacante como activador"
"targetname" "la victima debe encender el script"
"m_iszScriptFunctionName" "CTriggerScripts::GetKillerTriggerTarget"
"m_iMode" "1"
```
tu monster va a activar el trigger_script. luego el script hará un proceso en el que terminara activando su propio netname con el atacante como ``!activator``
 
```mermaid
graph TD;
    MONSTER-->SCRIPT;
    SCRIPT-->KILLER;
    KILLER-->SCRIPT;
    SCRIPT-->NEWACTIVATOR;
```

# Survival SPANISH

No existe ningun metodo para deshabilitar/habilitar el modo de supervivencia desde mapping con entidades stock. asi que esta función puede ser utilizada.

Esta función es bastante simple. si el modo de supervivencia esta activado este se desactivará y visceversa
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::ToggleSurvivalMode"
"m_iMode" "1"
```

# Stealth SPANISH

Te has preguntado alguna vez como seria un mapa de sigilo en un juego MP?

Bastante extraño para ser sincero. pero si aun asi lo quieres intentar nos hemos aseguramos de que puedas implementarlo.
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::Stealth"
"m_iMode" "2"
"target" "monster"
"netname" "targetspot"
"message" "targetrelease"
```

``target`` Define el monster que va a desencadenar los eventos en el momento en que este vea a un jugador.

``netname`` Define una entidad en donde teleportaras a el jugador que fue visto.

``message`` Define una entidad a activar cuando el jugador sea teleportado. el será el ``!activator``

Notas:

-  Ya que no es un teleport en si. es mas bien un cambio de origin. ten en cuenta la posicion del jugador.

# Render progresive SPANISH

Quieres crear un efecto de desvanecimiento pero eres demasiado perezoso como para crear alrededor de 100 env_renders?

Con esta función puedes cambiar el renderizado (renderamt) progresivamente con un simple trigger.
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::RenderProgressive"
"m_iMode" "2"
"target" "entity to affect"
"renderamt" "value to change progressively"
```
``target`` Define entidad a afectar

``renderamt`` Define valor a establecer progresivamente.

Notas:

- El valor será cambiado en +1/-1 por cada vez. variar el tiempo de pensamiento del script variará el tiempo de renderizado.

- Multiples entidades pueden ser afectadas.

- Su valor renderamt puede ser cambiado durante el juego con changevalue.

# Timer SPANISH

Si no quieres que un jugador se rushee medio mapa o los demas se pierdan cinematicas puedes hacer un contador facilmente con este script.

Muestra un contador en pantalla. util para crear salas de esperas asi mas jugadores se unen a la partida antes de comenzar el mapa. ejemplo ``El juego comenzará en X segundos.``
```angelscript
"m_iszScriptFunctionName" "CTriggerScripts::ShowTimer"
"m_iMode" "2"
"m_flThinkDelta" "1.0"
"health" "tiempo en segundos"
"netname" "Activar tras terminar de contar"
```
Notas: 

- El mensaje soporta multi-lenguaje y estos ya estan definidos internamente en el script.

- No cambiar ``m_flThinkDelta`` ya que si deja de ser 1.0 un segundo ya no será un segundo.