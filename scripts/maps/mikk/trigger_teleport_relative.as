#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_teleport_relative
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_teleport_relative::trigger_teleport_relative", "trigger_teleport_relative" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_teleport_relative' ) +
            g_ScriptInfo.Description( 'Entity for relative teleport using landmarks' ) +
            g_ScriptInfo.Wiki( 'trigger_teleport_relative' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    enum trigger_teleport_relative_spawnflags
    {
        ALL_PLAYERS = 1,
        ALLOW_MONSTERS = 2,
        NO_CLIENTS = 4
    }

    class trigger_teleport_relative : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string m_iszTargetOnExit, m_vStartPoint, m_vEndPoint;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_vStartPoint" ) 
            {
                m_vStartPoint = szValue;
            }
            else if( szKey == "m_vEndPoint" ) 
            {
                m_vEndPoint = szValue;
            }
            else if( szKey == "m_iszTargetOnExit" ) 
            {
                m_iszTargetOnExit = szValue;
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Spawn()
        {
            self.pev.solid = SOLID_TRIGGER;
            self.pev.effects |= EF_NODRAW;
            self.pev.movetype = MOVETYPE_NONE;
            SetBoundaries();

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( spawnflag( ALL_PLAYERS ) )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    RelativeTeleport( cast<CBasePlayer@>( g_PlayerFuncs.FindPlayerByIndex( iPlayer ) ) );
                }
            }
            else
            {
                RelativeTeleport( pActivator );
            }
        }

        void Touch( CBaseEntity@ pOther ) 
        {
            RelativeTeleport( pOther );
        }

        void RelativeTeleport( CBaseEntity@ pTeleEnt = null )
        {
            if( pTeleEnt !is null && !IsLockedByMaster() )
            {
                if( pTeleEnt.IsPlayer() && !spawnflag( NO_CLIENTS ) || pTeleEnt.IsMonster() && spawnflag( ALLOW_MONSTERS ) )
                {
                    Vector VecStart, VecEnd;

                    if( g_Utility.IsString3DVec( m_vStartPoint ) )
                    {
                        VecStart = g_Util.StringToVec( m_vStartPoint );
                    }
                    else
                    {
                        VecStart = LandmarkName( m_vStartPoint );
                    }

                    if( g_Utility.IsString3DVec( m_vEndPoint ) )
                    {
                        VecEnd = g_Util.StringToVec( m_vEndPoint );
                    }
                    else
                    {
                        VecEnd = LandmarkName( m_vEndPoint );
                    }

                    if( VecStart != g_vecZero && VecEnd != g_vecZero )
                    {
                        Vector VecDif = ( VecStart - pTeleEnt.pev.origin );
                        Vector VecRes = ( VecEnd - VecDif );
                        g_EntityFuncs.SetOrigin( pTeleEnt, VecRes );
                        g_Util.Trigger( m_iszTargetOnExit, pTeleEnt, self, USE_TOGGLE, m_fDelay );
                    }
                }
            }
        }

        Vector LandmarkName( const string iszLandmark )
        {
            CBaseEntity@ pLandmark = g_EntityFuncs.FindEntityByTargetname( pLandmark, iszLandmark );

            if( pLandmark !is null )
            {
                return pLandmark.pev.origin;
            }
            return Vector( 0, 0, 0 );
        }
    }
}