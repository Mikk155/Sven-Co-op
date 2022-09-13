[env_spritehud](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/env_spritehud.as) is a custom entity for showing hud sprites. the description will be kinda of empty since that's what it does. you'll see here some vague explanations of the effects and values. i did take them from the API. if i do test them propertly a better description will be added.

**Enum Keyvalues**
key | value | description
-----|-------|-----------
target | !activator | Let empty target for showing to everyone.
model | mikk/tcis/logo.spr | sprite to show. do not need to specify "sprites/" we're already in that directory.
x | 0.50 | Horizontal position on the screen. <0, 1.0> = left to right. (-1.0, 0) = right to left. -1.0 = centered
y | 0.50 | Vertical position on the screen. <0, 1.0> = top to bottom. (-1.0, 0) = bottom to top. -1.0 = centered
channel | 0 | Channel. Range: 0-15 (each module type has its own channel group).
frame | 0 | show number of frame
top | 0 | Sprite top offset. Range: 0-255
left | 0 | Sprite left offset. Range: 0-255
width | 0 | Sprite width. Range: 0-512 (0: auto; use total width of the sprite)
height | 0 | Sprite height. Range: 0-512 (0: auto; use total height of the sprite)
numframes | 1 | Number of frames
framerate | 1.0 | Speed of framerates
holdTime | 1.0 | Hold time
fadeinTime | 0.5 | Fade In Time
fadeoutTime | 0.5 | Fade Out Time
color1 | (see enum colors) | |
color2 | (see enum colors) | |
effect |  (see enum effect) | |
spawnflags | (see enum spawnflags) | |

**Enum Colors**
value | color
------|------
0 | RGBA_WHITE
1 | RGBA_BLACK
2 | RGBA_RED
3 | RGBA_GREEN
4 | RGBA_BLUE
5 | RGBA_YELLOW
6 | RGBA_ORANGE
7 | RGBA_SVENCOOP

**Enum Effect**
value | effect name | description 
------|-------------|------------
0 | HUD_EFFECT_NONE | No effect.
1 | HUD_EFFECT_RAMP_UP | Linear ramp up from color1 to color2.
2 | HUD_EFFECT_RAMP_DOWN | Linear ramp down from color2 to color1.
3 | HUD_EFFECT_TRIANGLE | Linear ramp up and ramp down from color1 through color2 back to color1.
4 | HUD_EFFECT_COSINE_UP | Cosine ramp up from color1 to color2.
5 | HUD_EFFECT_COSINE_DOWN | Cosine ramp down from color2 to color1.
6 | HUD_EFFECT_COSINE | Cosine ramp up and ramp down from color1 through color2 back to color1.
7 | HUD_EFFECT_TOGGLE | Toggle between color1 and color2.
8 | HUD_EFFECT_SINE_PULSE | Sine pulse from color1 through zero to color2.

**Enum Spawnflags**
Spawnflag | flag name | description 
----------|-----------|------------
1 | HUD_ELEM_ABSOLUTE_X | X position in pixels.
2 | HUD_ELEM_ABSOLUTE_Y | Y position in pixels.
4 | HUD_ELEM_SCR_CENTER_X | X position relative to the center of the screen.
8 | HUD_ELEM_SCR_CENTER_Y | Y position relative to the center of the screen.
16 | HUD_ELEM_NO_BORDER | Ignore the client-side HUD border (hud_bordersize).
32 | HUD_ELEM_HIDDEN | Create a hidden element.
64 | HUD_ELEM_EFFECT_ONCE | Play the effect only once.
128 | HUD_ELEM_DEFAULT_ALPHA | Use the default client-side HUD alpha (hud_defaultalpha).
256 | HUD_ELEM_DYNAMIC_ALPHA | Use the default client-side HUD alpha and flash the element when updated.
65536 | HUD_SPR_OPAQUE | Draw opaque sprite.
131072 | HUD_SPR_MASKED | Draw masked sprite.
262144 | HUD_SPR_PLAY_ONCE | Play the animation only once.
524288 | HUD_SPR_HIDE_WHEN_STOPPED | Hide the sprite when the animation stops.