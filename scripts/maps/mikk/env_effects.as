#include "utils"

bool env_effect_cylinder_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_cylinder' );
bool env_effect_disk_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_disk' );
bool env_effect_dlight_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_dlight' );
bool env_effect_implosion_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_implosion' );
bool env_effect_quake_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_quake' );
bool env_effect_smoke_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_smoke' );
bool env_effect_splash_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_splash' );
bool env_effect_spritefield_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_spritefield' );
bool env_effect_spriteshooter_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_spriteshooter' );
bool env_effect_toxic_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_toxic' );
bool env_effect_tracer_register = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_tracer' );

namespace env_effects
{
	enum env_effects_spawnflags
	{
		REUSABLE = 1
	}

    class BaseFX : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Precache()
        {
            CustomModelPrecache();
            BaseClass.Precache();
        }

        void Spawn()
        {
            pev.solid = SOLID_NOT;
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
        }

        void Use(CBaseEntity@ a, CBaseEntity@ c, USE_TYPE u, float d)
        {
            if( IsLockedByMaster() )
            {
                g_Util.Trigger( g_Util.GetCKV( self, '$s_target' ), self, self, USE_TOGGLE, 0.0f );
                return;
            }
            else
            {
                if( self.pev.classname == "env_effect_smoke" )
                {
                    g_Effect.smoke( self.pev.origin, string( self.pev.model ), int( self.pev.health ), int( self.pev.max_health ) );
                }
                else if( self.pev.classname == "env_effect_cylinder" )
                {
                    g_Effect.cylinder( self.pev.origin, string( self.pev.model ), int8( self.pev.frags ), int( self.pev.max_health ), self.pev.rendercolor, int( self.pev.renderamt ), atoui( self.pev.target ), atoui( self.pev.netname ), atoui( self.pev.message ), int8( self.pev.health ) );
                }
                else if( self.pev.classname == "env_effect_implosion" )
                {
                    g_Effect.implosion( self.pev.origin, atoui( self.pev.netname ), atoui( self.pev.message ), atoui( self.pev.target ) );
                }
                else if( self.pev.classname == "env_effect_quake" )
                {
                    g_Effect.quake( self.pev.origin, int( self.pev.health ) );
                }
                else if( self.pev.classname == "env_effect_spriteshooter" )
                {
                    g_Effect.spriteshooter( self.pev.origin, string( self.pev.model ), int( self.pev.health ), int( self.pev.max_health ), atoi( self.pev.netname ), atoi( self.pev.target ) );
                }
                else if( self.pev.classname == "env_effect_tracer" )
                {
                    g_Effect.tracer( self.pev.origin, self.pev.angles, uint( self.pev.health ), uint( self.pev.max_health ), uint( self.pev.frags ) );
                }
                else if( self.pev.classname == "env_effect_splash" )
                {
                    g_Effect.splash( self.pev.origin, self.pev.angles, uint( self.pev.frags ), uint( self.pev.health ), uint( self.pev.max_health ), atoui( self.pev.netname ) );
                }
                else if( self.pev.classname == "env_effect_disk" )
                {
                    g_Effect.disk( self.pev.origin, string( self.pev.model ), int( self.pev.max_health ), self.pev.rendercolor, int( self.pev.renderamt ), atoui( self.pev.netname ), atoui( self.pev.message ) );
                }
                else if( self.pev.classname == "env_effect_toxic" )
                {
                    g_Effect.toxic( self.pev.origin );
                }
                else if( self.pev.classname == "env_effect_dlight" )
                {
                    g_Effect.dlight( self.pev.origin, self.pev.rendercolor, uint8( self.pev.renderamt ), uint8( self.pev.health ), uint8( self.pev.frags ) );
                }
                else if( self.pev.classname == "env_effect_spritefield" )
                {
                    g_Effect.spritefield( self.pev.origin, string( self.pev.model ), uint16( self.pev.renderamt ), uint8( self.pev.frags ), uint8( self.pev.health), uint8( self.pev.max_health ) );
                }
            }
            
            if( !spawnflag( REUSABLE ) )
            {
                g_EntityFuncs.Remove( self );
            }
        }
    }
}