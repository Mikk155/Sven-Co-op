/*
	Replacemet for point_checkpoint that will save everyone's lifes and not only dead ones.
	
	NOTE: This scripts required you to Include https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as


OLD SCRIPT but im not doing lazyripent yet until v2 or something

*/

#include "../respawndead_keepweapons"

void RegisterGameSave()
{
	g_Hooks.RegisterHook( Hooks::Player::PlayerPreThink, @PlayerUseSpawn::PlayerUse );
	g_CustomEntityFuncs.RegisterCustomEntity( "game_save", "point_checkpoint" );
	g_Game.PrecacheOther( "point_checkpoint" );

	dictionary keyvalues;

	keyvalues =	
	{
		{ "message", "Press 'E' key to respawn"},
		{ "message_spanish", "Presione la tecla 'E' para reaparecer"},
		{ "message_portuguese", "Pressione a tecla 'E' para reaparecer"},
		{ "message_french", "Appuyez sur la touche 'E' pour reapparaitre"},
		{ "message_italian", "Premi il tasto 'E' per rigenerarti"},
		{ "message_esperanto", "Premu la 'E' klavon por reakiri"},
		{ "message_german", "Drucken Sie die 'E'-Taste, um zu respawnen"},
		{ "x", "-1"},
		{ "y", "0.67"},
		{ "effect", "0"},
		{ "holdtime", "1"},
		{ "fadeout", "0"},
		{ "fadein", "0"},
		{ "channel", "7"},
		{ "fxtime", "0"},
		{ "color", "255 0 0"},
		{ "color2", "100 100 100"},
		{ "spawnflags", "2"}, // No echo console + activator only
		{ "targetname", "GZ_IZL_HOWTOUSE"}
	};
	if( g_CustomEntityFuncs.IsCustomEntity( "game_text_custom" ) )
	{ g_EntityFuncs.CreateEntity( "game_text_custom", keyvalues, true ); }
	else{ g_EntityFuncs.CreateEntity( "game_text", keyvalues, true ); }
}

HUDTextParams SpawnCountHudText;

class game_save : ScriptBaseEntity  
{
	bool Disabled = true;
	private string strFunnelSprite = "sprites/glow01.spr";
	private string strStartSound = "ambience/particle_suck2.wav";
	private string strEndSound = "debris/beamstart7.wav";
	private string m_sActivationMusic = "../media/valve.mp3"; // Class member so it can be customisable - Outerbeast

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "minhullsize" )
			g_Utility.StringToVector( self.pev.vuser1, szValue );
		else if( szKey == "maxhullsize" )
			g_Utility.StringToVector( self.pev.vuser2, szValue );
		else if( szKey == "sprite" )
			strFunnelSprite = szValue;
		else if( szKey == "startsound" )
			strStartSound = szValue;
		else if( szKey == "endsound" )
			strEndSound = szValue;
		else if( szKey == "music" ) // Key to change activation music to something other than valve theme - Outerbeast
		{
			m_sActivationMusic = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );

		return true;
	}

	void Spawn()
	{
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_TRIGGER;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );

		if( !self.pev.SpawnFlagBitSet( 1 ) )
		{
			SetIcon();
			
			SetTouch( TouchFunction( this.SpawnTouch ) );
			self.pev.nextthink = g_Engine.time + 0.1f;
		}
		
		if( self.pev.vuser2 == g_vecZero && self.pev.vuser1 == g_vecZero )
		{
			g_EntityFuncs.SetSize( self.pev, Vector( -200, -200, -32 ), Vector( 200, 200, 32 ) );
		}

	    BaseClass.Spawn();
	}
	
	void SetIcon()
	{
		self.pev.framerate 		= 1.0f;
		
		self.pev.rendermode		= kRenderTransTexture;
		self.pev.renderamt		= 255;
		
		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/common/lambda.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );
	}

	void Precache()
	{
		// Allow for custom models
		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( "models/common/lambda.mdl" );
			g_Game.PrecacheGeneric( "models/common/lambda.mdl" );
		}
		else
		{
			g_Game.PrecacheModel( self.pev.model );
			g_Game.PrecacheGeneric( string( self.pev.model ) );
		}

		g_Game.PrecacheModel( strFunnelSprite );
		g_Game.PrecacheModel( "sprites/fexplo1.spr" ); // Outerbeast: Fix for precache host error in CreateSpawnEffect()
		g_Game.PrecacheGeneric( strFunnelSprite );

		g_SoundSystem.PrecacheSound( strStartSound );
		g_SoundSystem.PrecacheSound( strEndSound );

		g_Game.PrecacheGeneric( "sound/" + strStartSound );
		g_Game.PrecacheGeneric( "sound/" + strEndSound );
		
		g_SoundSystem.PrecacheSound( m_sActivationMusic );

		BaseClass.Precache();
	}

	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
	{
		if( self.pev.SpawnFlagBitSet( 1 ) )
		{
			g_Scheduler.SetTimeout( this, "SpawnSnd", 1.6f );

			NetworkMessage largefunnel( MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null );
				largefunnel.WriteByte( TE_LARGEFUNNEL );

				largefunnel.WriteCoord( self.pev.origin.x );
				largefunnel.WriteCoord( self.pev.origin.y );
				largefunnel.WriteCoord( self.pev.origin.z );

				largefunnel.WriteShort( g_EngineFuncs.ModelIndex( "" + strFunnelSprite ) );
				largefunnel.WriteShort( 0 );
			largefunnel.End();

			g_Scheduler.SetTimeout( this, "CreateCheckpoint", 6.0f );
		}
		else
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, m_sActivationMusic, 1.0f, ATTN_NONE ); // Change to use custom activation music if set - Outerbeast
			
			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "GAME SAVED: Game saved by the map\n" );
			
			SaveStore();
			
			SetThink( ThinkFunction( this.SpawnThink ) );
			
			Disabled = false;
		}
	}

	void SpawnSnd()
	{
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, strStartSound, 1.0f, ATTN_NORM );
	}

    void CreateCheckpoint()
    {
		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, strEndSound, 1.0f, ATTN_NORM );
		
		SetIcon();
		
		SetTouch( TouchFunction( this.SpawnTouch ) );

		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void SpawnTouch( CBaseEntity@ pOther )
	{
		if( !Disabled )
			return;

		if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, m_sActivationMusic, 1.0f, ATTN_NONE ); // Change to use custom activation music if set - Outerbeast

			g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, "Game saved by " + pOther.pev.netname + "\n" );

			SaveStore();

			SetThink( ThinkFunction( this.SpawnThink ) );

			Disabled = false;
		}
		
		self.pev.nextthink = g_Engine.time + 0.1f;
	}
	
	void SaveStore()
	{
		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
			int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_gs_spawns").GetInteger();
			ckvSpawns.SetKeyvalue("$i_gs_spawns", kvSpawnIs + 1 );

			self.SUB_UseTargets( self, USE_TOGGLE, 0 );
		}
	}
	
	void SpawnThink()
	{
		if ( self.pev.renderamt > 0 )
		{
			self.pev.renderamt -= 20;
		}

		if ( self.pev.renderamt < 20 )
		{
			g_EntityFuncs.Remove( self );
		}

        self.pev.nextthink = g_Engine.time + 0.2f; //per frame
    }
}

