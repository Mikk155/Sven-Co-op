#include "utils"
namespace env_render
{
    CScheduledFunction@ g_Renders = g_Scheduler.SetTimeout( "FindEnvRenders", 0.0f );

    void FindEnvRenders()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "env_render::entity", "env_render_custom" );

        CBaseEntity@ pRender = null;

        while( ( @pRender = g_EntityFuncs.FindEntityByClassname( pRender, "env_render" ) ) !is null )
        {
            if( pRender !is null && atoi( g_Util.GetCKV( pRender, '$i_angelscript' ) ) != 0 )
            {
				dictionary g_Dictionary;
				g_Dictionary [ "targetname" ] = string( pRender.pev.targetname );
				g_Dictionary [ "target" ] = string( pRender.pev.target );
				g_Dictionary [ "renderamt" ] = string( pRender.pev.renderamt );
				g_Dictionary [ "rendermode" ] = string( pRender.pev.rendermode );
				g_Dictionary [ "rendercolor" ] = pRender.pev.rendercolor.ToString();
				g_Dictionary [ "renderfx" ] = string( pRender.pev.renderfx );
				g_Dictionary [ "spawnflags" ] = string( pRender.pev.spawnflags );

				g_Dictionary [ "$s_target" ] = g_Util.GetCKV( pRender, '$s_target' );
				g_Dictionary [ "$f_gradual" ] = g_Util.GetCKV( pRender, '$f_gradual' );
				g_Dictionary [ "$i_gradual" ] = g_Util.GetCKV( pRender, '$i_gradual' );
				g_Dictionary [ "$s_gradual" ] = g_Util.GetCKV( pRender, '$s_gradual' );

                CBaseEntity@ pNewRender = g_EntityFuncs.CreateEntity( "env_render_custom", g_Dictionary );

				if( pNewRender !is null )
				{
					g_EntityFuncs.Remove( pRender );
				}
            }
        }

        g_Util.ScriptAuthor.insertLast
        (
            "Author: Mikk\n"
            "Github: github.com/Mikk155\n"
            "Description: Expands env_render functions.\n"
        );
    }

    class entity : ScriptBaseEntity
    {
        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
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

		void CRender( CBaseEntity@ pTarget, USE_TYPE useType = USE_TOGGLE )
		{
			CStore( pTarget );
			
			if( Flag( 8 ) )
			{
				Vector VecColor;
				g_Utility.StringToVector( VecColor, g_Util.GetCKV( pTarget, '$v_rendercolor' ) );
				pTarget.pev.rendercolor = ( useType == USE_OFF ) ? VecColor : self.pev.rendercolor;
			}
			if( Flag( 4 ) )
			{
				pTarget.pev.rendermode = ( useType == USE_OFF ) ? atoi( g_Util.GetCKV( pTarget, '$i_rendermode' ) ) : self.pev.rendermode;
			}
			if( Flag( 1 ) )
			{
				pTarget.pev.renderfx = ( useType == USE_OFF ) ? atoi( g_Util.GetCKV( pTarget, '$i_renderfx' ) ) : self.pev.renderfx;
			}
			if( Flag( 2 ) )
			{
				if( Flag( 64 ) && useType != USE_OFF )
				{
					CGradual( pTarget );
					return;
				}
				pTarget.pev.renderamt = ( useType == USE_OFF ) ? atof( g_Util.GetCKV( pTarget, '$i_renderamt' ) ) : self.pev.renderamt;
			}
            g_EntityFuncs.FireTargets( g_Util.GetCKV( self, '$s_target' ), pTarget, self, USE_TOGGLE, 0.0f );
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
				g_Util.SetCKV( pTarget, '$i_rendermode', string( pTarget.pev.rendermode ) );
			}
			if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$v_rendercolor' ) )
			{
				g_Util.SetCKV( pTarget, '$v_rendercolor', pTarget.pev.rendercolor.ToString() );
			}
			if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$i_renderamt' ) )
			{
				g_Util.SetCKV( pTarget, '$i_renderamt', string( pTarget.pev.renderamt ) );
			}
			if( !pTarget.GetCustomKeyvalues().HasKeyvalue( '$i_renderfx' ) )
			{
				g_Util.SetCKV( pTarget, '$i_renderfx', string( pTarget.pev.renderfx ) );
			}
		}

		void CGradual( CBaseEntity@ pTarget )
		{
			int Valor = atoi( g_Util.GetCKV( self, '$i_gradual' ).Replace( '-', '' ).Replace( '+', '' ) );
			int Accion = atoi( g_Util.GetCKV( self, '$i_gradual' ) );

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

			if( Accion < 0 && pTarget.pev.renderamt <= atoi( g_Util.GetCKV( self, '$s_gradual' ) )
			or Accion > 0 && pTarget.pev.renderamt >= atoi( g_Util.GetCKV( self, '$s_gradual' ) ) )
			{
				g_EntityFuncs.FireTargets( g_Util.GetCKV( self, '$s_target' ), pTarget, self, USE_TOGGLE, 0.0f );
			}
			else
			{
				g_Scheduler.SetTimeout( this, "CGradual", atof( g_Util.GetCKV( self, '$f_gradual' ) ), @pTarget );
			}
		}
    }
}
// End of namespace