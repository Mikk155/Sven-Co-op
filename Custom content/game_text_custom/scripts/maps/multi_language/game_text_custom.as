/*

#include "Gaftherman/game_text_custom"

void MapInit()
{
	RegisterCustomTextGame();
}

*/

enum EnumLanguage
{
	LANGUAGE_ENGLISH = 0, 
	LANGUAGE_SPANISH,
	LANGUAGE_PORTUGUESE,	
	LANGUAGE_GERMAN,
	LANGUAGE_FRENCH,
	LANGUAGE_ITALIAN,
	LANGUAGE_ESPERANTO	
}
	
enum EnumSpawnFlags
{
	SF_ALL_PLAYERS = 1 << 0
}
	 
class game_text_custom : ScriptBaseEntity
{
	HUDTextParams TextParams;
	private string_t message_spanish, message_portuguese, message_german, message_french, message_italian, message_esperanto;
		
	void Spawn() 
	{
		self.pev.solid = SOLID_NOT;
		self.pev.movetype = MOVETYPE_NONE;
		self.pev.framerate = 1.0f;
			
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		BaseClass.Spawn();	
	}
		
	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if(szKey == "channel")
		{
			TextParams.channel = atoi(szValue);
			return true;
		}
		else if(szKey == "x")
		{
			TextParams.x = atof(szValue);
			return true;
		}
		else if(szKey == "y")
		{
			TextParams.y = atof(szValue);
			return true;
		}
		else if(szKey == "effect")
		{
			TextParams.effect = atoi(szValue);
			return true;
		}
		else if(szKey == "color")
		{
			string delimiter = " ";
			array<string> splitColor = {"","",""};
			splitColor = szValue.Split(delimiter);
			array<uint8>result = {0,0,0};
			result[0] = atoi(splitColor[0]);
			result[1] = atoi(splitColor[1]);
			result[2] = atoi(splitColor[2]);
			if (result[0] > 255) result[0] = 255;
			if (result[1] > 255) result[1] = 255;
			if (result[2] > 255) result[2] = 255;
			RGBA vcolor = RGBA(result[0],result[1],result[2]);
			TextParams.r1 = vcolor.r;
			TextParams.g1 = vcolor.g;
			TextParams.b1 = vcolor.b;
			return true;
		}
		else if(szKey == "color2")
		{
			string delimiter2 = " ";
			array<string> splitColor2 = {"","",""};
			splitColor2 = szValue.Split(delimiter2);
			array<uint8>result2 = {0,0,0};
			result2[0] = atoi(splitColor2[0]);
			result2[1] = atoi(splitColor2[1]);
			result2[2] = atoi(splitColor2[2]);
			if (result2[0] > 255) result2[0] = 255;
			if (result2[1] > 255) result2[1] = 255;
			if (result2[2] > 255) result2[2] = 255;
			RGBA vcolor2 = RGBA(result2[0],result2[1],result2[2]);
			TextParams.r2 = vcolor2.r;
			TextParams.g2 = vcolor2.g;
			TextParams.b2 = vcolor2.b;
			return true;
		}
		else if(szKey == "fadein")
		{
			TextParams.fadeinTime = atof(szValue);
			return true;
		}
		else if(szKey == "fadeout")
		{
			TextParams.fadeoutTime = atof(szValue);
			return true;
		}
		else if(szKey == "holdtime")
		{
			TextParams.holdTime = atof(szValue);
			return true;
		}
		else if(szKey == "fxtime")
		{
			TextParams.fxTime = atof(szValue);
			return true;
		}
		else if(szKey == "message_spanish")
		{
			message_spanish = szValue;
			return true;
		}
		else if(szKey == "message_portuguese")
		{
			message_portuguese = szValue;
			return true;
		}
		else if(szKey == "message_german")
		{
			message_german = szValue;
			return true;
		}
		else if(szKey == "message_french")
		{
			message_french = szValue;
			return true;
		}
		else if(szKey == "message_italian")
		{
			message_italian = szValue;
			return true;
		}
		else if(szKey == "message_esperanto")
		{
			message_esperanto = szValue;
			return true;
		}
		else 
		{
			return BaseClass.KeyValue( szKey, szValue );
		}
	}
		
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		if( !pActivator.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);

        CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
        CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
        int iLanguage = int(ckLenguageIs.GetFloat());

		if( self.pev.SpawnFlagBitSet(SF_ALL_PLAYERS) )
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer2 = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
						
				if( pPlayer2 is null || !pPlayer2.IsConnected() )
					continue;

				if(iLanguage == LANGUAGE_ENGLISH)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, self.pev.message );
					
				if(iLanguage == LANGUAGE_SPANISH)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_spanish );	

				if(iLanguage == LANGUAGE_PORTUGUESE)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_portuguese );	

				if(iLanguage == LANGUAGE_GERMAN)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_german );	

				if(iLanguage == LANGUAGE_FRENCH)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_french );	

				if(iLanguage == LANGUAGE_ITALIAN)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_italian );		

				if(iLanguage == LANGUAGE_ESPERANTO)
					g_PlayerFuncs.HudMessage( pPlayer2, TextParams, message_esperanto );		
			}
		}
		else
		{
			if(iLanguage == LANGUAGE_ENGLISH)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, self.pev.message );

			if(iLanguage == LANGUAGE_SPANISH)	
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_spanish );

			if(iLanguage == LANGUAGE_PORTUGUESE)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_portuguese );	

			if(iLanguage == LANGUAGE_GERMAN)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_german );	

			if(iLanguage == LANGUAGE_FRENCH)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_french );	

			if(iLanguage == LANGUAGE_ITALIAN)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_italian );

			if(iLanguage == LANGUAGE_ESPERANTO)
				g_PlayerFuncs.HudMessage( pPlayer, TextParams, message_esperanto );		
		}
	}
}
	
void RegisterCustomTextGame()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom", "game_text_custom" );
}