namespace PlayerUseSpawn
{
	HookReturnCode PlayerUse( CBasePlayer@ pPlayer, uint& out uiFlags )
	{
		CustomKeyvalues@ ckvSpawns = pPlayer.GetCustomKeyvalues();
		int kvSpawnIs = ckvSpawns.GetKeyvalue("$i_gs_spawns").GetInteger();

		SpawnCountHudText.x = 0.05;
		SpawnCountHudText.y = 0.05;
		SpawnCountHudText.effect = 0;
		SpawnCountHudText.r1 = RGBA_SVENCOOP.r;
		SpawnCountHudText.g1 = RGBA_SVENCOOP.g;
		SpawnCountHudText.b1 = RGBA_SVENCOOP.b;
		SpawnCountHudText.a1 = 0;
		SpawnCountHudText.r2 = RGBA_SVENCOOP.r;
		SpawnCountHudText.g2 = RGBA_SVENCOOP.g;
		SpawnCountHudText.b2 = RGBA_SVENCOOP.b;
		SpawnCountHudText.a2 = 0;
		SpawnCountHudText.fadeinTime = 0; 
		SpawnCountHudText.fadeoutTime = 0.25;
		SpawnCountHudText.holdTime = 0.2;
		SpawnCountHudText.fxTime = 0;
		SpawnCountHudText.channel = 6;

		g_PlayerFuncs.HudMessage(pPlayer, SpawnCountHudText, "Spawns: " + kvSpawnIs +"" );

		if( pPlayer is null or kvSpawnIs <= 0 )
			return HOOK_CONTINUE;

		if( !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() )
		{
			g_EntityFuncs.FireTargets( "GZ_IZL_HOWTOUSE", pPlayer, pPlayer, USE_ON );
		
			if( pPlayer.m_afButtonLast & IN_USE != 0 || pPlayer.m_afButtonPressed & IN_USE != 0  )
			{
				pPlayer.GetObserver().RemoveDeadBody(); //Remove the dead player body
				
				g_PlayerFuncs.RespawnPlayer( pPlayer, false, true );

				// Must include https://github.com/Outerbeast/Entities-and-Gamemodes/blob/master/respawndead_keepweapons.as
				RESPAWNDEAD_KEEPWEAPONS::ReEquipCollected( pPlayer, true );
				
				ckvSpawns.SetKeyvalue("$i_gs_spawns", kvSpawnIs - 1 );
			}
		}
		return HOOK_CONTINUE;
	}
}	// End of namespace