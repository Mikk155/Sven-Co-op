[See in english](#english)

[Leer en español](#spanish)

# ENGLISH

Entity Utils is a script with exposed code soo that other entities/scripts can interact with it. my "utils" are in the directory ``scripts/maps/mikk/entities/utils.as`` you will have to include this script in your main script or in your custom entity would work too
```angelscript
#include "mikk/entities/utils"
```
this will offer the next mechanics.

**namespace UTILS**

- [Send trigger state the same as a multi_manager does](#send-trigger-state-the-same-as-a-multi_manager-does)

- [Requires a entity be inside other entity](#Requires-a-entity-be-inside-other-entity)

- [Let your entity decide being solid or point type](#Let-your-entity-decide-being-solid-or-point-type)

- [Shows a motd information box](#Shows-a-motd-information-box)

**namespace MLAN**

- [Allows your custom entity to be able to use Multi Language](#Allows-your-custom-entity-to-be-able-to-use-Multi-Language)

**namespace NETWORKMSG**

- [Show scoreboard like when game end](#show-scoreboard-like-when-game-end)

- [Toggle third/first person](#Toggle-third-&-first-person)

- [Shake camera](#Shake-camera)

- [Show HλLF-LIFE logo](#Show-HλLF-LIFE-logo)

- [Scoreboard Title](#Scoreboard-Title)

- [ScoreInfo Players](#ScoreInfo-Players)

## namespace UTILS

# Send trigger state the same as a multi_manager does
[multi_manager](https://sites.google.com/site/svenmanor/entguide/multi_manager) has the hability to send different trigger types for their targets as USE_ON, USE_OFF, USE_KILL, USE_TOGGLE (default)

So we've do a this for using that feature on our custom entities.

**USAGE:**
```
UTILS::TriggerMode(self, self.pev.target, pPlayer);
```

In your entity just use ``"target" "TriggerThis#1"``

- The first argument "self" defines your custom entity. dont change

- The second argument defines the key that you're using. we've used target, netname and message for multiples triggers

- The third argument defines the activator.

# Requires a entity be inside other entity

Usage:
```angelscript
	if( UTILS::InsideZone( pPlayer, self ) )
```
In this case ``pPlayer`` refers that entity that must be inside ``self``

Original code taken from [Cubemath](https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/trigger_once_mp.as#L63)
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

# Let your entity decide being solid or point type

Let your entity choose to be SolidBase (BSPClip) or PointBase ([BBox](https://developer.valvesoftware.com/wiki/Bounding_box))

Usage:
```angelscript
void Spawn()
{
	UTILS::SetSize( self );
}
```
To make it SolidBase just asign it to a brush-model otherwise you can set a [BBox](https://developer.valvesoftware.com/wiki/Bounding_box) with the keys ``vuser1`` and ``vuser2`` MinHullSize and MaxHullSize respectivelly.
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

# Shows a motd information box

- Code by Geigue
```angelscript
	UTILS::ShowMOTD( pPlayer, "motd title", "motd contain" );
```

## namespace MLAN

# Allows your custom entity to be able to use Multi Language

[Multi-Language](https://github.com/Mikk155/Sven-Co-op/wiki/Multi-Language-Spanish)

You have to add the next code for it to work.

- | first you have to call the function ``MLAN::MoreKeyValues`` just after your class.

**Example:**
```angelscript
class game_text_custom : ScriptBaseEntity, MLAN::MoreKeyValues
{
}
```

- 2 Now you have to add the new values inside the keyvalues of your entity. ``SexKeyValues(szKey, szValue);``

**Example:**
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

- 3 Call all the players or pActivator/pOther to see their custom keyvalue and obtain their language
```angelscript
int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
```

**Example:**
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
(The next examples comes from the same function CallText)

- 4
```angelscript
g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string(ReadLanguages(iLanguage))+"\n" );
```
After all that code. the function ``ReadLanguage`` will contain the respective keyvalue to the value of the player and it will show in the correct message.

**Alternativelly to step 4**

You have to add the replacement method since we updated a mechanic in game_text_custom wich we needed.
```angelscript
string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "!frags", ""+int(self.pev.frags) }, {"!activator", ""+self.pev.netname } } );
```
Now once we reached the end simply show the correct message to the player.
**Example:**
```angelscript
g_PlayerFuncs.ShowMessage( pPlayer, ""+ReadLanguage+"\n" );
```


**Possible questions:**
- If i am using a language that the map does not have will i miss the messages?
	No. while a message does not exist the original ``message`` will be shown

- Is there a language limit?
	Technically no. the only limiting factor that we are bound to is using simple romaji.

- Why the code is external?
	This way you don't have to modify your entity when a new language is added.

## namespace NETWORKMSG

Code taken from [DrAbcOficial](https://github.com/Mikk155/DrAbcOfficial-AngelScripts/blob/master/lib/networkmessage.as)

# Show scoreboard like when game end

- can't disable

**Usage:**
```angelscript
	NETWORKMSG::SVC_INTERMISSION();
```

code:
```angelscript
    void SVC_INTERMISSION()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
        message.End();
    }
```

# Toggle third & first person

**Usage:**
```angelscript
	NETWORKMSG::ViewMode( 1, pPlayer );
```
- The first argument defines the mode.

- 0 first person

- 1 third person

Code:
```angelscript

    void ViewMode( int imode, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ViewMode, pPlayer.edict() );
            message.WriteByte(imode);
        message.End();
    }
```

# Shake camera

**Usage:**
```angelscript
	NETWORKMSG::Concuss( 15, -15, 15, pPlayer );
```
the arguments defines:

- 1 yall

- 2 pitch

- 3 roll

Code:
```angelscript
    void Concuss( int yall, int pitch, int roll, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::Concuss, pPlayer.edict() );
            message.WriteFloat(yall);
            message.WriteFloat(pitch);
            message.WriteFloat(roll);
        message.End();
    }
```

# Show HλLF-LIFE logo

**Usage:**
```angelscript
	NETWORKMSG::GameTitle();
```

Code:
```angelscript
    void GameTitle()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::GameTitle );
        message.WriteByte(1);
        message.End();
    }
```

# Scoreboard Title

**Usage:**
Change server hostname at score board. do not actually touchs hostname. only shows on scoreboard
```angelscript
	NETWORKMSG::ServerName("The best fucking map");
```

Code:
```angelscript
    void ServerName( const string StrTitle)
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
            message.WriteString(StrTitle);
        message.End();
    }
```

# ScoreInfo Players

**Usage:**
On scoreboard information. doesn't modify player values only visual in scoreboard.
```angelscript
	NETWORKMSG::ScoreInfo(0, 0, 0, 0, 0, 0, 0, pPlayer );
```
The arguments defines:

- 1 points (frags)

- 2 deaths

- 3 health

- 4 armor

- 5 team

- 6 icon (See bellow)

- 7 server icon (See bellow)

**Icon**

- 0 none

- 1 electro crowbar

- 2 golden uzi

- 3 dollar

- 4 tester

- 5 artist

- 6 developer

**Server Icon**

- 0 none

- 1 admin

- 2 serverowner

Code:
```angelscript
    void ScoreInfo(int frags, int death, int health, int armor, int team, int icon, int server, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ScoreInfo, pPlayer.edict() );
            message.WriteByte(1);
            message.WriteFloat(frags);
            message.WriteLong(death);
            message.WriteFloat(health);
            message.WriteFloat(armor);
            message.WriteByte(team);
            message.WriteShort(icon);
            message.WriteShort(server);
        message.End();
    }
```

# SPANISH

Entity Utils es un script de codigo expuesto asi que otras entidades/scripts pueden interactuar con el. mi "utils" esta en el directorio ``scripts/maps/mikk/entities/utils.as`` deberas incluir este script en tu script principal o en tu entidad custom funcionará tambien 
```angelscript
#include "mikk/entities/utils"
```
Esto te ofrecerá las siguientes mecanicas.

**namespace UTILS**

- [Enviar un tipo de trigger igual como multi_manager lo hace](#enviar-un-tipo-de-trigger-igual-como-multi_manager-lo-hace)

- [Necesita que una entidad este dentro de otra](#Necesita-que-una-entidad-este-dentro-de-otra)

- [Permite que tu entidad pueda ser solid o point based](#Permite-que-tu-entidad-pueda-ser-solid-o-point-based)

- [Muestra un motd con informacion en su caja](#Muestra-un-motd-con-informacion-en-su-caja)

**namespace MLAN**

- [Permite que tu entidad haga uso de multiples lenguajes](#Permite-que-tu-entidad-haga-uso-de-multiples-lenguajes)

**namespace NETWORKMSG**

- [Muestra la tabla de puntuación como si el juego terminara](#Muestra-la-tabla-de-puntuación-como-si-el-juego-terminara)

- [Varia entre tercera/primera persona](#Varia-entre-tercera-y-primera-persona)

- [Sacude la camera](#Sacude-la-camera)

- [Muestra el logo de HλLF-LIFE](#Muestra-el-logo-de-HλLF-LIFE)

- [Titulo en la tabla de puntuación](#Titulo-en-la-tabla-de-puntuación)

- [Jugadores en la tabla de puntuación](#Jugadores-en-la-tabla-de-puntuación)

## namespace UTILS

# Enviar un tipo de trigger igual como multi_manager lo hace

[multi_manager](https://sites.google.com/site/svenmanor/entguide/multi_manager) Tiene la habilidad de enviar diferentes tipos de trigger a sus targets como USE_ON, USE_OFF, USE_KILL, USE_TOGGLE (por defecto)

Asi que hemos hecho esto para usar esa mecanica en nuestras entidades custom.

**USO:**
```
UTILS::TriggerMode(self, self.pev.target, pPlayer);
```

En tu entidad luego solo usarias ``"target" "TriggerThis#1"``

- El primer argumento "self" define tu entidad custom. no cambiar

- El segundo argumento define la key que estas usando. usamos target, netname y message para multiples triggers.

- El tercer argumento define el activador.


# Necesita que una entidad este dentro de otra

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

# Permite que tu entidad pueda ser solid o point based
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

# Muestra un motd con informacion en su caja

- Codigo por Geigue
```angelscript
	UTILS::ShowMOTD( pPlayer, "motd title", "motd contain" );
```

## namespace MLAN

# Permite que tu entidad haga uso de multiples lenguajes

[Multi-Language](https://github.com/Mikk155/Sven-Co-op/wiki/Multi-Language-Spanish)

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

- 4
```angelscript
g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string(ReadLanguages(iLanguage))+"\n" );
```
Luego de todo ese codigo. la función ``ReadLanguage`` contendrá la keyvalue correspondiente a el valor del jugador y será mostrado el mensaje correcto.

**Alternativamente para el paso 4**

Puedes agregar el metodo de Remplazo ya que hemos actualizado una mecanica en game_text_custom que necesitabamos.
```angelscript
string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "!frags", ""+int(self.pev.frags) }, {"!activator", ""+self.pev.netname } } );
```
Ahora una vez llegados al final simplemente muestra el debido mensaje a el jugador.
**Ejemplo:**
```angelscript
g_PlayerFuncs.ShowMessage( pPlayer, ""+ReadLanguage+"\n" );
```

**Probables preguntas:**
- Si estoy usando un idioma que el mapa no tiene me perderé los mensajes?
	No. mientras que un mensaje no exista siempre se te mostrará el mensaje original ``message``

- Hay limites de idioma?
	Tecnicamente no. la unica limitante es que estamos ligados a usar solamente romaji sencillo.

- Porque el codigo es externo?
	De este modo tu no debes modificar tu entidad cuando un lenguaje nuevo sea añadido.

## namespace NETWORKMSG

Code taken from [DrAbcOficial](https://github.com/Mikk155/DrAbcOfficial-AngelScripts/blob/master/lib/networkmessage.as)

# Muestra la tabla de puntuación como si el juego terminara

- No puede ser desactivado

**Uso:**
```angelscript
	NETWORKMSG::SVC_INTERMISSION();
```

codigo:
```angelscript
    void SVC_INTERMISSION()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
        message.End();
    }
```

# Varia entre tercera y primera persona

**Uso:**
```angelscript
	NETWORKMSG::ViewMode( 1, pPlayer );
```
- El primer argumento define el modo.

- 0 Primera persona

- 1 Tercera persona

Codigo:
```angelscript

    void ViewMode( int imode, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ViewMode, pPlayer.edict() );
            message.WriteByte(imode);
        message.End();
    }
```

# Sacude la camera

**Uso:**
```angelscript
	NETWORKMSG::Concuss( 15, -15, 15, pPlayer );
```
Los argumentos definen:

- 1 yall

- 2 pitch

- 3 roll

Codigo:
```angelscript
    void Concuss( int yall, int pitch, int roll, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::Concuss, pPlayer.edict() );
            message.WriteFloat(yall);
            message.WriteFloat(pitch);
            message.WriteFloat(roll);
        message.End();
    }
```

# Muestra el logo de HλLF-LIFE

**Uso:**
```angelscript
	NETWORKMSG::GameTitle();
```

Codigo:
```angelscript
    void GameTitle()
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::GameTitle );
        message.WriteByte(1);
        message.End();
    }
```

# Titulo en la tabla de puntuación

**Uso:**
Cambia el nombre del servidor en la tabla de puntuación. no modifica el nombre realmente. solo en la tabla de puntuación.
```angelscript
	NETWORKMSG::ServerName("The best fucking map");
```

Codigo:
```angelscript
    void ServerName( const string StrTitle)
    {
        NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
            message.WriteString(StrTitle);
        message.End();
    }
```

# Jugadores en la tabla de puntuación

**Uso:**
Información en la tabla de puntuación. No modifican valores del jugador simplemente es visual.
```angelscript
	NETWORKMSG::ScoreInfo(0, 0, 0, 0, 0, 0, 0, pPlayer );
```
Los argumentos definen:

- 1 puntos (frags)

- 2 duertes

- 3 vida

- 4 armadura

- 5 equipo

- 6 icono del jugador (Ver abajo)

- 7 icono del servidor (Ver abajo)

**Icono**

- 0 ninguno

- 1 palanca electrica

- 2 uzi dorada

- 3 dolar

- 4 tester

- 5 artista

- 6 desarollador

**Iconos del servidor**

- 0 ninguno

- 1 administrador

- 2 Owner del server

Codigo:
```angelscript
    void ScoreInfo(int frags, int death, int health, int armor, int team, int icon, int server, CBasePlayer@ pPlayer )
    {
        NetworkMessage message( MSG_ONE, NetworkMessages::ScoreInfo, pPlayer.edict() );
            message.WriteByte(1);
            message.WriteFloat(frags);
            message.WriteLong(death);
            message.WriteFloat(health);
            message.WriteFloat(armor);
            message.WriteByte(team);
            message.WriteShort(icon);
            message.WriteShort(server);
        message.End();
    }
```