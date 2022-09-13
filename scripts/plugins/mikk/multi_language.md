[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Multi-Language offers to Scriptes and Mappers the hability of doing use of adding language support for player's choice that they can change on-the-fly dynamically.

it works by adding to them a custom keyvalue. see more about custom keyvalues at [svenmanor](https://sites.google.com/site/svenmanor/entguide/custom-keyvalues)

Other plugins, scripts or custom entities can interact with those keyvalues and get their values for showing the correct message.

**INSTALL:**
```angelscript
	"plugin"
	{
		"name" "Multi-Language"
		"script" "mikk/multi_language"
	}
```

Setup your plugin is pretty easy. you only need to get this value from players and then show the proper message. the basic code looks like this

```angelscript
void YourFuction()
{
	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
	int iLanguage = int(ckLenguageIs.GetFloat());

	if(iLanguage == 1 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 1 (Spanish)" );
	}
	else if(iLanguage == 2 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 2 (Portuguese)" );
	}
	else if(iLanguage == 3 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 3 (German)" );
	}
	else if(iLanguage == 4 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 4 (French)" );
	}
	else if(iLanguage == 5 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 5 (Italian)" );
	}
	else if(iLanguage == 6 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 6 (Esperanto)" );
	}
	else
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 0 or anything else (English)" );
	}
}
```

For set up your custom entity see [utils](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/utils.md)

For supported languages see [Suported languages](https://github.com/Mikk155/Sven-Co-op/wiki/Supported-Languages)

For maps translations see [Localizations list](https://github.com/Mikk155/Sven-Co-op/wiki/Localizations)

# SPANISH

Multi-Language Ofrece a los mappers y scriptes la habilidad de dar uso al soporte de multi-lenguaje por elección de los jugadores que puede ser cambiado en el aire y dinamicamente.

Esto funciona añadiendo una custom keyvalue en ellos. mas informacion sobre custom keyvalues en [svenmanor](https://sites.google.com/site/svenmanor/entguide/custom-keyvalues)

Otros plugins, scripts o entidades custom pueden iteractuar con esta keyvalue y tomar su valor para luego mostrar el mensaje correcto a su lenguaje.

**INSTALAR:**
```angelscript
	"plugin"
	{
		"name" "Multi-Language"
		"script" "mikk/multi_language"
	}
```

Configurar tu script es bastante simple. solo debes tomar el valor de los jugadores y mostrar el mensaje correcto. la base del codigo luce asi

```angelscript
void YourFuction()
{
	CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
	CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
	int iLanguage = int(ckLenguageIs.GetFloat());

	if(iLanguage == 1 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 1 (Spanish)" );
	}
	else if(iLanguage == 2 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 2 (Portuguese)" );
	}
	else if(iLanguage == 3 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 3 (German)" );
	}
	else if(iLanguage == 4 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 4 (French)" );
	}
	else if(iLanguage == 5 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 5 (Italian)" );
	}
	else if(iLanguage == 6 )
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 6 (Esperanto)" );
	}
	else
	{
		g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "This message will be shown if player choice is equal to 0 or anything else (English)" );
	}
}
```

Para configurar tu entidad custom mira [utils](https://github.com/Mikk155/Sven-Co-op/blob/main/scripts/maps/mikk/entities/utils.md)

Para saber los lenguajes soportados mira [Suported languages](https://github.com/Mikk155/Sven-Co-op/wiki/Supported-Languages)

Para ver lista de mapas traducidos mira [Localizations list](https://github.com/Mikk155/Sven-Co-op/wiki/Localizations)

