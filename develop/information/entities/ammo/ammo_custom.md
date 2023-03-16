### ammo_custom

ammo_custom is an ammo item customizable that gives a specified ammout of bullets that the entity sets.

<details><summary>Installation</summary>
<p>

```bat
set Main=https://github.com/Mikk155/Sven-Co-op/raw/main/
set Files=utils ammo_custom
set output=scripts/maps/mikk/
if not exist %output% (
  mkdir %output:/=\%
)
(for %%a in (%Files%) do (
  curl -LJO %Main%%%a.as
  
  move %%a.as %Output%
)) 
```

In your main map_script add:
```angelscript
#include "mikk/ammo_custom"

void MapInit()
{
	ammo_custom::Register();
}
```

</p>
</details>

Base Support [ammo](ammo.md).

| key | value | description |
|-----|-------|-------------|
| model | string | defines a custom world model |
| p_sound | string | defines a custom sound to use when the item is taken |
| am_name | [choices](#values-am_name) | defines the type of ammunition this item will give to players |
| am_give | integer | number of bullets that this item should give to the players |
| frags | integer | How many times player can take this item (affect only activator) 0 = infinite ( if set and player is above the count, the item is render invisible for that player and he can't pickup it anymore |

### Values am_name

- buckshot
- 9mm
- ARgrenades
- sporeclip
- rockets
- uranium
- bolts
- 556
- 357
- m40a1
- satchel
- Trip Mine
- Hand Grenade
- snarks

### Notes:

⚠️ The player must have already equiped the items that classifies as "weapons" the ammo will be added but the player won't be able to select them until collect a weapon.

List:
- satchel
- Trip Mine
- Hand Grenade
- snarks