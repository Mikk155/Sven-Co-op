/*
	Original idea and game_text_custom base by Kmkz.
	
	game_text_custom
	The same as game_text but this entity will support custom languages if the plugin is being used.

	"message" is the default message, should be placeholder for english.
	"message_spanish" will be shown if spanish is choosen and so on with other languages. see utils for supported languages.
	
	game_popup by Outerbeast and Giegue. Merged here for the use of languages.
	

INSTALL:

#include "mikk/multi_language"
#include "mikk/entities/utils"
#include "mikk/entities/game_text_custom"

void MapInit()
{
	RegisterCustomTextGame();
	MultiLanguageInit();
}

*/

void RegisterCustomTextGame()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "game_text_custom", "game_text_custom" );
}

class game_text_custom : ScriptBaseEntity, MLAN::MoreKeyValues
{
	HUDTextParams TextParams;
	private string killtarget = "";

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
		// Game text legacy -// For some reasons this is not doing TOGGLE. not sure. didn't tested more than func_wall_toggle.
		self.SUB_UseTargets( pPlayer, USE_TOGGLE, 0 );
		
		// Ditto
		if( killtarget != "" && killtarget != self.GetTargetname() )
		{
			do g_EntityFuncs.Remove( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) );
			while( g_EntityFuncs.FindEntityByTargetname( null, killtarget ) !is null );
		}
		
		int iLanguage = MLAN::GetCKV(pPlayer, "$f_lenguage");

		if( !self.pev.SpawnFlagBitSet( 2 ) )	// No echo console flag
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTCONSOLE, string(ReadLanguages(iLanguage))+"\n" );
		}

		// Game text things
		if( TextParams.effect <= 2 )
		{
			g_PlayerFuncs.HudMessage( pPlayer, TextParams, ReadLanguages(iLanguage) );
		}
		// trigger_once/multiple-like messages
		else if( TextParams.effect == 3 )
		{
			g_PlayerFuncs.ShowMessage( pPlayer, ""+string(ReadLanguages(iLanguage))+"\n" );
		}
		// Scrolling mesage ( must trigger to update)
		else if( TextParams.effect == 4 )
		{
			TextParams.y -= 0.005;

			if( TextParams.y < 0 )
			{
				g_EntityFuncs.Remove( self );
			}
		}
		// Ditto. opposite.
		else if( TextParams.effect == 5 )
		{
			TextParams.y += 0.005;
			
			if( TextParams.y > 1 )
			{
				g_EntityFuncs.Remove( self );
			}
		}
		// Motd message
		else if( TextParams.effect == 6 )
		{
			ShowMOTD( pPlayer, string( "motd info" ), string( ReadLanguages(iLanguage)  ) );
		}
		// Chat message
		else if( TextParams.effect == 7 )
		{
			g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, ""+string(ReadLanguages(iLanguage))+"\n" );
		}
	}

    /*	Shows a MOTD message to the player -Code by Geigue	*/
    void ShowMOTD(EHandle hPlayer, const string& in szTitle, const string& in szMessage)
    {
        if( !hPlayer )
            return;

        CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

        if( pPlayer is null )
            return;
        
        NetworkMessage title( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        title.WriteString( szTitle );
        title.End();
        
        uint iChars = 0;
        string szSplitMsg = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        
        for( uint uChars = 0; uChars < szMessage.Length(); uChars++ )
        {
            szSplitMsg.SetCharAt( iChars, char( szMessage[ uChars ] ) );
            iChars++;
            if( iChars == 32 )
            {
                NetworkMessage message( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
                message.WriteByte( 0 );
                message.WriteString( szSplitMsg );
                message.End();
                
                iChars = 0;
            }
        }
		
        // If we reached the end, send the last letters of the message
        if( iChars > 0 )
        {
            szSplitMsg.Truncate( iChars );
            
            NetworkMessage fix( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
            fix.WriteByte( 0 );
            fix.WriteString( szSplitMsg );
            fix.End();
        }
        
        NetworkMessage endMOTD( MSG_ONE_UNRELIABLE, NetworkMessages::MOTD, pPlayer.edict() );
        endMOTD.WriteByte( 1 );
        endMOTD.WriteString( "\n" );
        endMOTD.End();
        
        NetworkMessage restore( MSG_ONE_UNRELIABLE, NetworkMessages::ServerName, pPlayer.edict() );
        restore.WriteString( g_EngineFuncs.CVarGetString( "hostname" ) );
        restore.End();
    }
}