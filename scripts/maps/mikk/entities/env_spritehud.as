/*
	Shows a sprite on the hud
	See the wiki https://github.com/Mikk155/Sven-Co-op/wiki/env_spritehud-Spanish

INSTALL:

#include "mikk/entities/env_spritehud"

void MapInit()
{
	RegisterEnvSpriteHud();
}
*/

void RegisterEnvSpriteHud()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "env_spritehud", "env_spritehud" );
}

class env_spritehud : ScriptBaseEntity
{
	HUDSpriteParams params;

    private int color1 = 0;
    private int color2 = 0;
    private int effect = 0;
	
	bool KeyValue( const string& in szKey, const string& in szValue ){
		if(szKey == "channel")
			params.channel = atoi(szValue);
        else if( szKey == "color1" )
            color1 = atoi( szValue );
        else if( szKey == "color2" )
            color2 = atoi( szValue );
        else if( szKey == "effect" )
            effect = atoi( szValue );
		else if(szKey == "frame")
			params.frame = atoi(szValue);
		else if(szKey == "numframes")
			params.numframes = atoi(szValue);
		else if(szKey == "framerate")
			params.framerate = atoi(szValue);
		else if(szKey == "x")
			params.x = atof(szValue);
		else if(szKey == "y")
			params.y = atof(szValue);
		else if(szKey == "top")
			params.top = atoi(szValue);
		else if(szKey == "left")
			params.left = atoi(szValue);
		else if(szKey == "width")
			params.width = atoi(szValue);
		else if(szKey == "height")
			params.height = atoi(szValue);
		else if(szKey == "fadeinTime")
			params.fadeinTime = atof(szValue);
		else if(szKey == "fadeoutTime")
			params.fadeoutTime = atof(szValue);
		else if(szKey == "holdTime")
			params.holdTime = atof(szValue);
		else if(szKey == "fxtime")
			params.fxTime = atof(szValue);
		else 
			return BaseClass.KeyValue( szKey, szValue );
		return true;
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( "sprites/" + self.pev.model );
		g_Game.PrecacheGeneric( "sprites/" + self.pev.model );
		BaseClass.Precache();
	}
	
	void Spawn()
	{
		SetChoices();
        params.spritename = string( self.pev.model );
		BaseClass.Spawn();
	}
	
	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		if( string( self.pev.targetname ) != "!activator" && pActivator !is null && pActivator.IsPlayer() )
		{
			g_PlayerFuncs.HudCustomSprite( cast<CBasePlayer@>(pActivator), params );
		}
		else
		{
			for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
			{
				CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

				if( pPlayer !is null )
				{
					g_PlayerFuncs.HudCustomSprite( pPlayer, params );
				}
			}
		}
	}
	
	void SetChoices()
	{
		if( color1 == 0 ) { params.color1 = RGBA_WHITE; }
		else if( color1 == 1 ) { params.color1 = RGBA_BLACK; }
		else if( color1 == 2 ) { params.color1 = RGBA_RED; }
		else if( color1 == 3 ) { params.color1 = RGBA_GREEN; }
		else if( color1 == 4 ) { params.color1 = RGBA_BLUE; }
		else if( color1 == 5 ) { params.color1 = RGBA_YELLOW; }
		else if( color1 == 6 ) { params.color1 = RGBA_ORANGE; }
		else if( color1 == 7 ) { params.color1 = RGBA_SVENCOOP; }
		
		if( color2 == 0 ) { params.color2 = RGBA_WHITE; }
		else if( color2 == 1 ) { params.color2 = RGBA_BLACK; }
		else if( color2 == 2 ) { params.color2 = RGBA_RED; }
		else if( color2 == 3 ) { params.color2 = RGBA_GREEN; }
		else if( color2 == 4 ) { params.color2 = RGBA_BLUE; }
		else if( color2 == 5 ) { params.color2 = RGBA_YELLOW; }
		else if( color2 == 6 ) { params.color2 = RGBA_ORANGE; }
		else if( color2 == 7 ) { params.color2 = RGBA_SVENCOOP; }

		if( effect == 0 ) { params.effect = HUD_EFFECT_NONE; }
		else if( effect == 1 ) { params.effect = HUD_EFFECT_RAMP_UP; }
		else if( effect == 2 ) { params.effect = HUD_EFFECT_RAMP_DOWN; }
		else if( effect == 3 ) { params.effect = HUD_EFFECT_TRIANGLE; }
		else if( effect == 4 ) { params.effect = HUD_EFFECT_COSINE_UP; }
		else if( effect == 5 ) { params.effect = HUD_EFFECT_COSINE_DOWN; }
		else if( effect == 6 ) { params.effect = HUD_EFFECT_COSINE; }
		else if( effect == 7 ) { params.effect = HUD_EFFECT_TOGGLE; }
		else if( effect == 8 ) { params.effect = HUD_EFFECT_SINE_PULSE; }

		params.flags = HUD_NUM(self.pev.spawnflags);
	}
}