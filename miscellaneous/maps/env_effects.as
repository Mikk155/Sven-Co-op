#include 'utils/CEffects'
#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_effects
{
    void Register()
    {
        array<string> StrEffect = 
        {
            'env_effect_cylinder',
            'env_effect_disk',
            'env_effect_dlight',
            'env_effect_implosion',
            'env_effect_quake',
            'env_effect_smoke',
            'env_effect_splash',
            'env_effect_spritefield',
            'env_effect_spriteshooter',
            'env_effect_toxic',
            'env_effect_tracer'
        };

        for(uint i = 0; i < StrEffect.length(); i++)
        {
            g_CustomEntityFuncs.RegisterCustomEntity( 'env_effects::CEnvFX', StrEffect[i] );
        }

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_effects' ) +
            g_ScriptInfo.Description( 'Exposes Temporary Entities as a Custom Entities' ) +
            g_ScriptInfo.Wiki( 'CEffects' ) +
            g_ScriptInfo.Author( 'wootguy' ) +
            g_ScriptInfo.GetGithub('wootguy') +
            g_ScriptInfo.Author( 'GeckonCZ' ) +
            g_ScriptInfo.GetGithub('baso88') +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum env_effects_spawnflags
    {
        REUSABLE = 1
    }

    class CEnvFX : ScriptBaseEntity, ScriptBaseCustomEntity
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

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE UseType, float flDelay )
        {
            if( !IsLockedByMaster() )
            {
                string iszClass = string( self.pev.classname );
                string iszModel = string( self.pev.model );
                Vector VecPos;

                if( s_value( 'origin' ) == '!activator' && pActivator !is null )
                {
                    VecPos = pActivator.pev.origin;
                }
                else if( s_value( 'origin' ) == '!caller' && pCaller !is null )
                {
                    VecPos = pCaller.pev.origin;
                }
                else if( !s_value( 'origin' ).IsEmpty() )
                {
                    CBaseEntity@ pFind = g_EntityFuncs.FindEntityByTargetname( pFind, s_value( 'origin' ) );

                    if( pFind !is null )
                    {
                        VecPos = pFind.pev.origin;
                    }
                    else
                    {
                        VecPos = self.pev.origin;
                    }
                }
                else
                {
                    VecPos = self.pev.origin;
                }

                if( iszClass == "env_effect_cylinder" )
                {
                    g_Effect.cylinder
                    (
                        VecPos,
                        iszModel,
                        i8_value( 'radius' ),
                        i_value( 'flag' ),
                        v_value( 'color' ),
                        i8_value( 'amt' ),
                        i8_value( 'scroll' ),
                        i8_value( 'start' ),
                        i8_value( 'frame' ),
                        i8_value( 'time' )
                    );
                }
                else if( iszClass == "env_effect_disk" )
                {
                    g_Effect.disk
                    (
                        VecPos,
                        iszModel,
                        i8_value( 'radius' ),
                        v_value( 'color' ),
                        i8_value( 'amt' ),
                        i8_value( 'start' ),
                        i8_value( 'hold' )
                    );
                }
                else if( iszClass == "env_effect_dlight" )
                {
                    g_Effect.dlight
                    (
                        VecPos,
                        v_value( 'color' ),
                        i8_value( 'radius' ),
                        i8_value( 'life' ),
                        i8_value( 'noise' )
                    );
                }
                else if( iszClass == "env_effect_implosion" )
                {
                    g_Effect.implosion
                    (
                        VecPos,
                        i8_value( 'radius' ),
                        i8_value( 'count' ),
                        i8_value( 'life' )
                    );
                }
                else if( iszClass == "env_effect_quake" )
                {
                    g_Effect.quake
                    (
                        VecPos,
                        i_value( 'flag' )
                    );
                }
                else if( iszClass == "env_effect_smoke" )
                {
                    g_Effect.smoke
                    (
                        VecPos,
                        iszModel,
                        i8_value( 'scale' ),
                        i8_value( 'frame' )
                    );
                }
                else if( iszClass == "env_effect_splash" )
                {
                    g_Effect.splash
                    (
                        VecPos,
                        v_value( 'velocity' ),
                        i8_value( 'color' ),
                        i8_value( 'speed' ),
                        i8_value( 'noise' ),
                        i8_value( 'amt' )
                        );
                }
                else if( iszClass == "env_effect_spritefield" )
                {
                    g_Effect.spritefield
                    (
                        VecPos,
                        iszModel,
                        i8_value( 'radius' ),
                        i8_value( 'count' ),
                        i8_value( 'life' ),
                        i8_value( 'flags' )
                    );
                }
                else if( iszClass == "env_effect_spriteshooter" )
                {
                    g_Effect.spriteshooter
                    (
                        VecPos,
                        iszModel,
                        i_value( 'count' ),
                        i_value( 'life' ),
                        i_value( 'scale' ),
                        i_value( 'noise' )
                    );
                }
                else if( iszClass == "env_effect_toxic" )
                {
                    g_Effect.toxic
                    (
                        VecPos
                    );
                }
                else if( iszClass == "env_effect_tracer" )
                {
                    g_Effect.tracer
                    (
                        VecPos,
                        v_value( 'velocity' ),
                        i_value( 'hold' ),
                        i_value( 'length' ),
                        i_value( 'color' )
                    );
                }

                if( !spawnflag( REUSABLE ) )
                {
                    g_EntityFuncs.Remove( self );
                }
            }
        }

        string s_value( string iszString )
        {
            return g_Util.CKV( self, '$s_fx_' + iszString );
        }

        Vector v_value( string iszString )
        {
            return g_Util.atov( g_Util.CKV( self, '$s_fx_' + iszString ) );
        }

        int i_value( string iszString )
        {
            return atoi( s_value( iszString ) );
        }

        int i8_value( string iszString )
        {
            return uint8( i_value( iszString ) );
        }
    }
}
