# Custom KeyValues

The custom keyvalues are, to a degree, a mechanic since Sven Co-op 4.6

Using Custom Keyvalues you can save all information you want in an entity, with names you choose.

While the normal keyvalues are gonna be read by the entity in question, custom entities are discarted.

The custom keyvalues are identifies by having the dollar symbol ``$`` as the first character. 

The game is goingto read the next custom keyvalues with the prefix that defines wich type of keyvalue it will be.

Examples:

- $s_
	- ``string`` Is composed by a string, basically text format that is going to be read how it is written.

- $i_
	- ``integer`` Is composed by a whole number. Without dicemals, can have negative values.

- $f_
	- ``float`` Is composed by a number with decimals. can have negative values.
	
- $v_
	- ``Vector`` Is composed by three floats

Examples:
```angelscript
"$s_keyvalue" "This is a string and can contain any character supported by the game"
"$i_keyvalue" "128"
"$f_keyvalue" "128.00000"
"$v_keyvalue" "128.000 255 259.00"
```

# Add custom keyvalues

There are different ways to add custom keyvalues. The most direct one is add them directly into an entity.

You can also add them with a [trigger_changevalue](trigger_changevalue_english.md).

The main reason that custom keyvalues were added in the game is to give mappers an alternative to save information inside entities. here is a list of possible uses and scenearios that might inspire you:

- ``$i_fuel``
	- Saved in the player, represents how much fuel he has for a jetpack.
	
- ``$i_keycardlevel``
	- Saved in a player, represents the security level this player has to access a door .

You can read them at all times with [trigger_condition](trigger_condition_english.md) to execute actions dependently.
