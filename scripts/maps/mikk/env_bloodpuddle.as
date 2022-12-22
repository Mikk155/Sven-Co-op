/*
DOWNLOAD:

https://github.com/Mikk155/Sven-Co-op/releases/download/env_bloodpuddle/models.rar

models/mikk/misc/bloodpuddle.mdl
scripts/maps/mikk/env_bloodpuddle.as


INSTALL:

#include "mikk/env_bloodpuddle"

void MapInit()
{
    env_bloodpuddle::Register();
}

OR:
as a plugin. see scripts/maps/mikk/plugins/BloodPuddle.as
*/

namespace env_bloodpuddle
{
    void Register()
    {
        // If both map and server is using this. prevent one of them executing this function.
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
            // Add custom keyvalue "$f_bloodpuddle_disable" to monsters for prevent them from generating bloodpuddles.
            if( pEntity.GetCustomKeyvalues().HasKeyvalue( "$f_bloodpuddle_disable" ) )
            {
                continue;
            }

            if( pEntity !is null && pEntity.IsMonster() && pEntity.pev.deadflag == DEAD_DEAD && cast<CBaseMonster@>(pEntity).GetCustomKeyvalues().GetKeyvalue( "$f_bloodpuddle" ).GetFloat() <= 0.0 )
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
                cast<CBaseMonster@>(pEntity).GetCustomKeyvalues().SetKeyvalue( "$f_bloodpuddle", 1 );
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

            // don't change this. use a gmr file instead.-
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
            else
            {
                g_EntityFuncs.Remove( self );
            }

            self.StudioFrameAdvance();
            self.pev.nextthink = g_Engine.time + 0.1;
        }
    }
}// end namespace