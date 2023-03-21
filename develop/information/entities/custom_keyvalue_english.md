# Custom KeyValues

The custom keyvalues are, to a degree, a mechanic since Sven Co-op 4.6

Utilizando Custom Keyvalues Puedes guardar toda la información que tu quieras en una entidad, con los nombres que tu quieras tambien.

Mientras que las keyvalues normales van a ser leidas internamente por la entidad en cuestion, las custom keyvalues son descartadas.

Las custom keyvalues son identificadas por llevar un signo de dolar ``$`` en su primer caracter. 

El juego va a leer las siguientes custom keyvalues con un prefijo que define que tipo de keyvalue será.

Ejemplos:

- $s_
	- ``string`` Se compone por un string, basicamente formato de texto que será leido tal cual fue escrito.

- $i_
	- ``integer`` Se compone por un numero entero. sin ninguna decima, puede tener valores negativos.

- $f_
	- ``float`` Se compone por un numero con decimas. puede tener valores negativos.
	
- $v_
	- ``Vector`` Se compone por tres float

Ejemplos:
```angelscript
"$s_keyvalue" "Esto es una string y puede contener cualquier caracter soportado por el juego"
"$i_keyvalue" "128"
"$f_keyvalue" "128.00000"
"$v_keyvalue" "128.000 255 259.00"
```

# Añadir custom keyvalues

Hay diferentes formas de añadir custom keyvalues. la mas directa es agregarlas directamente en la entidad.

Puedes tambien agregarlas mediante [trigger_changevalue](trigger_changevalue_english.md).

La razon principal de las custom keyvalues es que fueron añadidas al juego para darle al mapper una alternativa para guardar informacion en las entidades. aqui una lista de posibles usos y escenarios que podrian inspirarte:

- ``$i_fuel``
	- Guardada en un jugador, Representa cuanta gasolina tiene para un jetpack.
	
- ``$i_keycardlevel``
	- Guardada en un jugador, Representa que nivel tiene este jugador para acceder a una puerta de seguridad.

Puedes leerlas en todo momento con [trigger_condition](trigger_condition_english.md) para efectuar acciones dependientemente.
