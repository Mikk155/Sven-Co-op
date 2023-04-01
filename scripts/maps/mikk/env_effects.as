#include "utils"
namespace env_effects
{
	bool Register0 = g_Util.CustomEntity( 'env_effects::env_effect_smoke','env_effect_smoke' );
	bool Register1 = g_Util.CustomEntity( 'env_effects::env_effect_cylinder','env_effect_cylinder' );
	bool Register2 = g_Util.CustomEntity( 'env_effects::env_effect_implosion','env_effect_implosion' );
	bool Register3 = g_Util.CustomEntity( 'env_effects::env_effect_quake','env_effect_quake' );
	bool Register4 = g_Util.CustomEntity( 'env_effects::env_effect_spriteshooter','env_effect_spriteshooter' );
	bool Register5 = g_Util.CustomEntity( 'env_effects::env_effect_tracer','env_effect_tracer' );
	bool Register6 = g_Util.CustomEntity( 'env_effects::env_effect_splash','env_effect_splash' );
	bool Register7 = g_Util.CustomEntity( 'env_effects::env_effect_disk','env_effect_disk' );
	bool Register8 = g_Util.CustomEntity( 'env_effects::env_effect_toxic','env_effect_toxic' );
	bool Register9 = g_Util.CustomEntity( 'env_effects::env_effect_elight','env_effect_elight' );
	bool Register10 = g_Util.CustomEntity( 'env_effects::env_effect_dlight','env_effect_dlight' );
    class env_effect_smoke:ScriptBaseEntity,BaseFX{}
    class env_effect_cylinder:ScriptBaseEntity,BaseFX{}
    class env_effect_implosion:ScriptBaseEntity,BaseFX{}
    class env_effect_quake:ScriptBaseEntity,BaseFX{}
    class env_effect_spriteshooter:ScriptBaseEntity,BaseFX{}
    class env_effect_tracer:ScriptBaseEntity,BaseFX{}
    class env_effect_splash:ScriptBaseEntity,BaseFX{}
    class env_effect_disk:ScriptBaseEntity,BaseFX{}
    class env_effect_toxic:ScriptBaseEntity,BaseFX{}
    class env_effect_elight:ScriptBaseEntity,BaseFX{}
    class env_effect_dlight:ScriptBaseEntity,BaseFX{}

    mixin class BaseFX
    {
        private string m_iszMaster();

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            if ( szKey == "master" )
            {
                this.m_iszMaster = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Precache()
        {
            if( !string( self.pev.model ).IsEmpty() )
            {
                g_Game.PrecacheModel( string( self.pev.model ) );
                g_Game.PrecacheGeneric( string( self.pev.model ) );
            }
            BaseClass.Precache();
        }

        void Spawn()
        {
            pev.solid = SOLID_NOT;
            self.pev.flags |= FL_CUSTOMENTITY;
            g_EntityFuncs.SetOrigin( self, self.pev.origin );
        }

        void Use(CBaseEntity@ a, CBaseEntity@ c, USE_TYPE u, float d)
        {
            if( !m_iszMaster.IsEmpty() and !g_EntityFuncs.IsMasterTriggered( m_iszMaster, self ) )
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
            }
            
            if( !self.pev.SpawnFlagBitSet( 1 ) )
            {
                g_EntityFuncs.Remove( self );
            }
        }
    }
}
// End of namespace