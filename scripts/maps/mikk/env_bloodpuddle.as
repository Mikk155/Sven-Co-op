// -TODO
/*
    - splashj sounds when walk in + depend the range of the bloodpuddle
    - alternatively use sprite
    - start frame
    - sequence velocity
    hullsizes (splash sound) dependiente de el modelo + la escala
*/
#include "utils"

namespace env_bloodpuddle
{
    bool fadeout = false;
    string iszgmodel = "models/mikk/misc/bloodpuddle.mdl";
    void model( string cmodel )
    {
        iszgmodel = cmodel;

        g_Game.PrecacheModel( cmodel );
        g_Game.PrecacheGeneric( cmodel );
    }

    void Register()
    {
        g_Game.PrecacheModel( iszgmodel );
        g_Game.PrecacheGeneric( iszgmodel );

        if( !g_CustomEntityFuncs.IsCustomEntity( 'env_bloodpuddle' ) )
        {
            g_Scheduler.SetInterval( "env_bloodpuddle_think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
        }

        g_CustomEntityFuncs.RegisterCustomEntity( 'env_bloodpuddle::env_bloodpuddle','env_bloodpuddle' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_bloodpuddle' ) +
            g_ScriptInfo.Description( 'Blood Puddle Effect' ) +
            g_ScriptInfo.Wiki( 'env_bloodpuddle' ) +
            g_ScriptInfo.Author( 'Gaftherman' ) +
            g_ScriptInfo.GetGithub('Gaftherman') +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    class env_bloodpuddle : ScriptBaseAnimating
    {
        private float minscale = 1.5, maxscale = 2.5;
        void Spawn()
        {
            Precache();
            self.pev.solid = SOLID_NOT;
            self.pev.movetype = self.pev.movetype;
            self.pev.scale = Math.RandomFloat( minscale, maxscale );

            if( !string( self.pev.model ).IsEmpty() )
            {
                g_EntityFuncs.SetModel( self, string( self.pev.model ) );
            }
            else
            {
                g_EntityFuncs.SetModel( self, iszgmodel );
            }
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            self.pev.sequence = 2;

            SetThink( ThinkFunction( this.BloodPreSpawn ) );
            self.pev.nextthink = g_Engine.time + 0.8f;
        }

        void Precache()
        {
            if( !string( self.pev.model ).IsEmpty() && !string( self.pev.model ).StartsWith( '*' ) )
            {
                g_Game.PrecacheModel( string( self.pev.model ) );
                g_Game.PrecacheGeneric( string( self.pev.model ) );
            }
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
            else if( fadeout )
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

    void env_bloodpuddle_think()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);

            if( pMonster.IsMonster()
            && pMonster.pev.deadflag == DEAD_DEAD
            && string( pMonster.GetClassname() ).Find( 'dead' ) == String::INVALID_INDEX
            && pMonster.m_bloodColor != ( DONT_BLEED )
            && atof( g_Util.GetCKV( pMonster, '$f_bloodpuddle' ) ) <= 0.0 )
            {
                CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "env_bloodpuddle", null, true);
                if( pBlood !is null )
                {
                    if( g_Util.GetCKV( pEntity, '$i_bloodpuddle' ) != '' )
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
}