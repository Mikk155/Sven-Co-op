Todas las entidades visibles de el juego soportan este sistema de renderizado.

El sistema de renderizado en GoldSource es simple pero trae legacy de Quake que casi nunca es usada.

Se pueden representar hasta 512 entidades visibles al mismo tiempo, anteriormente, 256

A continuación se explican los diferentes modos de renderizado y cómo funcionan.

### rendermode

| valor | Code | descripción detallada |
|-------|------|-----------------------|
| 0 | kRenderNormal | Normal |
| 1 | kRenderTransColor | Utilizando esta opción, la textura de la entidad será reemplazada por el color elegido en [rendercolor](#rendercolor) | 
| 2 | kRenderTransTexture | Utilizando esta opción, la transparencia de la entidad será definida por [renderamt](#renderamt) |
| 3 | kRenderGlow | Utilizando esta opción, la transparencia y tamaño de sprites (Solamente sprites)  se verá afectada dependiendo la distancia, [renderfx](#renderfx) en un valor de 14 (Constant Glow) cancela el efecto de transparencia y tamaño por distancia |
| 4 | kRenderTransAlpha | Utilizando esta opción, las partes transparentes de las texturas se harán invisibles |
| 5 | kRenderTransAdd | Utilizando esta opción, la transparencia de la entidad será definida por [renderamt](#renderamt) y por su color, los colores oscuros serán menos visibles mientras que los claros serán mas visibles |

### renderamt

FX Amount (1 - 255) Opacidad de la entidad si esta tiene un [rendermode](#rendermode) mayor a 0, mayor el numero menor la transparencia.

### rendercolor

FX Color (R G B) Color de la entidad si [rendermode](#rendermode) esta en un valor de 1

### renderfx

- renderfx solo funciona si [rendermode](#rendermode) esta por encima de 0 (normal)

| valor | Code | Descripción |
|-------|------|-------------|
| 0 | kRenderFxNone | Normal |
| 1 | kRenderFxPulseSlow | Slow Pulse, Varia su opacidad lentamente, si renderamt es demasiado alto, este efecto no se notará |
| 2 | kRenderFxPulseFast | Fast Pulse, Ditto, Rapidamente |
| 3 | kRenderFxPulseSlowWide | Slow Wide Pulse, Ditto, Lentamente |
| 4 | kRenderFxPulseFastWide | Fast Wide Pulse, Ditto, Rapidamente |
| 5 | kRenderFxFadeSlow | Slow Fade Away, No parece tener efecto alguno, pero como su nombre indica, deberia lentanmente hacerse transparente |
| 6 | kRenderFxFadeFast | Fast Fade Away, Ditto, Rapidamente|
| 7 | kRenderFxSolidSlow | Slow Become Solid, Varia su opacidad lentamente hacia solido |
| 8 | kRenderFxSolidFast | Fast Become Solid, Ditto, Rapidamente|
| 9 | kRenderFxStrobeSlow |  Slow Strobe, Parpadea lentamente entre invisible y renderamt |
| 10 | kRenderFxStrobeFast | Fast Strobe, Ditto, Rapidamente |
| 11 | kRenderFxStrobeFaster | Faster Strobe, Ditto, Aun mas rapidamente |
| 12 | kRenderFxFlickerSlow | Slow Flicker, Parpadea lentamente, Parece ser afectado por los FPS |
| 13 | kRenderFxFlickerFast | Fast Flicker, Ditto, Rapidamente |
| 14 | kRenderFxNoDissipation | Constant Glow, evite que [rendermode](#rendermode) en un valor de 3 (glow) sea afectado por la distancia |
| 15 | kRenderFxDistort | Distort, Parpadea continuamente |
| 16 | kRenderFxHologram | Hologram (Distort + fade), crea un holograma, efecto utilizado en los mapas de entrenamiento de Half-Life |
| 17 | kRenderFxDeadPlayer | Sin efecto alguno |
| 18 | kRenderFxExplode | Explode (Garg Like), Hace el efecto de deformacion de Gargantua (justo cuando este muere). no funciona en BSPModels o sprites |
| 19 | kRenderFxGlowShell | Glow Shell, Cubre con un efecto de Quake, [rendercolor](#rendercolor) debe ser usado, no funciona en sprites o BSPModels |
| 20 | kRenderFxClampMinScale | ClampMinScale (Sprites), No parece tener algun efecto en glow |