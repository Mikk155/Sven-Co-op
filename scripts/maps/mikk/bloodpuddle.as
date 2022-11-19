/*
INSTALL:

#include "mikk/bloodpuddle"

void MapInit()
{
	RegisterBloodPuddle();
}

*/

void RegisterBloodPuddle()
{
    if( g_CustomEntityFuncs.IsCustomEntity( "blood" ) )
        return;

	g_CustomEntityFuncs.RegisterCustomEntity( "blood", "blood" );
	g_Game.PrecacheOther( "blood" );

	g_Scheduler.SetInterval( "EntityDied", 0.5, g_Scheduler.REPEAT_INFINITE_TIMES );
}

void EntityDied()
{
	CBaseEntity@ pDeadEntity = null;
	while((@pDeadEntity = g_EntityFuncs.FindEntityByClassname( pDeadEntity, "monster_*" )) !is null )
	{
		CustomKeyvalues@ kvDeadEntity = pDeadEntity.GetCustomKeyvalues();
		CBaseMonster@ pMonsterBlood = cast<CBaseMonster@>(pDeadEntity);

		if( pMonsterBlood is null || pDeadEntity.IsPlayer() || pMonsterBlood.IsPlayer() )
			continue;

		if( pDeadEntity.pev.deadflag == DEAD_DEAD && int(kvDeadEntity.GetKeyvalue( "$i_blood" ).GetInteger()) == 0 )
		{

			CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "blood", null, true);
            pBlood.SetOrigin( pDeadEntity.Center() + Vector( 0, 0, 6 ) );

			if( pMonsterBlood.m_bloodColor == (BLOOD_COLOR_GREEN | BLOOD_COLOR_YELLOW)  )
				pBlood.pev.skin = 1;
			else
				pBlood.pev.skin = 0;

			@pBlood.pev.owner = pDeadEntity.edict();

			kvDeadEntity.SetKeyvalue("$i_blood", 1);
		}
	}
}

class blood : ScriptBaseAnimating
{
    void Spawn()
    {
        Precache();

        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_NOT;
		self.pev.scale = Math.RandomFloat( 1.5, 2.5 );

        g_EntityFuncs.SetModel(self, "models/mikk/misc/bloodpuddle.mdl");
        g_EntityFuncs.SetOrigin(self, self.pev.origin);
		self.pev.sequence = 2;

		SetThink( ThinkFunction( this.BloodPreSpawn ) );
		self.pev.nextthink = g_Engine.time + 0.8f;
    }

	void Precache()
	{
		g_Game.PrecacheModel( "models/mikk/misc/bloodpuddle.mdl" );

        BaseClass.Precache();
    }

	void BloodPreSpawn()
	{
		self.pev.sequence = 1;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
		self.pev.framerate = Math.RandomFloat( 0.3, 0.6 );	

		SetThink( ThinkFunction( this.BloodThink ) );
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void BloodThink()
	{
		CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );

		if( pOwner !is null && self != pOwner && pOwner.IsMonster() )
		{
			self.pev.origin = pOwner.pev.origin;
		}

		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.1;
	}
}