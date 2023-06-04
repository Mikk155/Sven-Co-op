#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

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
            m_UTLatest = useType;

            if( IsLockedByMaster() )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    if( g_Util.WhoAffected( pPlayer, m_iAffectedPlayer, pPlayer ) )
                    {
                        VerifyData( pPlayer );
                    }
                }
            }
            g_Util.Trigger( string( self.pev.target ), self, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
        }

        void VerifyData( CBasePlayer@ pPlayer )
        {
            if( pPlayer !is null )
            {
                CBasePlayerItem@ pHasItem = pPlayer.HasNamedPlayerItem( m_iszComparator );
                CBaseEntity@ pIntersects = g_EntityFuncs.FindEntityByTargetname( g_EntityFuncs.Instance( 0 ), m_iszComparator );

                array<bool> Conditions = 
                {
                    pPlayer !is null, /* 0 No usage */
                    pPlayer.HasSuit(), /* 1 */
                    string( g_EngineFuncs.GetPlayerAuthId( pPlayer.edict() ) ) == m_iszComparator, /* 2 */
                    pPlayer.m_fLongJump, /* 3 */
                    g_PlayerFuncs.AdminLevel( pPlayer ) == 1, /* 4 */
                    g_PlayerFuncs.AdminLevel( pPlayer ) == 2, /* 5 */
                    g_PlayerFuncs.AdminLevel( pPlayer ) > 0, /* 6 */
                    pPlayer.IsAlive(), /* 7 */
                    pPlayer.IsOnLadder(), /* 8 */
                    ( ( self.pev.origin - pPlayer.pev.origin ).Length() <= atoi( m_iszComparator ) ), /* 9 */
                    pPlayer.FlashlightIsOn(), /* 10 */
                    pPlayer.GetObserver().IsObserver(), /* 11 */
                    pPlayer.GetObserver().IsObserver() && pPlayer.GetObserver().HasCorpse(), /* 12 */
                    pPlayer.IsMoving(), /* 13 */
                    pHasItem !is null, /* 14 */
                    pIntersects !is null && pIntersects.Intersects( pPlayer ), /* 15 */
                };

                g_Util.Trigger( ( Conditions[ m_iCondition ] ? m_iszTrueCase : m_iszFalseCase ), pPlayer, self, g_Util.itout( m_iUseType, m_UTLatest ), m_fDelay );
            }
        }
    }
}