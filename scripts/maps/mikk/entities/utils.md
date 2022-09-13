[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Entity Utils es un script de codigo expuesto asi que otras entidades/scripts pueden interactuar con el. mi "utils" esta en el directorio ``scripts/maps/mikk/entities/utils.as`` deberas incluir este script en tu script principal o en tu entidad custom funcionará tambien 
```angelscript
#include "mikk/entities/utils"
```
Esto te ofrecerá las siguientes mecanicas.

Necesitar que una entidad este dentro de otra
Usage:
```angelscript
	if( UTILS::InsideZone( pPlayer, self ) )
```
En este caso ``pPlayer`` se refiere a la entidad que debera estar dentro de ``self``

Codigo original tomado de [Cubemath](https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/trigger_once_mp.as#L63)
```angelscript
bool InsideZone( CBaseEntity@ pInsider, CBaseEntity@ pCornerZone )
{
	bool blInside = true;
	blInside = blInside && pInsider.pev.origin.x + pInsider.pev.maxs.x >= pCornerZone.pev.origin.x + pCornerZone.pev.mins.x;
	blInside = blInside && pInsider.pev.origin.y + pInsider.pev.maxs.y >= pCornerZone.pev.origin.y + pCornerZone.pev.mins.y;
	blInside = blInside && pInsider.pev.origin.z + pInsider.pev.maxs.z >= pCornerZone.pev.origin.z + pCornerZone.pev.mins.z;
	blInside = blInside && pInsider.pev.origin.x + pInsider.pev.mins.x <= pCornerZone.pev.origin.x + pCornerZone.pev.maxs.x;
	blInside = blInside && pInsider.pev.origin.y + pInsider.pev.mins.y <= pCornerZone.pev.origin.y + pCornerZone.pev.maxs.y;
	blInside = blInside && pInsider.pev.origin.z + pInsider.pev.mins.z <= pCornerZone.pev.origin.z + pCornerZone.pev.maxs.z;
	return blInside;
}
```
Permite que tu entidad elija ser SolidBase (BSPClip) o PointBase ([BBox](https://developer.valvesoftware.com/wiki/Bounding_box))

Uso:
```angelscript
void Spawn()
{
	UTILS::SetSize( self );
}
```
Para hacerla SolidBase simplemente asigna un brush-model a entidad. de lo contrario puedes crear la [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) con las keys ``vuser1`` y ``vuser2`` MinHullSize y MaxHullSize respectivamente.
```angelscript
void SetSize( CBaseEntity@ pMaxMin )
{
	if( pMaxMin.GetClassname() == string(pMaxMin.pev.classname) && string( pMaxMin.pev.model )[0] == "*" && pMaxMin.IsBSPModel() )
	{
		g_EntityFuncs.SetModel( pMaxMin, pMaxMin.pev.model );
		g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.mins, pMaxMin.pev.maxs );
	}
	else
	{
		g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.vuser1, pMaxMin.pev.vuser2 );		
	}
}
```

Permite que tu entidad custom pueda utilizar [Multi-Language](https://github.com/Mikk155/Sven-Co-op/wiki/Multi-Language-Spanish)

Deberas añadir el siguiente codigo en orden para ello.

- | Primero debes llamar la función ``MLAN::MoreKeyValues`` justo luego de tu class.

**Ejemplo:**
```angelscript
class game_text_custom : ScriptBaseEntity, MLAN::MoreKeyValues
{
}
```

- 2 Ahora debes añadir los nuevos valores dentro de las keyvalues de tu entidad. ``SexKeyValues(szKey, szValue);``

**Ejemplo:**
```angelscript
bool KeyValue( const string& in szKey, const string& in szValue )
{
	SexKeyValues(szKey, szValue);

	if(szKey == "x")
	{
		TextParams.x = atof(szValue);
	}
	else if(szKey == "y")
	{
		TextParams.y = atof(szValue);
	}
	else 
	{
		return BaseClass.KeyValue( szKey, szValue );
	}

	return true;
}
```

- 3 Llama a todos los jugadores o pActivator/pOther para ver su custom keyvalue y obtener su lenguaje
```angelscript
int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
```

**Ejemplo:**
```angelscript
void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if ( self.pev.SpawnFlagBitSet( 1 ) )
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer !is null )
			{
				CallText( pPlayer );
			}
		}
	}
	else if( pActivator !is null && pActivator.IsPlayer() )
	{	
		CallText( cast<CBasePlayer@>(pActivator) );
	}
}

void CallText( CBasePlayer@ pPlayer )
{
	int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
```
(Los siguientes ejemplos provienen de la misma función CallText)

- 4 Ahora debes agregar el metodo de Remplazo ya que hemos actualizado una mecanica en game_text_custom que necesitabamos.
```angelscript
string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "!frags", ""+int(self.pev.frags) }, {"!activator", ""+self.pev.netname } } );
```

- 5 Ahora una vez llegados al final simplemente muestra el debido mensaje a el jugador.

**Ejemplo:**
```angelscript
g_PlayerFuncs.ShowMessage( pPlayer, ""+ReadLanguage+"\n" );
```
Luego de todo ese codigo. la función ``ReadLanguage`` contendrá la keyvalue correspondiente a el valor del jugador y será mostrado el mensaje correcto.

**Probables preguntas:**
- Si estoy usando un idioma que el mapa no tiene me perderé los mensajes?
	No. mientras que un mensaje no exista siempre se te mostrará el mensaje original ``message``

- Hay limites de idioma?
	Tecnicamente no. la unica limitante es que estamos ligados a usar solamente romaji sencillo.

- Porque el codigo es externo?
	De este modo tu no debes modificar tu entidad cuando un lenguaje nuevo sea añadido.

# SPANISH

Entity Utils es un script de codigo expuesto asi que otras entidades/scripts pueden interactuar con el. mi "utils" esta en el directorio ``scripts/maps/mikk/entities/utils.as`` deberas incluir este script en tu script principal o en tu entidad custom funcionará tambien 
```angelscript
#include "mikk/entities/utils"
```
Esto te ofrecerá las siguientes mecanicas.

Necesitar que una entidad este dentro de otra
Usage:
```angelscript
	if( UTILS::InsideZone( pPlayer, self ) )
```
En este caso ``pPlayer`` se refiere a la entidad que debera estar dentro de ``self``

Codigo original tomado de [Cubemath](https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/trigger_once_mp.as#L63)
```angelscript
bool InsideZone( CBaseEntity@ pInsider, CBaseEntity@ pCornerZone )
{
	bool blInside = true;
	blInside = blInside && pInsider.pev.origin.x + pInsider.pev.maxs.x >= pCornerZone.pev.origin.x + pCornerZone.pev.mins.x;
	blInside = blInside && pInsider.pev.origin.y + pInsider.pev.maxs.y >= pCornerZone.pev.origin.y + pCornerZone.pev.mins.y;
	blInside = blInside && pInsider.pev.origin.z + pInsider.pev.maxs.z >= pCornerZone.pev.origin.z + pCornerZone.pev.mins.z;
	blInside = blInside && pInsider.pev.origin.x + pInsider.pev.mins.x <= pCornerZone.pev.origin.x + pCornerZone.pev.maxs.x;
	blInside = blInside && pInsider.pev.origin.y + pInsider.pev.mins.y <= pCornerZone.pev.origin.y + pCornerZone.pev.maxs.y;
	blInside = blInside && pInsider.pev.origin.z + pInsider.pev.mins.z <= pCornerZone.pev.origin.z + pCornerZone.pev.maxs.z;
	return blInside;
}
```
Permite que tu entidad elija ser SolidBase (BSPClip) o PointBase ([BBox](https://developer.valvesoftware.com/wiki/Bounding_box))

Uso:
```angelscript
void Spawn()
{
	UTILS::SetSize( self );
}
```
Para hacerla SolidBase simplemente asigna un brush-model a entidad. de lo contrario puedes crear la [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) con las keys ``vuser1`` y ``vuser2`` MinHullSize y MaxHullSize respectivamente.
```angelscript
void SetSize( CBaseEntity@ pMaxMin )
{
	if( pMaxMin.GetClassname() == string(pMaxMin.pev.classname) && string( pMaxMin.pev.model )[0] == "*" && pMaxMin.IsBSPModel() )
	{
		g_EntityFuncs.SetModel( pMaxMin, pMaxMin.pev.model );
		g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.mins, pMaxMin.pev.maxs );
	}
	else
	{
		g_EntityFuncs.SetSize( pMaxMin.pev, pMaxMin.pev.vuser1, pMaxMin.pev.vuser2 );		
	}
}
```

Permite que tu entidad custom pueda utilizar [Multi-Language](https://github.com/Mikk155/Sven-Co-op/wiki/Multi-Language-Spanish)

Deberas añadir el siguiente codigo en orden para ello.

- | Primero debes llamar la función ``MLAN::MoreKeyValues`` justo luego de tu class.

**Ejemplo:**
```angelscript
class game_text_custom : ScriptBaseEntity, MLAN::MoreKeyValues
{
}
```

- 2 Ahora debes añadir los nuevos valores dentro de las keyvalues de tu entidad. ``SexKeyValues(szKey, szValue);``

**Ejemplo:**
```angelscript
bool KeyValue( const string& in szKey, const string& in szValue )
{
	SexKeyValues(szKey, szValue);

	if(szKey == "x")
	{
		TextParams.x = atof(szValue);
	}
	else if(szKey == "y")
	{
		TextParams.y = atof(szValue);
	}
	else 
	{
		return BaseClass.KeyValue( szKey, szValue );
	}

	return true;
}
```

- 3 Llama a todos los jugadores o pActivator/pOther para ver su custom keyvalue y obtener su lenguaje
```angelscript
int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
```

**Ejemplo:**
```angelscript
void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
{
	if ( self.pev.SpawnFlagBitSet( 1 ) )
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer !is null )
			{
				CallText( pPlayer );
			}
		}
	}
	else if( pActivator !is null && pActivator.IsPlayer() )
	{	
		CallText( cast<CBasePlayer@>(pActivator) );
	}
}

void CallText( CBasePlayer@ pPlayer )
{
	int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
```
(Los siguientes ejemplos provienen de la misma función CallText)

- 4 Ahora debes agregar el metodo de Remplazo ya que hemos actualizado una mecanica en game_text_custom que necesitabamos.
```angelscript
string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "!frags", ""+int(self.pev.frags) }, {"!activator", ""+self.pev.netname } } );
```

- 5 Ahora una vez llegados al final simplemente muestra el debido mensaje a el jugador.

**Ejemplo:**
```angelscript
g_PlayerFuncs.ShowMessage( pPlayer, ""+ReadLanguage+"\n" );
```
Luego de todo ese codigo. la función ``ReadLanguage`` contendrá la keyvalue correspondiente a el valor del jugador y será mostrado el mensaje correcto.

**Probables preguntas:**
- Si estoy usando un idioma que el mapa no tiene me perderé los mensajes?
	No. mientras que un mensaje no exista siempre se te mostrará el mensaje original ``message``

- Hay limites de idioma?
	Tecnicamente no. la unica limitante es que estamos ligados a usar solamente romaji sencillo.

- Porque el codigo es externo?
	De este modo tu no debes modificar tu entidad cuando un lenguaje nuevo sea añadido.