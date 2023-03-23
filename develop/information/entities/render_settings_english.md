All visible entities in the game support this rendering system.

The rendering system in GoldSource is simple but comes with legacy Quake wich is almost never used.

512 entities can be visibly represented at the same time, previously, only 256.

Next up is the explaining of the different rendering modes and how they work.

### rendermode

| valor | Code | Detailed description |
|-------|------|-----------------------|
| 0 | kRenderNormal | Normal |
| 1 | kRenderTransColor | Using this option, the entity's texture gets replaced by a choosen color in [rendercolor](#rendercolor) | 
| 2 | kRenderTransTexture | Using this option, the entity's transparensy will be defined by [renderamt](#renderamt) |
| 3 | kRenderGlow | Using this option, the transparency and sprite size (only for sprites) will be affected depending on the distance, [renderfx](#renderfx) with a value of 14 (Constant Glow) cancels the transparency and size by distance |
| 4 | kRenderTransAlpha | Using this option, all transparent parts of the texture will be invisible |
| 5 | kRenderTransAdd | Using this option, the entity's transparency will be defined by [renderamt](#renderamt) and by their color, darker colors will be less visible while lighter ones will be more visible |

### renderamt

FX Amount (1 - 255) Opacity of the entity if it has a [rendermode](#rendermode) higher than 0, higher number equals less transparency.

### rendercolor

FX Color (R G B) Color of the entity if [rendermode](#rendermode) has a value of 1

### renderfx

- renderfx only works if [rendermode](#rendermode) is over 0 (normal)

| valor | Code | Description |
|-------|------|-------------|
| 0 | kRenderFxNone | Normal |
| 1 | kRenderFxPulseSlow | Slow Pulse, Slowly varies the opacity, if renderamt is too high, this effect will be less noticable |
| 2 | kRenderFxPulseFast | Fast Pulse, Ditto, Faster |
| 3 | kRenderFxPulseSlowWide | Slow Wide Pulse, Ditto, Slower |
| 4 | kRenderFxPulseFastWide | Fast Wide Pulse, Ditto, Even faster |
| 5 | kRenderFxFadeSlow | Slow Fade Away, Doesn't seem to have any effect, but as the name indicates, it should slowly become transparent |
| 6 | kRenderFxFadeFast | Fast Fade Away, Ditto, Faster|
| 7 | kRenderFxSolidSlow | Slow Become Solid, Varies the opacity slowly towards solid |
| 8 | kRenderFxSolidFast | Fast Become Solid, Ditto, Faster|
| 9 | kRenderFxStrobeSlow |  Slow Strobe, Blinks slowly between invisible and renderamt |
| 10 | kRenderFxStrobeFast | Fast Strobe, Ditto, Faster |
| 11 | kRenderFxStrobeFaster | Faster Strobe, Ditto, Even faster |
| 12 | kRenderFxFlickerSlow | Slow Flicker, Blinks slowly, seems to be affected by FPS |
| 13 | kRenderFxFlickerFast | Fast Flicker, Ditto, Faster |
| 14 | kRenderFxNoDissipation | Constant Glow, avoids [rendermode](#rendermode) having a value of 3 (glow) becomes affected by distance |
| 15 | kRenderFxDistort | Distort, Blinks continuosly |
| 16 | kRenderFxHologram | Hologram (Distort + fade), creates a hologram, effect used in training maps from Half-Life |
| 17 | kRenderFxDeadPlayer | Without any effect |
| 18 | kRenderFxExplode | Explode (Garg Like), Makes the gargantua's deforming effect (when he is about to die). doesn't work in BSPModels or sprites |
| 19 | kRenderFxGlowShell | Glow Shell, Covers an effect from Quake, [rendercolor](#rendercolor) has to be used, doesn't work on sprites or BSPModels |
| 20 | kRenderFxClampMinScale | ClampMinScale (Sprites), Doesn't seem to have any effect in glow |
