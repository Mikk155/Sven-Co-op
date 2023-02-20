#include "utils"
namespace env_bloodpuddle
{
    string DefaultModel = "models/mikk/misc/bloodpuddle.mdl";
    bool RemoveBlood;

    void Register( const bool& in blRemove = false, const string& in szModel = "models/mikk/misc/bloodpuddle.mdl" )
    {
		g_Game.PrecacheModel( szModel );

        // If both map and server is using this. prevent one of them executing this function.
        if( g_CustomEntityFuncs.IsCustomEntity( "env_bloodpuddle" ) )
            return;

        g_Util.ScriptAuthor.insertLast
        (
            "Script: env_bloodpuddle\n"
            "Author: Gaftherman\n"
            "Github: github.com/Gaftherman\n"
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Generates a blood puddle when a monster die.\n"
        );

        RemoveBlood = blRemove;
        if( szModel != "models/mikk/misc/bloodpuddle.mdl" ) DefaultModel = szModel;

        g_Scheduler.SetInterval( "Think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );

        g_CustomEntityFuncs.RegisterCustomEntity( "env_bloodpuddle::entity", "env_bloodpuddle" );
    }

    void Think()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);

            // Add custom keyvalue "$f_bloodpuddle" "1" to monsters for prevent them from generating bloodpuddles.
            if( pMonster.IsMonster()
            && pMonster.pev.deadflag == DEAD_DEAD
            && pMonster.m_bloodColor != ( DONT_BLEED )
            && pMonster.GetCustomKeyvalues().GetKeyvalue( "$f_bloodpuddle" ).GetFloat() <= 0.0 )
            {
                CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "env_bloodpuddle", null, true);
                
                if( pBlood !is null )
                {
                    if( pEntity.GetCustomKeyvalues().HasKeyvalue( "$i_bloodpuddle" ) )
                    {
						pBlood.pev.skin = pMonster.GetCustomKeyvalues().GetKeyvalue( "$i_bloodpuddle" ).GetInteger();
                    }
                    else
                    {
                        if( pMonster.m_bloodColor == ( BLOOD_COLOR_RED )  )
                        {
                            pBlood.pev.skin = 0;
                        }
                        else
                        if( pMonster.m_bloodColor == ( BLOOD_COLOR_GREEN )
                        or pMonster.m_bloodColor == ( BLOOD_COLOR_YELLOW ) )
                        {
                            pBlood.pev.skin = 1;
                        }
                    }

                    pBlood.SetOrigin( cast<CBaseMonster@>(pEntity).Center() + Vector( 0, 0, 6 ) );

                    @pBlood.pev.owner = pMonster.edict();
                    pMonster.GetCustomKeyvalues().SetKeyvalue( "$f_bloodpuddle", 1 );
                }
            }
        }
    }

    class entity : ScriptBaseAnimating
    {
        void Spawn()
        {
            self.pev.movetype = MOVETYPE_NONE;
            self.pev.solid = SOLID_NOT;
            self.pev.scale = Math.RandomFloat( 1.5, 2.5 );

            g_EntityFuncs.SetModel(self, DefaultModel );
            g_EntityFuncs.SetOrigin(self, self.pev.origin);
            self.pev.sequence = 2;

            SetThink( ThinkFunction( this.BloodPreSpawn ) );
            self.pev.nextthink = g_Engine.time + 0.8f;
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

            if( pOwner !is null
            && self != pOwner
            && pOwner.IsMonster()
            && pOwner.pev.deadflag == DEAD_DEAD )
            {
                self.pev.origin = pOwner.pev.origin;
            }
            else if( RemoveBlood )
            {
                g_EntityFuncs.Remove( self );
            }
            else if( pOwner !is null )
            {
                pOwner.GetCustomKeyvalues().SetKeyvalue( "$f_bloodpuddle", 0 );
                @self.pev.owner = null;
                SetThink( null );
            }

            self.StudioFrameAdvance();
            self.pev.nextthink = g_Engine.time + 0.1;
        }
    }
}
// End of namespace