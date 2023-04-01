# ambient_generic

Esta entidad se utiliza para reproducir sonidos y musica tambien.

| Key | Descripción |
|-----|-------------|
| message | Nombre del archivo de audio a reproducir. soporta formatos listados en [fmod](../game/fmod_spanish.md) |
| health | Volumen de la musica, de 0 (inaudible) a 10 (normal) |
| [playmode](#playmode) | Especifica la forma de reproducir el sonido |
| [preset](#preset) | Permite especificar un preajuste dinámico para mejorar el sonido |
| volstart | volumen de entrada de entre 0.0 y 10.0 para fadein |
| fadein | Tiempo, en segundos, que tardará el sonido en alcanzar su volumen maximo 0-100 |
| fadeout | Tiempo, en segundos, que tardará el sonido en dejar de sonar 0-100 |
| pitch | velocidad del sonido |
| pitchstart | pitch inicial |
| spinup | Tiempo, en segundos, durante el cual se aplicará un efecto de sonido giratorio (apariciones graduales consecutivas) a medida que el sonido comienza a reproducirse. |
| spindown | Tiempo, en segundos, durante el cual se aplicará un efecto de sonido giratorio (depariciones graduales consecutivas) a medida que el sonido termina de reproducirse. |
| [lfotype](#lfotype) | Le permite configurar un oscilador de baja frecuencia para modificar el volumen y/o el tono con el tiempo, a medida que se reproduce el sonido. |
| lforate | Tasa, en Hertz, a la que oscila el LFO. Por lo general, querrá poner valores bajos como 0.3. |
| lfomodpitch |  Establece cuánto afectará el LFO al tono del sonido. |
| lfomodvol | Establece cuánto afectará el LFO al volumen del sonido. |


| Flag | Bit | Descripción |
|------|-----|-------------|
| Play Everywhere | 1 | Se escucha en todo el mapa |
| Small Radius | 2 | 384 unidades |
| Medium Radius | 4 | 768 unidades |
| Large Radius | 8 | 1536 unidades  |
| Start Silent | 16 | El sonido inicia apagado hasta recibir trigger. (Loop) |
| Un-looped/Cyclic | 32 | el sonido será reproducido cuando se active, si se esta actualmente reproduciendo, el sonido parará y se reiniciará |
| User Only (+origin) | 64 | el sonido se reproducirá ADICIONALMENTE en el origin del jugador !activator |

### playmode

| playmode | Descripción |
|----------|-------------|
| 0 = Default | Normal |
| 1 = Play Once | Se ejecuta solo una vez |
| 2 = Loop | Se ejecuta siempre que el sonido termina |
| 5 = Linear / Play Once | Se ejecuta solo una vez, el radio es [linearmin/linearmax](#linearminlinearmax) |
| 6 = Linear / Loop | Se ejecuta siempre que el sonido termina, el radio es [linearmin/linearmax](#linearminlinearmax) |

### preset

| preset | Descripción |
|----------|-------------|
| 0 = None | No utiliza ningun preset y no reemplaza ninguna configuración |
| 1 = Huge Machine | spinup muy largo, comenzando lento y acelerándose. spindown muy largo. |
| 2 = Big Machine | spinup medio, comenzando normal y acelerando. spindown largo. |
| 3 = Machine | spinup rapido, comenzando normal y acelerando. spindown corto. |
| 4 = Slow Fade in | fade in/out lento |
| 5 = Fade in | fade in/out medio |
| 6 = Quick Fade in | fade in/out rapido |
| 7 = Slow Pulse | Velocidad de pulsación lenta. fadeout rápido. |
| 8 = Pulse | Velocidad de pulsación. fadeout. |
| 9 = Quick pulse | Velocidad de pulsación rapida. fadeout rápido. |
| 10 = Slow Oscillator | Oscilación lenta entre velocidad normal y lenta. fadeout rápido. |
| 11 = Oscillator | Oscilación entre velocidad normal y lenta. fadeout rápido. |
| 12 = Quick Oscillator | Oscilación rapida entre velocidad normal y lenta. fadeout rápido. |
| 13 = Grunge pitch | Extremamente lento, fadeout rapido. |
| 14 = Very low pitch | Muy lento, fadeout rapido. |
| 15 = Low pitch | Lento, fadeout rapido. |
| 16 = High pitch | Rapido, fadeout rapido. |
| 17 = Very high pitch | Muy rapido, fadeout rapido. |
| 18 = Screaming pitch | Extremamente rapido, fadeout rapido. |
| 19 = Oscillate spinup/down | Oscilación con spinup lento a rapido, spindown lento. |
| 20 = Pulse spinup/down | Pulso lento, con spinup de lento a rápido. spindown largo. |
| 21 = Random pitch | Ocasionalmente cambia de velocidad, tendiendo hacia velocidades más lentas. fadeout rápido. |
| 22 = Random pitch fast | Ocasionalmente cambia de velocidad, tendiendo hacia velocidades más rapidas. fadeout rápido. |
| 23 = Incremental Spinup | Spinup rapido, Triggers subsiguientes no alternarán, pero aumentarán la velocidad existente, hasta cinco veces. No se puede apagar. |
| 24 = Alien | pulsaciones y velocidades de conmutación inusuales. fadeout rápido. |
| 25 = Bizzare | Oscilación rápida entre rápido y lento/silencioso. fadeout rápido |
| 26 = Planet X | Cambio medio entre velocidades más lentas, similar a "Paso aleatorio". fadeout rápido. |
| 27 = Haunted | Cambio lento entre velocidad normal y lenta. fadeout rápido. |

### linearmin/linearmax

- linearmin
	- Distancia en la que se escuchará el sonido a todo volumen
	
- linearmax
	- Distancia en la que ya no se escuchará el sonido

| linearmin/linearmax | Descripción |
|----------|-------------|
| 0 | 0 units |
| 1 | 256 units |
| 2 | 512 units |
| 3 | 768 units |
| 4 | 1,024 units |
| 5 | 1,280 units |
| 6 | 1,536 units |
| 7 | 1,792 units |
| 8 | 2,048 units |
| 9 | 2,304 units |
| 10 | 2,560 units |
| 11 | 2,816 units |
| 12 | 3,072 units |
| 13 | 3,328 units |
| 14 | 3,584 units |
| 15 | 3,840 units |
| 16 | 4,096 units |

### lfotype

| playmode | Descripción |
|----------|-------------|
| 0 = Off | Normal |
| 1 = Square Wave | Cambia entre un tono bajo y alto |
| 2 = Triangle Wave | Oscila entre un tono bajo y alto |
| 3 = Random | Cambia aleatoriamente los tonos |
| 4 = Saw Tooth Wave | |
| 5 = Sine Wave | |

# ambient_music

Esta entidad se utiliza comunmente para reproducir musica, ya que es controlado por el cliente mediante el cvar ``mp3volume`` y no ``volume``

| Key | Value | Descripción |
|-----|-------|-------------|
| message | string | Nombre del archivo de audio a reproducir. soporta formatos listados en [fmod](../game/fmod_spanish.md) |
| volume | integer | Volumen de la musica, de 0 (inaudible) a 10 (normal) pero el volumen sera mayormente controlado por el jugador mediante ``mp3volume`` |

| Flag | Bit | Descripción |
|------|-----|-------------|
| Start Silent | 1 | La entidad necesita recibir Trigger para comenzar a reproducir la musica |
| Loop | 2 | La musica se reiniciará cuando termine de sonar |
| Activator Only | 4 | Solamente !activator podrá oirla |

- Comportamiento de [activación](triggering_system_spanish.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| Reproduce/Para el sonido | Para el sonido | Reproduce el sonido | Si esta activado lo apaga, si esta desactivado lo enciende |  |  |