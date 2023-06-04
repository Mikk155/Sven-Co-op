#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace item_oxygentank
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "item_oxygentank::item_oxygentank", "item_oxygentank" );
        g_CustomEntityFuncs.RegisterCustomEntity( "item_oxygentank::env_oxygenbubble", "env_oxygenbubble" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'item_oxygentank' ) +
            g_ScriptInfo.Description( 'Give oxigen to the players' ) +
            g_ScriptInfo.Wiki( 'item_oxygentank' ) +
            g_ScriptInfo.Author( 'CubeMath' ) +
            g_ScriptInfo.GetGithub( 'CubeMath' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class item_oxygentank : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string sprite = "sprites/bubble.spr";
        private string splashsound = "debris/bustflesh1.wav";
        private Vector m_vVelocity = Vector( 128.0f, 128.0f, 128.0f );

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);

            if( szKey == "sprite" )
            {
                sprite = szValue;
            }
            else if( szKey == "splashsound" )
            {
                splashsound = szValue;
            }
            else if( szKey == "m_vVelocity" )
            {
                m_vVelocity = g_Util.atov( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }
        void Precache() 
        {
            BaseClass.Precache();
            g_Game.PrecacheModel( sprite );
            CustomModelPrecache('models/w_oxygen.mdl');
            g_Game.PrecacheGeneric( 'sound/' + splashsound );
            g_SoundSystem.PrecacheSound( splashsound );
            g_Game.PrecacheOther( 'env_oxygenbubble' );
        }
        
        void Spawn()
        {
            Precache();
            self.pev.movetype = self.pev.movetype;
            self.pev.solid = SOLID_TRIGGER;
            CustomModelSet('models/w_oxygen.mdl');

            if( minhullsize == g_vecZero )
                minhullsize = Vector(-32,-32,-32);
            if( maxhullsize == g_vecZero )
                maxhullsize = Vector(32,32,32);

            if( SetBoundaries() )

            SetThink( ThinkFunction( this.letsRespawn ) );
        }
        
        void letsRespawn() 
        {
            self.pev.renderamt = 255;
            self.pev.solid = SOLID_TRIGGER;
        }
        
        void Touch( CBaseEntity@ pOther ) 
        {
            if( IsLockedByMaster()
            or self.pev.health > 0.0 
            or pOther is null 
            or !pOther.IsPlayer() 
            or spawnflag( 2 ) && pOther.pev.button & 32 == 0
            or spawnflag( 1 ) && g_Util.CKV( pOther, '$i_item_oxygentank_' + self.entindex() ) != '' )
            {
                return;
            }

            g_SoundSystem.EmitSoundDyn( pOther.edict(), CHAN_ITEM, splashsound, 1.0, ATTN_NORM, 0, PITCH_HIGH );
            
            pOther.pev.air_finished = g_Engine.time + 12.0;
            self.pev.solid = SOLID_NOT;
            self.pev.renderamt = 50;
            self.pev.nextthink = ( m_fDelay < 0.1 ) ? g_Engine.time + 1.0f : g_Engine.time + m_fDelay;
            
            for(int i = 0; i < 20; ++i)
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create("env_oxygenbubble", self.pev.origin+Vector( 0, 0, 50 ), Vector(0, 0, 0), false);
                g_EntityFuncs.SetModel( pEnt, sprite );
                pEnt.pev.scale = self.pev.scale;
                pEnt.pev.velocity.x = Math.RandomFloat(-m_vVelocity.x, m_vVelocity.x);
                pEnt.pev.velocity.y = Math.RandomFloat(-m_vVelocity.y, m_vVelocity.y);
                pEnt.pev.velocity.z = Math.RandomFloat(-m_vVelocity.z, m_vVelocity.z);
            }
            g_Util.Trigger( self.pev.target, pOther, self, USE_TOGGLE, 0.0f );
            g_Util.CKV( pOther, '$i_item_oxygentank_' + self.entindex(), 1 );
        }
    }

    class env_oxygenbubble : ScriptBaseEntity
    {
        private float lifeTime;

        void Spawn()
        {
            self.pev.movetype         = MOVETYPE_FLY;
            self.pev.solid             = SOLID_TRIGGER;
            self.pev.rendermode        = 2;
            self.pev.renderamt        = 255;
            
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
            g_EntityFuncs.SetSize( self.pev, Vector(-8, -8, -8), Vector(8, 8, 8) );
            
            lifeTime = g_Engine.time + 1.0f;
            SetThink( ThinkFunction( this.ownThink ) );
            self.pev.nextthink = g_Engine.time + 0.05f;
        }
        
        void ownThink()
        {
            if( lifeTime < g_Engine.time + 1.0f )
            {
                if(lifeTime < g_Engine.time)
                {
                    g_EntityFuncs.Remove( self );
                }
                self.pev.renderamt = ( lifeTime - g_Engine.time ) * 255.0f;
            }
            self.pev.nextthink = g_Engine.time + 0.01f;
        }
    }
}