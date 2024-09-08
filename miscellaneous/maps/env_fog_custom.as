#include 'utils/CEffects'
#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace env_fog_custom
{
    void Register()
    {
        g_Util.CustomEntity( 'env_fog_custom' );
        g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @env_fog_custom::playerjoin );
        g_Scheduler.SetTimeout( "env_fog_custom_init", 0.0f );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'env_fog_custom' ) +
            g_ScriptInfo.Description( 'Expands env_fog entity' ) +
            g_ScriptInfo.Wiki( 'env_fog_custom' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    void env_fog_custom_init()
    {
        CBaseEntity@ pFog = null;

        while( ( @pFog = g_EntityFuncs.FindEntityByClassname( pFog, "env_fog" ) ) !is null )
        {
            if( pFog !is null )
            {
                if( pFog.pev.SpawnFlagBitSet( INDIVIDUAL )
                or pFog.pev.SpawnFlagBitSet( FADEIN_COLOR )
                or pFog.pev.SpawnFlagBitSet( FADEIN_MINDIS )
                or pFog.pev.SpawnFlagBitSet( FADEIN_MAXDIS ) )
                {
                    dictionary g_keyvalues =
                    {
                        { "targetname", pFog.GetTargetname() },
                        { "netname", string( pFog.pev.iuser2 ) },
                        { "message", string( pFog.pev.iuser3 ) },
                        { "rendercolor", pFog.pev.rendercolor.ToString() },
                        { "spawnflags", string( pFog.pev.spawnflags ) },
                        { "$s_master", g_Util.CKV( pFog, '$s_master' ) },
                        { "$s_TriggerOnMaster", g_Util.CKV( pFog, '$s_TriggerOnMaster' ) },
                        { "$v_fog_rendercolor", g_Util.CKV( pFog, '$v_fog_rendercolor' ) },
                        { "$f_fog_rendercolor_time", g_Util.CKV( pFog, '$f_fog_rendercolor_time' ) },
                        { "$i_fog_iuser2", g_Util.CKV( pFog, '$i_fog_iuser2' ) },
                        { "$f_fog_iuser2_time", g_Util.CKV( pFog, '$f_fog_iuser2_time' ) },
                        { "$i_fog_iuser3", g_Util.CKV( pFog, '$i_fog_iuser3' ) },
                        { "$f_fog_iuser3_time", g_Util.CKV( pFog, '$f_fog_iuser3_time' ) }
                    };

                    CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "env_fog_custom", g_keyvalues );
                    
                    if( pEntity !is null )
                    {
                        g_EntityFuncs.Remove( pFog );
                    }
                }
            }
        }
    }

    enum env_fog_custom_spawnflags
    {
        START_OFF = 1,
        INDIVIDUAL = 2,
        FADEIN_COLOR = 4,
        FADEIN_MINDIS = 8,
        FADEIN_MAXDIS = 16
    }

    class env_fog_custom : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private bool State = false;

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( useType == USE_KILL )
            {
                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                    if( pPlayer !is null )
                    {
                        g_Effect.fog( pPlayer, 0, 0, 0, 0, 0, 0 );
                    }
                }
                return;
            }

            if( useType == USE_OFF ) State = false;
            else if( useType == USE_ON ) State = true;
            else State = !State;

            uint8
            R = uint8( self.pev.rendercolor.x ),
            G = uint8( self.pev.rendercolor.y ),
            B = uint8( self.pev.rendercolor.z );

            if( spawnflag( INDIVIDUAL ) && pActivator !is null && pActivator.IsPlayer() )
            {
                CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );
                
                if( pPlayer !is null )
                {
                    if( spawnflag( FADEIN_COLOR ) or spawnflag( FADEIN_MINDIS ) or spawnflag( FADEIN_MAXDIS ) )
                    {
                        ExecFog( pPlayer, State );
                    }
                    else
                    {
                        g_Effect.fog( pPlayer, ( State ? 1 : 0 ), R, G, B, atoi(self.pev.netname), atoi(self.pev.message) );
                    }
                }
            }
            else
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ ePlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( ePlayer !is null )
                    {
                        if( spawnflag( FADEIN_COLOR ) or spawnflag( FADEIN_MINDIS ) or spawnflag( FADEIN_MAXDIS ) )
                        {
                            ExecFog( ePlayer, State );
                        }
                        else
                        {
                            g_Effect.fog( ePlayer, ( State ? 1 : 0 ), R, G, B, atoi(self.pev.netname), atoi(self.pev.message) );
                        }
                    }
                }
            }
        }
        
        void ExecFog( CBasePlayer@ pPlayer, bool State, USE_TYPE UseType = USE_TOGGLE )
        {
            if( UseType == USE_SET )
            {
                g_Util.CKV( pPlayer, '$i_fog_state', 2 );
                return;
            }

            if( atoi( g_Util.CKV( pPlayer, '$i_fog_state' ) ) == 1 )
            {
                return;
            }

            g_Util.CKV( pPlayer, '$i_fog_state', 1 );

            if( HasKey( '$v_fog_rendercolor' ) && spawnflag( FADEIN_COLOR ) )
            {
                g_Util.CKV( pPlayer, '$v_fog_rendercolor', ( State ) ? g_Util.CKV( self, '$v_fog_rendercolor' ) : self.pev.rendercolor.ToString() );
                g_Scheduler.SetTimeout( @this, "CFog", 0.0f, @pPlayer, 4, State );
            }
            if( HasKey( '$i_fog_iuser2' ) && spawnflag( FADEIN_MINDIS ) )
            {
                g_Util.CKV( pPlayer, '$i_fog_iuser2', g_Util.CKV( self, '$i_fog_iuser2' ) );
                g_Scheduler.SetTimeout( @this, "CFog", 0.0f, @pPlayer, 8, State );
            }
            if( HasKey( '$i_fog_iuser3' ) && spawnflag( FADEIN_MAXDIS ) )
            {
                g_Util.CKV( pPlayer, '$i_fog_iuser3', g_Util.CKV( self, '$i_fog_iuser3' ) );
                g_Scheduler.SetTimeout( @this, "CFog", 0.0f, @pPlayer, 16, State );
            }
        }

        void CFog( CBasePlayer@ pPlayer, int Mode, bool Statex )
        {
            if( atoi( g_Util.CKV( pPlayer, '$i_fog_state' ) ) == 2 )
            {
                return;
            }

            bool bl = true;

            uint8 R = uint8( self.pev.rendercolor.x );
            uint8 G = uint8( self.pev.rendercolor.y );
            uint8 B = uint8( self.pev.rendercolor.z );
            int Iuser2 = atoi( self.pev.netname );
            int Iuser3 = atoi( self.pev.message );

            if( !Statex )
            {
                R = uint8( g_Util.atov( g_Util.CKV( self, '$v_fog_rendercolor' ) ).x );
                G = uint8( g_Util.atov( g_Util.CKV( self, '$v_fog_rendercolor' ) ).y );
                B = uint8( g_Util.atov( g_Util.CKV( self, '$v_fog_rendercolor' ) ).z );
                Iuser2 = atoi( g_Util.CKV( self, '$i_fog_iuser2' ) );
                Iuser3 = atoi( g_Util.CKV( self, '$i_fog_iuser3' ) );
            }

            if( Mode == FADEIN_COLOR )
            {
                Vector VecColor = g_Util.atov( g_Util.CKV( pPlayer, '$v_fog_rendercolor' ) );
                uint8 pR = uint8( VecColor.x );
                uint8 pG = uint8( VecColor.y );
                uint8 pB = uint8( VecColor.z );
                if(pR>R)pR--;else if(pR<R)pR++;else bl=false;R=pR;
                if(pG>G)pG--;else if(pG<G)pG++;else bl=false;G=pG;
                if(pB>B)pB--;else if(pB<B)pB++;else bl=false;B=pB;
                g_Util.CKV( pPlayer, '$v_fog_rendercolor', Vector( R, G, B ).ToString() );
                if(bl)g_Scheduler.SetTimeout( @this, "CFog", ( HasKey( '$f_fog_rendercolor_time' ) ) ? atof( g_Util.CKV( self, '$f_fog_rendercolor_time' ) ) : 0.1f, @pPlayer, 4, Statex );
            }
            else if( Mode == FADEIN_MINDIS )
            {
                int pIuser2 = atoi( g_Util.CKV( pPlayer, '$i_fog_iuser2' ) );
                if(pIuser2>Iuser2)pIuser2--;else if(pIuser2<Iuser2)pIuser2++;else bl=false;Iuser2=pIuser2;
                g_Util.CKV( pPlayer, '$i_fog_iuser2', Iuser2 );
                if(bl)g_Scheduler.SetTimeout( @this, "CFog", ( HasKey( '$f_fog_iuser2_time' ) ) ? atof( g_Util.CKV( self, '$f_fog_iuser2_time' ) ) : 0.1f, @pPlayer, 8, Statex );
            }
            else if( Mode == FADEIN_MAXDIS )
            {
                int pIuser3 = atoi( g_Util.CKV( pPlayer, '$i_fog_iuser3' ) );
                if(pIuser3>Iuser3)pIuser3--;else if(pIuser3<Iuser3)pIuser3++;else bl=false;Iuser3=pIuser3;
                g_Util.CKV( pPlayer, '$i_fog_iuser3', Iuser3 );
                if(bl)g_Scheduler.SetTimeout( @this, "CFog", ( HasKey( '$f_fog_iuser3_time' ) ) ? atof( g_Util.CKV( self, '$f_fog_iuser3_time' ) ) : 0.1f, @pPlayer, 16, Statex );
            }

            g_Effect.fog( pPlayer, 1, R, G, B, Iuser2, Iuser3 );

            if( !bl ) g_Util.CKV( pPlayer, '$i_fog_state', 0 );
        }
        
        void UpdateOnRemove()
        {
            self.Use( null, null, USE_KILL, 0.0f );
            BaseClass.UpdateOnRemove();
        }
    
        bool HasKey( string key )
        {
            if( g_Util.CKV( self, key ).IsEmpty() )
                return false;
            return true;
        }
    }

    HookReturnCode playerjoin( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null )
        {
            CBaseEntity@ pIndiFog = null;
            while( ( @pIndiFog = g_EntityFuncs.FindEntityByClassname( pIndiFog, "env_fog_custom" ) ) !is null )
            {
                if( !pIndiFog.pev.SpawnFlagBitSet( START_OFF ) )
                {
                    g_Scheduler.SetTimeout( "EnableFog", 2.0f, EHandle(pIndiFog), EHandle(pPlayer) );
                }
            }
        }
        return HOOK_CONTINUE;
    }
    
    void EnableFog( EHandle fog, EHandle player )
    {
        if( player.IsValid() && fog.IsValid() )
        {
            cast<CBaseEntity@>(fog).Use( cast<CBasePlayer@>(player.GetEntity()), null, USE_ON, 0.0f );
        }
    }
}
