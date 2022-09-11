/*
	Original script by Cubemath: https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/item_airbubble.as
	

INSTALL:

#include "mikk/entities/item_airbubble"

void MapInit()
{
	RegisterAirbubbleCustomEntity();
}

*/

void RegisterAirbubbleCustomEntity()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "item_airbubble", "item_airbubble" );
	g_CustomEntityFuncs.RegisterCustomEntity( "item_miniairbubble", "item_miniairbubble" );
	g_Game.PrecacheOther( "item_miniairbubble" );
}

class item_airbubble : ScriptBaseEntity 
{
	void Precache() 
	{
		BaseClass.Precache();
		
		if( string( self.pev.model ).IsEmpty() ) { g_Game.PrecacheModel( "models/w_oxygen.mdl" ); } else{ g_Game.PrecacheModel( self.pev.model ); }
		
		g_Game.PrecacheModel( "sprites/bubble.spr" );
		g_Game.PrecacheGeneric( "sound/debris/bustflesh1.wav" );
		g_SoundSystem.PrecacheSound( "debris/bustflesh1.wav" );
	}
	
	void Spawn()
	{
		Precache();
		
		self.pev.movetype 		= MOVETYPE_NONE;
		self.pev.solid 			= SOLID_TRIGGER;
		self.pev.scale			= self.pev.scale;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		
		if( string( self.pev.model ).IsEmpty() ){g_EntityFuncs.SetModel( self, "models/w_oxygen.mdl" );}else{g_EntityFuncs.SetModel( self, self.pev.model);}
		
		g_EntityFuncs.SetSize( self.pev, Vector(-32, -32, -32), Vector(32, 32, 32) );
		
		SetThink( ThinkFunction( this.letsRespawn ) );
	}
	
	void letsRespawn() 
	{
		self.pev.renderamt = 255;
		self.pev.solid = SOLID_TRIGGER;
	}
	
	void Touch( CBaseEntity@ pOther ) 
	{
		if( pOther is null || !pOther.IsPlayer() ) 
		return;

		g_SoundSystem.EmitSoundDyn( pOther.edict(), CHAN_ITEM, "debris/bustflesh1.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH );
		
		pOther.pev.air_finished = g_Engine.time + 12.0;
		self.pev.solid = SOLID_NOT;
		self.pev.renderamt = 50;
        self.pev.nextthink = g_Engine.time + 1.0f;
		
		for(int i = 0; i < 20; ++i)
		{
			CBaseEntity@ pEnt = g_EntityFuncs.Create("item_miniairbubble", self.pev.origin+Vector( 0, 0, 50 ), Vector(0, 0, 0), false);
			pEnt.pev.velocity.x = Math.RandomFloat(-128.0f, 128.0f);
			pEnt.pev.velocity.y = Math.RandomFloat(-128.0f, 128.0f);
			pEnt.pev.velocity.z = Math.RandomFloat(-128.0f, 128.0f);
		}
	}
}

class item_miniairbubble : ScriptBaseEntity
{
	private float lifeTime;
	
	void Spawn()
	{
		self.pev.movetype 		= MOVETYPE_FLY;
		self.pev.solid 			= SOLID_TRIGGER;
		self.pev.rendermode		= 2;
		self.pev.renderamt		= 255;
		self.pev.scale 			= 0.5;
		
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		g_EntityFuncs.SetModel( self, "sprites/bubble.spr" );
		g_EntityFuncs.SetSize( self.pev, Vector(-8, -8, -8), Vector(8, 8, 8) );
		
		lifeTime = g_Engine.time + 1.0f;
		SetThink( ThinkFunction( this.ownThink ) );
        self.pev.nextthink = g_Engine.time + 0.05f;
	}
	
	void ownThink()
	{
		if(lifeTime < g_Engine.time + 1.0f)
		{
			if(lifeTime < g_Engine.time)
			{
				g_EntityFuncs.Remove( self );
			}
			self.pev.renderamt = (lifeTime - g_Engine.time) * 255.0f;
		}
        self.pev.nextthink = g_Engine.time + 0.01f;
	}
}