#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace game_zone_entity
{
    void Register()
    {
        g_Util.CustomEntity( 'game_zone_entity' );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'game_zone_entity' ) +
            g_ScriptInfo.Description( 'Expands game_zone_player removing the limitation to players only.' ) +
            g_ScriptInfo.Wiki( 'game_zone_entity' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetGithub() +
            g_ScriptInfo.GetDiscord()
        );
    }

    enum game_zone_entity_spawnflags
    {
        IGNORE_DEAD_ENTITIES = 1
    }

    class game_zone_entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string intarget, outtarget;
        private int USE_IN = 2, USE_OUT = 2;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );

            if( szKey == "intarget" ) 
            {
                intarget = szValue;
            }
            else if( szKey == "USE_IN" ) 
            {
                USE_IN = atoi( szValue );
            }
            else if( szKey == "outtarget" ) 
            {
                outtarget = szValue;
            }
            else if( szKey == "USE_OUT" ) 
            {
                USE_OUT = atoi( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }

            return true;
        }

        void Spawn() 
        {
            self.pev.movetype   = MOVETYPE_NONE;
            self.pev.solid      = SOLID_TRIGGER;
            self.pev.effects   |= EF_NODRAW;

            SetBoundaries();

            BaseClass.Spawn();
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            m_UTLatest = useType;

            if( IsLockedByMaster() )
                return;

            if( string( self.pev.netname ).IsEmpty()  or string( self.pev.netname ) == 'player' )
            {
                for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

                    CheckInVolume( pPlayer );
                }
            }
            else
            {
                CBaseEntity@ pEntity = null;

                while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, string( self.pev.netname ) ) ) !is null )
                {
                    CheckInVolume( pEntity );
                }
            }
        }

        void CheckInVolume( CBaseEntity@ pActivator )
        {
            if( spawnflag( IGNORE_DEAD_ENTITIES ) && !pActivator.IsAlive() )
                return;

            if( !intarget.IsEmpty() and self.Intersects( pActivator ) )
            {
                g_Util.Trigger( intarget, pActivator, self, USE_TOGGLE, m_fDelay );
            }

            if( !outtarget.IsEmpty() and !self.Intersects( pActivator ) )
            {
                g_Util.Trigger( outtarget, pActivator, self, g_Util.itout( USE_OUT, m_UTLatest ), m_fDelay );
            }
        }
    }
}