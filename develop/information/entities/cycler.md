# cycler

cycler es una entidad utilizada para mostrar modelos en tu mapa.

Poseen una colision solida y pueden recibir balas, este sangrará en blanco y negro.

la entidad cycler como su nombre indica, muestra animaciónes del modelo ciclicamente cada vez que recibe daño.

- Comportamiento de [activación](triggering_system.md)

| USE_TOGGLE | USE_OFF | USE_ON | USE_SET | target !activator | target USE_TYPE |
|------------|---------|--------|---------|------------|--------|
| inicia/pausa animación | pausa animación | inicia animación | inicia/pausa animación |  |  |

- Es mejor utilizar [item_generic](item_generic.md) o [env_sprite](env_sprite.md) para todos estos casos.

# cycler_sprite

Lo mismo que [cycler](#cycler) pero utiliza sprites

# cycler_weapon

Lo mismo que [cycler](#cycler) pero al colisionar con un jugador, esta entidad desaparece.

# cycler_wreckage

cycler_wreckage es una entidad que emite humo y muestra un sprite cuando es activada
 
| Key | Descripción |
|-----|-------------|
| framerate | frames por segundo del sprite en Hertz |
| scale | escala del sprite en pocicion 7- y -x |

| Bit | Flag | Descripción |
|-----|------|-------------|
| 32 | Toggle | Hace que la entidad sea alternada cuando sea activada, en lugar de mostrar solo un efecto de humo cada vez que es activada |
| 64 | Start On | si se utiliza en conjunto con 32 Toggle, esta entidad estará consecutivamente emitiendo humo desde el inicio del mapa |

- Notas
	- Los sprites son apenas visibles debajo del humo emitido