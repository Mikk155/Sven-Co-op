#include "utils"
#include 'utils/customentity'
#include 'utils/effects'

namespace env_effects
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_cylinder' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_disk' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_dlight' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_implosion' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_quake' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_smoke' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_splash' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_spritefield' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_spriteshooter' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_toxic' );
        g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CBaseFXTemporaryEntities','env_effect_tracer' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_effects' ) +
            g_ScriptInfo.Description( 'Exposes temporary effects for mappers usage' ) +
            g_ScriptInfo.Wiki( 'env_effects' ) +
            g_ScriptInfo.Author( 'wootguy' ) +
            g_ScriptInfo.GetGithub('wootguy') +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    enum env_effects_spawnflags
    {
        REUSABLE = 1
    }

    class CBaseFXTemporaryEntities : ScriptBaseEntity, ScriptBaseCustomEntity
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
            if( !IsLockedByMaster() )
            {
                string iszClass = string( self.pev.classname );
                string iszModel = string( self.pev.model );

                if( iszClass == "env_effect_smoke" )
                {
                    g_Effect.smoke( self.pev.origin, iszModel, int( self.pev.health ), int( self.pev.max_health ) );
                }
                else if( iszClass == "env_effect_cylinder" )
                {
                    g_Effect.cylinder( self.pev.origin, iszModel, int8( self.pev.frags ), int( self.pev.max_health ), self.pev.rendercolor, int( self.pev.renderamt ), atoui( self.pev.target ), atoui( self.pev.netname ), atoui( self.pev.message ), int8( self.pev.health ) );
                }
                else if( iszClass == "env_effect_implosion" )
                {
                    g_Effect.implosion( self.pev.origin, atoui( self.pev.netname ), atoui( self.pev.message ), atoui( self.pev.target ) );
                }
                else if( iszClass == "env_effect_quake" )
                {
                    g_Effect.quake( self.pev.origin, int( self.pev.health ) );
                }
                else if( iszClass == "env_effect_spriteshooter" )
                {
                    g_Effect.spriteshooter( self.pev.origin, iszModel, int( self.pev.health ), int( self.pev.max_health ), atoi( self.pev.netname ), atoi( self.pev.target ) );
                }
                else if( iszClass == "env_effect_tracer" )
                {
                    g_Effect.tracer( self.pev.origin, self.pev.angles, uint( self.pev.health ), uint( self.pev.max_health ), uint( self.pev.frags ) );
                }
                else if( iszClass == "env_effect_splash" )
                {
                    g_Effect.splash( self.pev.origin, self.pev.angles, uint( self.pev.frags ), uint( self.pev.health ), uint( self.pev.max_health ), atoui( self.pev.netname ) );
                }
                else if( iszClass == "env_effect_disk" )
                {
                    g_Effect.disk( self.pev.origin, iszModel, int( self.pev.max_health ), self.pev.rendercolor, int( self.pev.renderamt ), atoui( self.pev.netname ), atoui( self.pev.message ) );
                }
                else if( iszClass == "env_effect_toxic" )
                {
                    g_Effect.toxic( self.pev.origin );
                }
                else if( iszClass == "env_effect_dlight" )
                {
                    g_Effect.dlight( self.pev.origin, self.pev.rendercolor, uint8( self.pev.renderamt ), uint8( self.pev.health ), uint8( self.pev.frags ) );
                }
                else if( iszClass == "env_effect_spritefield" )
                {
                    g_Effect.spritefield( self.pev.origin, iszModel, uint16( self.pev.renderamt ), uint8( self.pev.frags ), uint8( self.pev.health), uint8( self.pev.max_health ) );
                }

                if( !spawnflag( REUSABLE ) )
                {
                    g_EntityFuncs.Remove( self );
                }
            }
        }
    }
}