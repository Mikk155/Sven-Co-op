// -TODO
/*
    - splashj sounds when walk in + depend the range of the bloodpuddle
    - alternatively use sprite
    - start frame
    - sequence velocity
    - hullsizes (splash sound) dependiente de el modelo + la escala
    - Offset origin del owner para que caiga al suelo
*/
#include "utils"
#include "utils/customentity"

CENVBLOODPUDDLE g_Blood;
final class CENVBLOODPUDDLE
{
    string GetKeyz( string iszKey, CBaseEntity@ pEntity )
    {
        string iszValue = g_Util.GetCKV( pEntity, iszKey );

        if( iszValue.IsEmpty() )
        {
            if( iszKey == '$s_blood_model' )
                return "models/mikk/misc/bloodpuddle.mdl";
            if( iszKey == '$i_blood_movetype' )
                return "0";
            if( iszKey == '$f_blood_minscale' )
                return "1.5";
            if( iszKey == '$f_blood_maxscale' )
                return "2.5";
            if( iszKey == '$i_blood_skin' )
                return "";
            if( iszKey == '$v_blood_minbbox' )
                return "-17 -17 -17";
            if( iszKey == '$v_blood_maxbbox' )
                return "17 17 17";
            if( iszKey == '$i_blood_sequence' )
                return "";
        }

        return iszValue;
    }

    bool IsMonsterAllowed( CBaseMonster@ pMonster )
    {
        if( pMonster.IsMonster()
        and pMonster.pev.deadflag == DEAD_DEAD
        and pMonster.m_bloodColor != ( DONT_BLEED )
        and atoi( g_Util.GetCKV( pMonster, '$i_bloodpuddle' ) ) < 1
        and pMonster.GetClassname().Find( 'dead' ) == String::INVALID_INDEX )
        {
            return true;
        }
        return false;
    }

    dictionary Dictionary( CBaseMonster@ pMonster )
    {
        dictionary g_Keys;
        g_Keys[ '$s_blood_model' ] = g_Blood.GetKeyz( '$s_blood_model', pMonster );
        g_Keys[ '$i_blood_movetype' ] = g_Blood.GetKeyz( '$i_blood_movetype', pMonster );
        g_Keys[ '$f_blood_minscale' ] = g_Blood.GetKeyz( '$f_blood_minscale', pMonster );
        g_Keys[ '$f_blood_maxscale' ] = g_Blood.GetKeyz( '$f_blood_maxscale', pMonster );
        g_Keys[ '$i_blood_skin' ] = g_Blood.GetKeyz( '$i_blood_skin', pMonster );
        g_Keys[ '$v_blood_minbbox' ] = g_Blood.GetKeyz( '$v_blood_minbbox', pMonster );
        g_Keys[ '$v_blood_maxbbox' ] = g_Blood.GetKeyz( '$v_blood_maxbbox', pMonster );
        g_Keys[ '$i_blood_fadeout' ] = g_Blood.GetKeyz( '$i_blood_fadeout', pMonster );
        g_Keys[ '$i_owner' ] = '1';
        return g_Keys;
    }
}

