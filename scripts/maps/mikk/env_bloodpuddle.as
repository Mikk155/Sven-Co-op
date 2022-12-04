/*
DOWNLOAD:

models/mikk/misc/bloodpuddle.mdl
scripts/maps/mikk/env_bloodpuddle.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/env_bloodpuddle"

void MapInit()
{
    env_bloodpuddle::Register();
}

OR DOWNLOAD:

models/mikk/misc/bloodpuddle.mdl
scripts/maps/mikk/env_bloodpuddle.as
scripts/maps/mikk/env_bloodpuddle_plugin.as
scripts/maps/mikk/utils.as


INSTALL:

	"plugin"
	{
		"name" "BloodPuddle"
		"script" "../maps/mikk/env_bloodpuddle_plugin"
	}
*/

#include "utils"

namespace env_bloodpuddle
{
    void Register()
    {
        if( g_CustomEntityFuncs.IsCustomEntity( "env_bloodpuddle" ) )
            return;

		g_Scheduler.SetInterval( "bloodpuddleThink", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
        g_CustomEntityFuncs.RegisterCustomEntity( "env_bloodpuddle::env_bloodpuddle", "env_bloodpuddle" );
        g_Game.PrecacheOther( "env_bloodpuddle" );
    }

    void bloodpuddleThink()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            if( pEntity !is null && pEntity.IsMonster() && pEntity.pev.deadflag == DEAD_DEAD && UTILS::GetFloatCKV( pEntity, "$f_bloodpuddle" ) <= 0.0 )
            {
                CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "env_bloodpuddle", null, true);

                if( cast<CBaseMonster@>(pEntity).m_bloodColor == ( DONT_BLEED )  )
                {
                    g_EntityFuncs.Remove( pBlood );
                }
                else if( cast<CBaseMonster@>(pEntity).m_bloodColor == ( BLOOD_COLOR_RED )  )
                {
                    pBlood.pev.skin = 0;
                }
                else if( cast<CBaseMonster@>(pEntity).m_bloodColor == ( BLOOD_COLOR_GREEN )  )
                {
                    pBlood.pev.skin = 1;
                }
                else if( cast<CBaseMonster@>(pEntity).m_bloodColor == ( BLOOD_COLOR_YELLOW )  )
                {
                    pBlood.pev.skin = 2;
                }

                pBlood.SetOrigin( cast<CBaseMonster@>(pEntity).Center() + Vector( 0, 0, 6 ) );

                @pBlood.pev.owner = cast<CBaseMonster@>(pEntity).edict();

                UTILS::SetFloatCKV( cast<CBaseMonster@>(pEntity), "$f_bloodpuddle", 1 );
            }
        }
    }

    class env_bloodpuddle : ScriptBaseAnimating
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
}// end namespace