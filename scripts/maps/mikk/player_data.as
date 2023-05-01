#include "utils"
#include "utils/customentity"

namespace player_data
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "player_data::player_data", "player_data" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'player_data' ) +
            g_ScriptInfo.Description( 'Exposed client information and can be used as a trigger_condition' ) +
            g_ScriptInfo.Wiki( 'player_data' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum player_data_spawnflags
    {
        ALL_PLAYERS = 1
    }

    class player_data : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string m_iszTrueCase, m_iszFalseCase, m_iszComparator;
        private int m_iCondition;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            if( szKey == "m_iszTrueCase" )
            {
                m_iszTrueCase = szValue;
            }
            else if( szKey == "m_iszFalseCase" )
            {
                m_iszFalseCase = szValue;
            }
            else if( szKey == "m_iszComparator" )
            {
                m_iszComparator = szValue;
            }
            else if( szKey == "m_iCondition" )
            {
                m_iCondition = atoi( szValue );
            }
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( IsLockedByMaster() )
            {
                if( spawnflag( ALL_PLAYERS ) )
                {
                    for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                    {
                        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                        VerifyData( pPlayer );
                    }
                }
                else
                {
                    VerifyData( ( pActivator.IsPlayer() ? cast<CBasePlayer@>( pActivator ) : null ) );
                }
            }
        }

        void VerifyData( CBasePlayer@ pPlayer )
        {
            if( pPlayer !is null )
            {
                CBasePlayerItem@ pHasItem = pPlayer.HasNamedPlayerItem( m_iszComparator );
                CBaseEntity@ pIntersects = g_EntityFuncs.FindEntityByTargetname( pIntersects, m_iszComparator );

                array<bool> Conditions = 
                {
                    // (0) No usage
                    pPlayer !is null,
                    // (1) 
                    pPlayer.HasSuit(),
                    // (2) 
                    string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) == m_iszComparator,
                    // (3) 
                    pPlayer.m_fLongJump,
                    // (4) 
                    g_PlayerFuncs.AdminLevel( pPlayer ) == 1,
                    // (5) 
                    g_PlayerFuncs.AdminLevel( pPlayer ) == 2,
                    // (6) 
                    g_PlayerFuncs.AdminLevel( pPlayer ) > 0,
                    // (7) 
                    pPlayer.IsAlive(),
                    // (8) 
                    pPlayer.IsOnLadder(),
                    // (9) 
                    ( ( self.pev.origin - pPlayer.pev.origin ).Length() <= atoi( m_iszComparator ) ),
                    // (10) 
                    pPlayer.FlashlightIsOn(),
                    // (11) 
                    pPlayer.GetObserver().IsObserver(),
                    // (12) 
                    pPlayer.GetObserver().IsObserver() && pPlayer.GetObserver().HasCorpse(),
                    // (13) 
                    pPlayer.IsMoving(),
                    // (14) 
                    pHasItem !is null,
                    // (15) 
                    pIntersects !is null && pIntersects.Intersects( pPlayer ),
                };

                if( Conditions[ m_iCondition ] )
                {
                    g_Util.Trigger( m_iszTrueCase, pPlayer, self, USE_TOGGLE, delay );
                }
                else
                {
                    g_Util.Trigger( m_iszFalseCase, pPlayer, self, USE_TOGGLE, delay );
                }
            }
        }
    }
}