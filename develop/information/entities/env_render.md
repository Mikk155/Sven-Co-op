# env_render

env_render is an entity that allows to modify the rendering of other entities. See [Render Settings](render_settings.md)

- Key ``armorvalue``
	- Asigns in a radious, Units, that env_render is going to find its objective, If it is outside the radious then it will not affect the rendering.
	- Value of 0 deactivates this mechanic.

| Bit | Flag | Description |
|-----|------|-------------|
| 1 | No render-fx | Renderfx is not going to be modified |
| 2 | No render-amt | Rrenderamt is not going to be modified |
| 4 | No render-mode | Rendermode is not going to be modified |
| 8 | No render-color | Rendercolor is not going to be modified |
| 16 | Auto apply | Automatically applies in a radious (armorvalue) the rendering when the objective enters the range, otherwise the entity has to be activated each time |

- Using env_render by default, will not matter wich USE_TYPE you send, it will always activate.

# env_render_custom

![image](../../images/angelscript.png)

<details><summary>Install</summary>
<p>

- Read [Install](../install.md)

- Requirements
	- scripts/maps/mikk/[env_render_custom.as](../../../scripts/maps/mikk/env_render_custom.as)
	- scripts/maps/mikk/[utils.as](../../../scripts/maps/mikk/utils.as)

</p>
</details>

| Key | Descripction |
|-----|-------------|
| $i_angelscript | You have to explicitly choose if use or not the next functinos, 0 = don't use, 1 = use |
| $s_target | Entity to activate when rendermode is applied, the entity that got their render changed will be !activator |
| Spawnflags 64 | You have to explicitly choose if use or not the next functions, Active = use |
| $f_gradual | Time, Interval (float) to change gradually the renderamt of the affected entity |
| $i_gradual | renderamt, Quantity of value that renderamt will change each interval, It needs a prefix, use (+) to add, use (-) to subtract |
| $s_gradual | renderamt, Maximum quantity to reach, the renderamt of the affected entity will change until it reaches this value |

<details><summary>Example</summary>
<p>

```angelscript
"$f_gradual" "1.0"
"$i_gradual" "-10"
"$s_gradual" "0"
```
In this case, each 1.0 seconds, we will subtract 10 on the objective until it reaches 0.
</p>
</details>

- Using "Render gradually" the target ($s_target) will be activated when the objective reaches the desired rendermode.

- Behavior of [activation](triggering_system.md)

| USE_OFF | Others | target USE_TYPE |
|---------|-------|-----------------|
| Asigns original render settings of the entity | Asigns render settings | USE_TOGGLE |

- Radius and Auto Apply do not work while other functinos of Angelscript are being used.
