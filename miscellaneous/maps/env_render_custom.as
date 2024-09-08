#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_render_custom
{
    void Register()
    {
        g_Util.CustomEntity( 'env_render_custom' );
        g_Scheduler.SetTimeout( "env_render_custom_init", 0.0f );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_render_custom' ) +
            g_ScriptInfo.Description( 'Expands env_render entity' ) +
            g_ScriptInfo.Wiki( 'env_render_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    void env_render_custom_init()
    {
        CBaseEntity@ pRender = null;

        while( ( @pRender = g_EntityFuncs.FindEntityByClassname( pRender, "env_render" ) ) !is null )
        {
            if( atoi( g_Util.CKV( pRender, '$i_angelscript' ) ) != 0 )
            {
                dictionary g_Dictionary;
                g_Dictionary [ "targetname" ] = string( pRender.pev.targetname );
                g_Dictionary [ "target" ] = string( pRender.pev.target );
                g_Dictionary [ "renderamt" ] = string( pRender.pev.renderamt );
                g_Dictionary [ "rendermode" ] = string( pRender.pev.rendermode );
                g_Dictionary [ "rendercolor" ] = pRender.pev.rendercolor.ToString();
                g_Dictionary [ "renderfx" ] = string( pRender.pev.renderfx );
                g_Dictionary [ "spawnflags" ] = string( pRender.pev.spawnflags );

                g_Dictionary [ "$s_target" ] = g_Util.CKV( pRender, '$s_target' );
                g_Dictionary [ "$f_gradual" ] = g_Util.CKV( pRender, '$f_gradual' );
                g_Dictionary [ "$i_gradual" ] = g_Util.CKV( pRender, '$i_gradual' );
                g_Dictionary [ "$s_gradual" ] = g_Util.CKV( pRender, '$s_gradual' );
                g_Dictionary [ "master" ] = g_Util.CKV( pRender, '$s_master' );
                g_Dictionary [ "$s_TriggerOnMaster" ] = g_Util.CKV( pRender, '$s_TriggerOnMaster' );
                g_Dictionary [ "m_fDelay" ] = g_Util.CKV( pRender, '$f_fDelay' );
                g_Dictionary [ "m_iUseType" ] = g_Util.CKV( pRender, '$i_iUseType' );

                CBaseEntity@ pNewRender = g_EntityFuncs.CreateEntity( "env_render_custom", g_Dictionary );

                if( pNewRender !is null )
                {
                    g_EntityFuncs.Remove( pRender );
                }
            }
        }
    }
    
    enum env_render_custom_spawnflags
    {
        NO_RENDERFX = 1,
        NO_RENDERAMT = 2,
        NO_RENDERMODE = 4,
        NO_RENDERCOLOR = 8,
        AUTO_APPLY = 16,
        RENDER_GRADUAL = 64
    }

    class env_render_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            m_UTLatest = useType;
            if( !IsLockedByMaster() )
            {
                if( string( self.pev.target ) == '!activator' || string( self.pev.target ).IsEmpty() )
                {
                    if( pActivator !is null )
                    {
                        CRender( pActivator, useType );
                    }
                }
                else if( string( self.pev.target ) == '!caller' && pCaller !is null )
                {
                    CRender( pCaller, useType );
                }
                else
                {
                    CBaseEntity@ pEntity = null;

                    while( ( @pEntity = g_EntityFuncs.FindEntityByTargetname( pEntity, string( self.pev.target ) ) ) !is null )
                    {
                        CRender( pEntity, useType );
                    }
                }
            }
        }

        void CRender( CBaseEntity@ pTarget, USE_TYPE useType = USE_TOGGLE )
        {
            CStore( pTarget );
            
            if( Flag( NO_RENDERCOLOR ) )
            {
                pTarget.pev.rendercolor = ( useType == USE_OFF ) ? g_Util.atov( g_Util.CKV( pTarget, '$v_rendercolor' ) ) : self.pev.rendercolor;
            }
            if( Flag( NO_RENDERMODE ) )
            {
                pTarget.pev.rendermode = ( useType == USE_OFF ) ? atoi( g_Util.CKV( pTarget, '$i_rendermode' ) ) : self.pev.rendermode;
            }
            if( Flag( NO_RENDERFX ) )
            {
                pTarget.pev.renderfx = ( useType == USE_OFF ) ? atoi( g_Util.CKV( pTarget, '$i_renderfx' ) ) : self.pev.renderfx;
            }
            if( Flag( NO_RENDERAMT ) )
            {
                if( Flag( RENDER_GRADUAL ) && useType != USE_OFF )
                {
                    CGradual( pTarget );
                    return;
                }
                pTarget.pev.renderamt = ( useType == USE_OFF ) ? atof( g_Util.CKV( pTarget, '$i_renderamt' ) ) : self.pev.renderamt;
            }
            g_Util.Trigger( g_Util.CKV( self, '$s_target' ), pTarget, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
        }
        
        bool Flag( int iFlagSet )
        {
            if( self.pev.SpawnFlagBitSet( iFlagSet ) )
                return false;
            return true;
        }
        
        void CStore( CBaseEntity@ pTarget )
        {
            if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$i_rendermode' ) )
            {
                g_Util.CKV( pTarget, '$i_rendermode', string( pTarget.pev.rendermode ) );
            }
            if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$v_rendercolor' ) )
            {
                g_Util.CKV( pTarget, '$v_rendercolor', pTarget.pev.rendercolor.ToString() );
            }
            if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$i_renderamt' ) )
            {
                g_Util.CKV( pTarget, '$i_renderamt', string( pTarget.pev.renderamt ) );
            }
            if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$i_renderfx' ) )
            {
                g_Util.CKV( pTarget, '$i_renderfx', string( pTarget.pev.renderfx ) );
            }
        }

        void CGradual( CBaseEntity@ pTarget )
        {
            int Valor = atoi( g_Util.CKV( self, '$i_gradual' ).Replace( '-', '' ).Replace( '+', '' ) );
            int Accion = atoi( g_Util.CKV( self, '$i_gradual' ) );

            if( Accion > 0 )
            {
                pTarget.pev.renderamt += Valor;
            }
            else if( Accion < 0 )
            {
                pTarget.pev.renderamt -= Valor;
            }

            if( pTarget.pev.renderamt < 0 )
            {
                pTarget.pev.renderamt = 0;
            }

            if( Accion < 0 && pTarget.pev.renderamt <= atoi( g_Util.CKV( self, '$s_gradual' ) )
            or Accion > 0 && pTarget.pev.renderamt >= atoi( g_Util.CKV( self, '$s_gradual' ) ) )
            {
                g_Util.Trigger( g_Util.CKV( self, '$s_target' ), pTarget, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
            }
            else
            {
                g_Scheduler.SetTimeout( this, "CGradual", atof( g_Util.CKV( self, '$f_gradual' ) ), @pTarget );
            }
        }
    }
}
