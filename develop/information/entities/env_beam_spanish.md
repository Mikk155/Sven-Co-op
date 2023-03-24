### env_beam

env_beam es una entidad usada para crear una linea entre dos entidades.

### Keyvalues

| Key | Descripción |
|-----|-------------|
| LightningStart | Entidad en donde el trazo iniciará
| LightningEnd | Entidad en donde el trazo finalizará
| [Render Settings](render_settings_spanish.md) | Todas las entidades visibles de el juego soportan este sistema de renderizado
| Radius | Maxima distancia de la entidad LightningStart o el env_beam, dependiendo como lo hayas configurado, a la destinacion de un golpe aleatorio
| life | Tiempo, En segundos, que el trazo será visible luego de ser activado, un valor de 0 lo hace visible por siempre
| BoltWidth | Ancho del sprite, en pulgadas 0.25
| NoiseAmplitude | Cuánto tiembla el rayo en una escala de 0 (nada) a 255 (mucho)
| texture | Nombre del sprite
| TextureScroll | Velocidad de movimiento deste LightningStart hasta LightningEnd 0 (lento) a 100 (rapido)
| framerate | Frecuencia con la que se debe actualizar la textura del trazo en diez segundos
| framestart | Establece el numero del frame del sprite para iniciar la animación
| StrikeTime | Tiempo, En segundos, que la entidad va a estar en espera luego de que un trazo haya terminado
| damage | Daño, Por segundo, que el trazo hará a quien lo toque.

### Spawnflags

| Bit | Flag | Descripción |
|-----|------|-------------|
| 1 | Start on | Activa, La entidad empieza activada cuando el mapa inicia
| 2 | Toggle | Activa, env_beam se puede alternar en lugar de causar un trazo cada vez que es activada
| 4 | Random strike | Activa, En conjunto con la flag 2, hace que el tiempo luego de cada trazo sea un numero aleatorio entre cero y StrikeTime
| 8 | Ring | Activa, Crea un circulo entre dos entidades, estas necesitan ser una entidad de brush con textura origin
| 16 | Start sparks | Activa, Chispas van a ser emitidas en el inicio del trazo 
| 32 | End sparks | Activa, Chispas van a ser emitidas en el final del trazo 
| 64 | Decal end | Activa, un [decal](decals_spanish.md) va a ser creado en donde el trazo golpee una superficie 
| 128 | Shade start | Activa, el trazo sera menos visible en su inicio
| 256 | Shade end | Activa, el trazo sera menos visible en su final

### Notas 

- Si LightningStart y LightningEnd no son expecificados, env_beam va a crear trazos aleatorios golpeando una superficie solida en su radio de rango

- En caso de que muchas entidades tengan el mismo nombre que LightningStart / LightningEnd, una entidad aleatoria será elegida por cada trazo creado

- Debes usar las flags 128 y 256 solo una a la vez, usando ambas va a hacer que solo funcione una

- Flag 8 no puede utilizar flags 128 y/o 256

- La key NoiseAmplitude no define el area en donde el daño será aplicado, el daño en area solo depende de LightningStart, LightningEnd y BoltWidth

- Cuando apagues la entidad, sus trazos seguirán activos hasta que estos hayan terminado su life

- Cuando reactivas la entidad, el siguiente trazo va a ser creado inmediatamente sin importar cuando el ultimo fue creado

- StrikeTime en valor negativo permite lanzar otro trazo antes de que el anterior haya terminado
	- Crear un trazo al instante de que otro es creado va a causar un numero infinito de trazos y eventualmente generar un crash

- Flag 8 en conjunto con life 0 no va a reaccionar a trigger OFF

- Flag 8 activa, el daño solo va a ser aplicado como si el trazo fuese linear, solo aplica entre LightningStart y LightningEnd

- Flag 8 en conjunto con life 0 ocacionalmente va a desaparecer por razones del cliente

- Flag 8 Siempre aplica daño en el momento de creación

- Trazos con life mayor a 0 no pueden utilizar las flags 128 y 256

- Flag 2 desactivada actuan como si estuviese activada, solo que nunca pueden ser desactivados de nuevo

- renderfx no tiene uso alguno

- Comportamiento de [activación](triggering_system_english.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Alterna el trazo | apaga el trazo | Inicia el trazo | Alterna el trazo |  |  |