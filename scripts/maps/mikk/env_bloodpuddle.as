#include "utils"
namespace env_bloodpuddle
{
	bool Register = g_Util.CustomEntity( 'env_bloodpuddle::env_bloodpuddle','env_bloodpuddle' );
    CScheduledFunction@ g_Think = g_Scheduler.SetInterval( "Think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
	string AutoPrecache = PrecacheModel();

    string BloodModel = 'models/mikk/misc/bloodpuddle.mdl';
	
	void model( const string& in szModel = BloodModel )
	{
		BloodModel = szModel;
		PrecacheModel();
	}
	
	string PrecacheModel( const string& in szModel = BloodModel )
	{
        g_Game.PrecacheModel( szModel );
        g_Game.PrecacheGeneric( szModel );
		return szModel;
	}

    bool fade = false;

    void Think()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);

            if( pMonster.IsMonster()
            && pMonster.pev.deadflag == DEAD_DEAD
            && pMonster.m_bloodColor != ( DONT_BLEED )
            && atof( g_Util.GetCKV( pMonster, '$f_bloodpuddle' ) ) <= 0.0 )
            {
                CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "env_bloodpuddle", null, true);

                if( pBlood !is null )
                {
                    if( pEntity.GetCustomKeyvalues().HasKeyvalue( "$i_bloodpuddle" ) )
                    {
                        pBlood.pev.skin = atoi( g_Util.GetCKV( pMonster, '$i_bloodpuddle' ) );
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
                    g_Util.SetCKV( pMonster, '$f_bloodpuddle', '1' );
                }
            }
        }
    }

    class env_bloodpuddle : ScriptBaseAnimating
    {
        void Spawn()
        {
            self.pev.movetype = MOVETYPE_NONE;
            self.pev.solid = SOLID_NOT;
            self.pev.scale = Math.RandomFloat( 1.5, 2.5 );

            g_EntityFuncs.SetModel( self, BloodModel );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
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
            else if( fade )
            {
                g_EntityFuncs.Remove( self );
            }
            else if( pOwner !is null )
            {
                g_Util.SetCKV( pOwner, '$f_bloodpuddle', '0' );
                @self.pev.owner = null;
                SetThink( null );
            }

            self.StudioFrameAdvance();
            self.pev.nextthink = g_Engine.time + 0.1;
        }
    }
}
// End of namespace