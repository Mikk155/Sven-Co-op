/*
    Original script by Cubemath: https://github.com/CubeMath/UCHFastDL2/blob/master/svencoop/scripts/maps/cubemath/item_airbubble.as

DOWNLOAD:

scripts/maps/mikk/item_oxygentank.as
scripts/maps/mikk/utils.as


INSTALL:

#include "mikk/item_oxygentank"

void MapInit()
{
    item_oxygentank::Register();
}

*/

#include "utils"

namespace item_oxygentank
{
    enum item_oxygentank_flags
    {
        SF_OGT_USABLE_ONCE = 1 << 0,
        SF_OGT_USEONLY_KEY = 1 << 1
    }

    class item_oxygentank : ScriptBaseEntity, UTILS::MoreKeyValues
    {
        private string sprite = "sprites/bubble.spr";
        private string splashsound = "debris/bustflesh1.wav";
        private float x_velocity = 128.0f, y_velocity = 128.0f, z_velocity = 128.0f;

        bool KeyValue( const string& in szKey, const string& in szValue ) 
        {
            ExtraKeyValues(szKey, szValue);
            if( szKey == "sprite" ) sprite = szValue;
            else if( szKey == "splashsound" ) splashsound = szValue;
            else if( szKey == "x_velocity" ) x_velocity = atof( szValue );
            else if( szKey == "y_velocity" ) y_velocity = atof( szValue );
            else if( szKey == "z_velocity" ) z_velocity = atof( szValue );
            else return BaseClass.KeyValue( szKey, szValue );
            return true;
        }
        void Precache() 
        {
            BaseClass.Precache();
            g_Game.PrecacheModel( sprite );
            g_Game.PrecacheModel( ( string( self.pev.model ).IsEmpty() ) ? "models/w_oxygen.mdl" : string( self.pev.model ) );
            g_Game.PrecacheGeneric( 'sound/' + splashsound );
            g_SoundSystem.PrecacheSound( splashsound );
        }
        
        void Spawn()
        {
            Precache();
            self.pev.movetype = self.pev.movetype;
            self.pev.solid = SOLID_TRIGGER;

            g_EntityFuncs.SetModel( self, ( string( self.pev.model ).IsEmpty() ) ? "models/w_oxygen.mdl" : string( self.pev.model ) );

            origin_to_world = 1;

            if( minhullsize == g_vecZero )
                minhullsize = Vector(-32,-32,-32);
            if( maxhullsize == g_vecZero )
                maxhullsize = Vector(32,32,32);

            SetBoundaries();

            SetThink( ThinkFunction( this.letsRespawn ) );
        }
        
        void letsRespawn() 
        {
            self.pev.renderamt = 255;
            self.pev.solid = SOLID_TRIGGER;
        }
        
        void Touch( CBaseEntity@ pOther ) 
        {
            if( master()
            or self.pev.health > 0.0 
            or pOther is null 
            or !pOther.IsPlayer() 
            or self.pev.SpawnFlagBitSet( SF_OGT_USEONLY_KEY ) && pOther.pev.button & 32 == 0
            or self.pev.SpawnFlagBitSet( SF_OGT_USABLE_ONCE ) && pOther.GetCustomKeyvalues().HasKeyvalue( "$i_item_oxygentank_" + self.entindex() ) )
                return;

            g_SoundSystem.EmitSoundDyn( pOther.edict(), CHAN_ITEM, splashsound, 1.0, ATTN_NORM, 0, PITCH_HIGH );
            
            pOther.pev.air_finished = g_Engine.time + 12.0;
            self.pev.solid = SOLID_NOT;
            self.pev.renderamt = 50;
            self.pev.nextthink = ( delay < 0.1 ) ? g_Engine.time + 1.0f : g_Engine.time + delay;
            
            for(int i = 0; i < 20; ++i)
            {
                CBaseEntity@ pEnt = g_EntityFuncs.Create("env_oxygenbubble", self.pev.origin+Vector( 0, 0, 50 ), Vector(0, 0, 0), false);
                g_EntityFuncs.SetModel( pEnt, sprite );
                pEnt.pev.scale = self.pev.scale;
                pEnt.pev.velocity.x = Math.RandomFloat(-x_velocity, x_velocity);
                pEnt.pev.velocity.y = Math.RandomFloat(-y_velocity, y_velocity);
                pEnt.pev.velocity.z = Math.RandomFloat(-z_velocity, z_velocity);
            }
            UTILS::Trigger( self.pev.target, pOther, self, USE_TOGGLE, 0.0f );
            pOther.GetCustomKeyvalues().SetKeyvalue( "$i_item_oxygentank_" + self.entindex(), 1 );
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

    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "item_oxygentank::item_oxygentank", "item_oxygentank" );
        g_CustomEntityFuncs.RegisterCustomEntity( "item_oxygentank::env_oxygenbubble", "env_oxygenbubble" );
        g_Game.PrecacheOther( "env_oxygenbubble" );
    }
}// end namespace