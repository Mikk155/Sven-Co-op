/*
	-Original idea and game_text_custom base by Kmkz.

	-Modified by Mikk & Gaftherman.

INSTALL:

#include "mikk/entities/game_text_custom"

void MapInit()
{
	RegisterCustomTextGame();
}

	If you're going to mod with this please check the wiki
	https://github.com/Mikk155/Sven-Co-op/wiki/Supported-Languages-Spanish
	
	
	
	
	Suggestions:
	-
	-
	-
	-
	-
*/
#include "utils"

void RegisterCustomTextGame()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom", "game_text_custom" );

	const string EntFileLoad = "mikk/translations/" + string( g_Engine.mapname ) + ".ent";

	if( g_EntityLoader.LoadFromFile( EntFileLoad ) ) g_EngineFuncs.ServerPrint( "Loaded entities from " + EntFileLoad + "\n" );
	else g_EngineFuncs.ServerPrint( "Can't open multi-language script file " + EntFileLoad + "\n" );
}

class game_text_custom : ScriptBaseEntity, MLAN::MoreKeyValues
{
	HUDTextParams TextParams;
	private string killtarget = "";
	private string messagesound = "null.wav";
	private float messagevolume = 10;

	void Precache()
	{
		g_SoundSystem.PrecacheSound( messagesound );
		g_Game.PrecacheGeneric( "sound/" + messagesound );

		BaseClass.Precache();
	}

	void Spawn()
	{
		Precache();
		
		CBaseEntity@ pGameText = g_EntityFuncs.FindEntityByTargetname( pGameText, string( self.pev.targetname ) );
		
		if( string( pGameText.pev.classname ) != "game_text_custom" )
		{
			g_EntityFuncs.Remove( pGameText );
		}

		BaseClass.Spawn();
	}

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		SexKeyValues(szKey, szValue);

		if(szKey == "channel")
		{
			TextParams.channel = atoi(szValue);
		}
		else if(szKey == "x")
		{
			TextParams.x = atof(szValue);
		}
		else if(szKey == "y")
		{
			TextParams.y = atof(szValue);
		}
		else if(szKey == "effect")
		{
			TextParams.effect = atoi(szValue);
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
		}
		else if(szKey == "fadein")
		{
			TextParams.fadeinTime = atof(szValue);
		}
		else if(szKey == "fadeout")
		{
			TextParams.fadeoutTime = atof(szValue);
		}
		else if(szKey == "holdtime")
		{
			TextParams.holdTime = atof(szValue);
		}
		else if(szKey == "fxtime")
		{
			TextParams.fxTime = atof(szValue);
		}
		else if( szKey == "killtarget" )
		{
            killtarget = szValue;
		}
		else if( szKey == "messagesound" )
		{
            messagesound = szValue;
		}
		else if( szKey == "messagevolume" )
		{
            messagevolume = atof(szValue);
		}
		else 
		{
			return BaseClass.KeyValue( szKey, szValue );
		}
		return true;
	}

	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		// All players flag
		if ( self.pev.SpawnFlagBitSet( 1 ) )
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer !is null )
				{
					if( pActivator !is null && pActivator.IsPlayer() ) self.pev.netname = pActivator.pev.netname;

					CallText( pPlayer );
				}
			}
			// Game text legacy -
			g_EntityFuncs.FireTargets( string( self.pev.target ), null, null, USE_TOGGLE );
		}
		else if( pActivator !is null && pActivator.IsPlayer() )
		{
			self.pev.netname = pActivator.pev.netname;
			CallText( cast<CBasePlayer@>(pActivator) );

			// Game text legacy -
			g_EntityFuncs.FireTargets( string( self.pev.target ), pActivator, pActivator, USE_TOGGLE );
		}
		// Game text legacy -
		if( killtarget != "" && killtarget != self.GetTargetname() )
		{
			do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) );
			while( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) !is null );
		}
	}

	void CallText( CBasePlayer@ pPlayer )
	{
		int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");
		
		string ReadLanguage = MLAN::Replace(ReadLanguages(iLanguage), { { "!frags", ""+int(self.pev.frags) }, {"!activator", ""+self.pev.netname } } );

		// No echo console flag
		if( !self.pev.SpawnFlagBitSet( 2 ) ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, ReadLanguage+"\n" );

		// Game text things
		if( TextParams.effect <= 2 ) g_PlayerFuncs.HudMessage( pPlayer, TextParams, ReadLanguage+"\n" );

		// trigger_once/multiple-like messages
		else if( TextParams.effect == 3 ) g_PlayerFuncs.ShowMessage( pPlayer, ""+ReadLanguage+"\n" );

		// Motd message
		else if( TextParams.effect == 4 ) UTILS::ShowMOTD( pPlayer, string( "motd info" ), ReadLanguage+"\n" );

		// Chat message
		else if( TextParams.effect == 5 ) g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, ""+ReadLanguage+"\n" );

		// Subtitle -WiP
		else if( TextParams.effect == 6 )  g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, ""+ReadLanguage+"\n (Subtitle effect not implemented yet)\n" );

		// Prints the key binded "use +alt1 to attack" -> "use [MOUSE3] to attack"
		else if( TextParams.effect == 7 ) g_PlayerFuncs.PrintKeyBindingString( pPlayer, ""+ReadLanguage+"\n"  );

		// env_message legacy
		if( messagesound != "" ) g_SoundSystem.PlaySound( pPlayer.edict(), CHAN_AUTO, messagesound, messagevolume/10, ATTN_NORM, 0, PITCH_NORM, pPlayer.entindex(), true, pPlayer.GetOrigin() );
	}
}