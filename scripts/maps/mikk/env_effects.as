#include "utils"
namespace env_effects
{
	bool blcylinder = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_cylinder' );
	bool bldisk = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_disk' );
	bool bldlight = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_dlight' );
	bool blimplosion = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_implosion' );
	bool blquake = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_quake' );
	bool blsmoke = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_smoke' );
	bool blsplash = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_splash' );
	bool blspritefield = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_spritefield' );
	bool blspriteshooter = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_spriteshooter' );
	bool bltoxic = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_toxic' );
	bool bltracer = g_Util.CustomEntity( 'env_effects::BaseFX','env_effect_tracer' );

	class BaseFX : ScriptBaseEntity
    {
        private string m_iszMaster();

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            if( szKey == "master" )
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
                else if( self.pev.classname == "env_effect_dlight" )
                {
					g_Effect.dlight( self.pev.origin, self.pev.rendercolor, uint8( self.pev.renderamt ), uint8( self.pev.health ), uint8( self.pev.frags ) );
                }
                else if( self.pev.classname == "env_effect_spritefield" )
                {
					g_Effect.spritefield( self.pev.origin, string( self.pev.model ), uint16( self.pev.renderamt ), uint8( self.pev.frags ), uint8( self.pev.health), uint8( self.pev.max_health ) );
                }
            }
            
            if( !self.pev.SpawnFlagBitSet( 1 ) )
            {
                g_EntityFuncs.Remove( self );
            }
        }
    }
}