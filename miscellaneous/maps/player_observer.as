#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace player_observer
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_observer::player_observer", "player_observer" );
        g_Hooks.RegisterHook( Hooks::Player::PlayerEnteredObserver, @player_observer::ClientJoin );
        g_Hooks.RegisterHook( Hooks::Player::PlayerLeftObserver, @player_observer::ClientLeft );
        g_Hooks.RegisterHook( Hooks::Player::PlayerPostThink, @player_observer::ClientThink );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_observer' ) +
            g_ScriptInfo.Description( 'Allow mapper to use Observer functions' ) +
            g_ScriptInfo.Wiki( 'player_observer' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    class player_observer : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string m_iszSetObserverTarget;
        private int m_iStartObserver;
        private int m_iStartObserverOrigin;
        private int m_iStartObserverAngles;
        private int m_iStartObserverBody;
        private int m_iSetMode;
        private int m_iSetObserverModeControlEnabled;
        private int m_iRemoveDeadBody;
        private int m_iFindNextPlayer;
        private float m_fDelayBeforeReSpawn;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "m_iszSetObserverTarget" ) 
            {
                m_iszSetObserverTarget = szValue;
            }
            else if( szKey == "m_iStartObserver" ) 
            {
                m_iStartObserver = atoi( szValue );
            }
            else if( szKey == "m_iStartObserverOrigin" ) 
            {
                m_iStartObserverOrigin = atoi( szValue );
            }
            else if( szKey == "m_iStartObserverAngles" ) 
            {
                m_iStartObserverAngles = atoi( szValue );
            }
            else if( szKey == "m_iStartObserverBody" ) 
            {
                m_iStartObserverBody = atoi( szValue );
            }
            else if( szKey == "m_iSetMode" ) 
            {
                m_iSetMode = atoi( szValue );
            }
            else if( szKey == "m_iSetObserverModeControlEnabled" ) 
            {
                m_iSetObserverModeControlEnabled = atoi( szValue );
            }
            else if( szKey == "m_iRemoveDeadBody" ) 
            {
                m_iRemoveDeadBody = atoi( szValue );
            }
            else if( szKey == "m_iFindNextPlayer" ) 
            {
                m_iFindNextPlayer = atoi( szValue );
            }
            else if( szKey == "m_fDelayBeforeReSpawn" ) 
            {
                m_fDelayBeforeReSpawn = atof( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn() 
        {
            g_EngineFuncs.CVarSetString( 'mp_observer_mode', '1' );
            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
            {
                return;
            }

            if( spawnflag( 1 ) )
            {
                for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( pPlayer !is null )
                    {
                        Observer( @pPlayer );
                    }
                }
            }
            else if( pActivator !is null && pActivator.IsPlayer() )
            {
                Observer( @pActivator );
            }
        }
        
        void Observer( EHandle hPlayer )
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>( hPlayer.GetEntity() );

            if( pPlayer is null )
                return;

            if( m_iStartObserver == 1 && !pPlayer.GetObserver().IsObserver() )
            {
                Vector VecOrigin = ( m_iStartObserverOrigin == 1 ) ? pPlayer.pev.origin : self.pev.origin;
                Vector VecAngles = ( m_iStartObserverAngles == 1 ) ? pPlayer.pev.angles : self.pev.angles;
                bool BlBody = ( m_iStartObserverBody == 1 ) ? false : true;
                pPlayer.GetObserver().StartObserver( VecOrigin, VecAngles, BlBody );
            }

            if( pPlayer.GetObserver().IsObserver() )
            {
                if( m_iszSetObserverTarget != '' )
                {
                    CBasePlayer@ pTarget = null;

                    if( g_Utility.IsStringInt( m_iszSetObserverTarget ) && atoi( m_iszSetObserverTarget ) > -1 )
                    {
                        @pTarget = cast<CBasePlayer@>( g_PlayerFuncs.FindPlayerByIndex( atoi( m_iszSetObserverTarget ) ) );
                    }
                    else
                    {
                        @pTarget = cast<CBasePlayer@>( g_EntityFuncs.FindEntityByTargetname( pTarget, m_iszSetObserverTarget ) );
                    }

                    if( pTarget !is null )
                    {
                        pPlayer.GetObserver().SetObserverTarget( pTarget );
                    }
                }
                if( m_iSetMode > 0 )
                {
                    pPlayer.GetObserver().SetMode( ( m_iSetMode == 1 ) ? OBS_CHASE_FREE : ( m_iSetMode == 3 ) ? OBS_CHASE_LOCKED : OBS_ROAMING );
                }
                bool BlControl = ( m_iSetObserverModeControlEnabled == 0 ) ? true : false;
                pPlayer.GetObserver().SetObserverModeControlEnabled( BlControl );

                if( m_iRemoveDeadBody == 1 )
                {
                    pPlayer.GetObserver().RemoveDeadBody();
                }

                if( m_iFindNextPlayer > 0 )
                {
                    bool fReverse = ( m_iFindNextPlayer == 2 ) ? true : false;
                    pPlayer.GetObserver().FindNextPlayer( fReverse );
                }

                if( m_fDelayBeforeReSpawn >= -1 )
                {
                    g_Util.CKV( pPlayer, '$i_player_observer', 1 );
                    if( m_fDelayBeforeReSpawn >= 0 )
                    {
                        g_Scheduler.SetTimeout( @this, "ReSpawns", m_fDelayBeforeReSpawn + 0.5f, @pPlayer );
                    }
                }
            }
        }
        
        void ReSpawns( CBasePlayer@ pPlayer )
        {
            g_Util.CKV( pPlayer, '$i_player_observer', 0 );
        }
    }
    
    void FindAndFire( CBasePlayer@ pPlayer, int iexm = 0 )
    {
        if( pPlayer !is null )
        {
            CBaseEntity@ self;
            while( ( @self = g_EntityFuncs.FindEntityByClassname( g_EntityFuncs.Instance( 0 ), "player_observer" ) ) !is null )
            {
                g_Util.Trigger( ( iexm == 1 ) ? self.pev.netname : self.pev.target, pPlayer, self, USE_TOGGLE, 0.0f );
            }
        }
    }

    HookReturnCode ClientThink( CBasePlayer@ pPlayer )
    {
        if( pPlayer !is null && !pPlayer.IsAlive() && pPlayer.GetObserver().IsObserver() && atoi( g_Util.CKV( pPlayer, '$i_player_observer' ) ) == 1 )
        {
            pPlayer.pev.nextthink = g_Engine.time + 1.0f;
        }
        return HOOK_CONTINUE;
    }
    HookReturnCode ClientLeft( CBasePlayer@ pPlayer )
    {
        FindAndFire( pPlayer, 1 );
        return HOOK_CONTINUE;
    }
    HookReturnCode ClientJoin( CBasePlayer@ pPlayer )
    {
        FindAndFire( pPlayer );
        return HOOK_CONTINUE;
    }
}