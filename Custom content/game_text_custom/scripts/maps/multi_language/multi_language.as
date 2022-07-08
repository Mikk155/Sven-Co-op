// Read current map .ent localization script.
const string EntFileLoad = "multi_language/localizations/" + string( g_Engine.mapname ) + ".ent";

// Include game_text_custom
#include "game_text_custom"

void MultiLanguageInit()
{
	// Register game_text_custom
	RegisterCustomTextGame();
}

void MultiLanguageActivate()
{
	CBaseEntity@ pEntity = null;
	
	if( !g_EntityLoader.LoadFromFile( EntFileLoad ) )
	{
		g_EngineFuncs.ServerPrint( "Can't open multi-language script file " + EntFileLoad + "\n" );
	}
	else
	{
		// Delete old text entities if new ones is created.
		while ( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "game_text" ) ) !is null )
		{
			g_EntityFuncs.Remove( pEntity );
		}
		while ( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "env_message" ) ) !is null )
		{
			g_EntityFuncs.Remove( pEntity );
		}
	}
}