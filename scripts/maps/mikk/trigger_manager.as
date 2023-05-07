#include 'utils/CUtils'
#include 'utils/CGetInformation'
#include 'utils/Reflection'
#include "utils/ScriptBaseCustomEntity"

namespace trigger_manager
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_manager::trigger_manager", "trigger_manager" );

        g_ScriptInfo.SetInformation
        ( 
            g_ScriptInfo.ScriptName( 'trigger_manager' ) +
            g_ScriptInfo.Description( 'Allows mapper to fully customize the Triggering-System\'s inputs' ) +
            g_ScriptInfo.Wiki( 'trigger_manager' ) +
            g_ScriptInfo.Author( 'Mikk' ) +
            g_ScriptInfo.GetDiscord() +
            g_ScriptInfo.GetGithub()
        );
    }

    enum trigger_manager_spawnflags
    {
        REMOVE_ON_FIRE = 1,
        ONCE_PER_PLAYER = 2,
        SET_RESTORE_OPP = 4
    }

    enum trigger_manager_usetype
    {
        TRIGGER_OFF = 0,
        TRIGGER_ON = 1,
        TRIGGER_KILL = 2,
        TRIGGER_TOGGLE = 3,
        TRIGGER_SAME = 4,
        TRIGGER_OPPOSITE = 5,
        TRIGGER_SET = 6
    }

    class trigger_manager : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle Eactivator = null, Ecaller = null;
        private float m_iWaitUntilRefire;
        private string m_iszFireOnMaster, m_iszFireOnLocked, strTarget, m_iszActivator, m_iszCaller;
        private bool Reactivated = true;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_iszActivator" )
            {
                m_iszActivator = szValue;
            }
            else if( szKey == "m_iszCaller" )
            {
                m_iszCaller = szValue;
            }
            else if( szKey == "m_iszFireOnMaster" )
            {
                m_iszFireOnMaster = szValue;
            }
            else if( szKey == "m_iszFireOnLocked" )
            {
                m_iszFireOnLocked = szValue;
            }
            else if( szKey == "m_iWaitUntilRefire" || szKey == "wait" )
            {
                m_iWaitUntilRefire = atof( szValue );
            }
            else
            {
                return BaseClass.KeyValue( szKey, szValue );
            }
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
            if( pActivator !is null && spawnflag( SET_RESTORE_OPP ) && useType == USE_SET )
            {
                g_Util.SetCKV( pActivator, "$i_fireonce_" + self.entindex(), 0 );
                return;
            }

            if( IsLockedByMaster() )
            {
                strTarget = m_iszFireOnMaster;
            }
            else if( !Reactivated )
            {
                strTarget = m_iszFireOnLocked;
            }
            else
            {
                strTarget = string( self.pev.target );
            }
            
            if( strTarget.IsEmpty() ) { return; }

            if( m_iszActivator == '!activator' or m_iszActivator.IsEmpty() )
            {
                if( pActivator !is null ) Eactivator = pActivator; else Eactivator = self;
            }
            else if( m_iszActivator == "!caller" )
            {
                if( pCaller !is null ) Eactivator = pCaller; else Eactivator = self;
            }
            else if( m_iszActivator == "!attacker" )
            {
                if( pActivator !is null )
                {
                    CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );
                    if( pAttacker !is null ) Eactivator = pAttacker; else Eactivator = pActivator;
                }
                else Eactivator = self;
            }
            else
            {
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, m_iszActivator );
                if( pEnt !is null ) Eactivator = pEnt; else Eactivator = self;
            }

            if( m_iszCaller == '!activator' )
            {
                if( pActivator !is null ) Ecaller = pActivator; else Ecaller = self;
            }
            else if( m_iszCaller == "!caller" or m_iszCaller.IsEmpty() )
            {
                if( pCaller !is null ) Ecaller = pCaller; else Ecaller = self;
            }
            else if( m_iszCaller == "!attacker" )
            {
                if( pActivator !is null )
                {
                    CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );
                    if( pAttacker !is null ) Ecaller = pAttacker; else Ecaller = pActivator;
                }
                else Ecaller = self;
            }
            else
            {
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, m_iszCaller );
                if( pEnt !is null ) Eactivator = pEnt; else Eactivator = self;
            }

            if( spawnflag( ONCE_PER_PLAYER ) and atoi( g_Util.GetCKV( Eactivator.GetEntity(), "$i_fireonce_" + self.entindex() ) ) == 1 )
            {
                return;
            }

            g_Util.Trigger( strTarget, Eactivator.GetEntity(), Ecaller.GetEntity(), GetUseType( useType ), m_fDelay );
            
            if( spawnflag( REMOVE_ON_FIRE ) )
            {
                g_EntityFuncs.Remove( self );
            }
            
            if( spawnflag( ONCE_PER_PLAYER ) )
            {
                g_Util.SetCKV( Eactivator.GetEntity(), "$i_fireonce_" + self.entindex(), 1 );
            }
            
            if( m_iWaitUntilRefire > 0.0 )
            {
                Reactivated = false;
                g_Scheduler.SetTimeout( @this, "ReActivation", m_iWaitUntilRefire );
            }
        }
        
        void ReActivation()
        {
            Reactivated = true;
        }
    }
}