namespace env_bloodpuddle
{
    void Register()
    {
        g_Game.PrecacheModel( "models/mikk/misc/bloodpuddle.mdl" );
        g_Game.PrecacheGeneric( "models/mikk/misc/bloodpuddle.mdl" );

        if( !g_CustomEntityFuncs.IsCustomEntity( 'env_bloodpuddle' ) )
        {
            g_Scheduler.SetInterval( "env_bloodpuddle_think", 0.5f, g_Scheduler.REPEAT_INFINITE_TIMES );
            g_CustomEntityFuncs.RegisterCustomEntity( 'env_bloodpuddle::env_bloodpuddle','env_bloodpuddle' );
        }

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_bloodpuddle' ) +
            g_ScriptInfo.Description( 'Blood Puddle Effect' ) +
            g_ScriptInfo.Wiki( 'env_bloodpuddle' ) +
            g_ScriptInfo.Author( 'Gaftherman' ) +
            g_ScriptInfo.GetGithub('Gaftherman') +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class env_bloodpuddle : ScriptBaseAnimating, ScriptBaseCustomEntity
    {
        private bool m_blstepin;

        void Precache()
        {
            CustomModelPrecache( g_Blood.GetKeyz( '$s_blood_model', self ) );
        }

        void Spawn()
        {
            Precache();

            CustomModelSet( g_Blood.GetKeyz( '$s_blood_model', self ) );

            g_EntityFuncs.SetSize( self.pev, g_Util.StringToVec( g_Blood.GetKeyz( '$v_blood_minbbox', self ) ), g_Util.StringToVec( g_Blood.GetKeyz( '$v_blood_maxbbox', self ) ) );
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            self.pev.solid = SOLID_TRIGGER;
            self.pev.movetype = ( atoi( g_Blood.GetKeyz( '$i_blood_movetype', self ) ) == 0 ? MOVETYPE_NONE : MOVETYPE_TOSS );
            self.pev.scale = Math.RandomFloat( atof( g_Blood.GetKeyz( '$f_blood_minscale', self ) ), atof( g_Blood.GetKeyz( '$f_blood_maxscale', self ) ) );

            if( !g_Blood.GetKeyz( '$i_blood_skin', self ).IsEmpty() )
                self.pev.skin = atoi( g_Blood.GetKeyz( '$i_blood_skin', self ) );

            if( g_Blood.GetKeyz( '$i_blood_sequence', self ).IsEmpty() ) self.pev.sequence = 2;
            else self.pev.sequence = atoi( g_Blood.GetKeyz( '$i_blood_sequence', self ) );

            g_Scheduler.SetTimeout( this, "BloodPreThink", 0.8f );
        }
        
        void Touch( CBaseEntity@ pOther )
        {
            if( pOther !is null && pOther.IsPlayer() && pOther.IsAlive() && !m_blstepin )
            {
            }
        }

        void BloodPreThink()
        {
            if( g_EntityFuncs.Instance( self.pev.owner ) !is null )
            {
                self.pev.sequence = 1;
            }
            self.pev.frame = 0;
            self.ResetSequenceInfo();
            self.pev.framerate = Math.RandomFloat( 0.3, 0.6 );
            SetThink( ThinkFunction( this.BloodThink ) );
            self.pev.nextthink = g_Engine.time + 0.2f;
        }

        void BloodThink()
        {
            self.StudioFrameAdvance();

            CBaseEntity@ pOwner = g_EntityFuncs.Instance( self.pev.owner );

            if( pOwner !is null && pOwner != self )
            {
                self.pev.origin = pOwner.pev.origin;
            }
            else if( atoi( g_Blood.GetKeyz( '$i_owner', self ) ) == 0 )
            {
                g_Util.Debug( 'Think self' );
            }
            else if( atoi( g_Blood.GetKeyz( '$i_blood_fadeout', self ) ) == 1 )
            {
                self.pev.renderamt = 255;
                SetThink( ThinkFunction( this.FadeoutBlood ) );
                self.pev.nextthink = g_Engine.time + 0.2f;
                return;
            }
            else
            {
                self.pev.sequence = 0;
                return;
            }
            self.pev.nextthink = g_Engine.time + 0.2f;
        }
        
        void FadeoutBlood()
        {
            if( self.pev.renderamt > 10 )
            {
                self.pev.rendermode = kRenderTransTexture;
                self.pev.renderamt -= 1;
            }
            else
            {
                g_EntityFuncs.Remove( self );
                return;
            }
            self.pev.nextthink = g_Engine.time + 0.2f;
        }
    }

    void env_bloodpuddle_think()
    {
        CBaseEntity@ pEntity = null;

        while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, "monster_*" ) ) !is null )
        {
            CBaseMonster@ pMonster = cast<CBaseMonster@>(pEntity);

            if( g_Blood.IsMonsterAllowed( pMonster ) )
            {
                CBaseEntity@ pBlood = g_EntityFuncs.CreateEntity( "env_bloodpuddle", g_Blood.Dictionary( pMonster ), true );

                if( pBlood !is null )
                {
                    if( !g_Blood.GetKeyz( '$i_blood_skin', pMonster ).IsEmpty() )
                    {
                        pBlood.pev.skin = atoi( g_Blood.GetKeyz( '$i_blood_skin', pMonster ) );
                    }
                    else if( pMonster.m_bloodColor == ( BLOOD_COLOR_RED ) )
                    {
                        pBlood.pev.skin = 0;
                    }
                    else
                    {
                        pBlood.pev.skin = 1;
                    }
                    @pBlood.pev.owner = pMonster.edict();
                    pBlood.SetOrigin( cast<CBaseMonster@>( pEntity ).Center() );
                    g_Util.SetCKV( pMonster, '$i_bloodpuddle', '1' );
                }
            }
        }
    }
}