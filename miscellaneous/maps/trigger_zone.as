#include 'utils/as_utils'

namespace trigger_zone
{
    void Register()
    {
        m_EntityFuncs.CustomEntity( 'trigger_zone' );

        m_ScriptInfo.SetScriptInfo
        (
            {
                { 'script', 'trigger_zone' },
                { 'description', 'Trigger target by a set BBox' }
            }
        );
    }

    class trigger_zone : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            return BaseClass.KeyValue( szKey, szValue );
        }

        void Spawn()
        {
            self.pev.solid = SOLID_TRIGGER;
            self.pev.effects |= EF_NODRAW;
            self.pev.movetype = MOVETYPE_NONE;
            SetBBOX();

            BaseClass.Spawn();
        }

        void Touch( CBaseEntity@ pOther )
        {
            if( pOther !is null )
            {
                float fdelay;
                m_CustomKeyValue.GetValue( pOther, '$f_trigger_zone_delay', fdelay );

                if( fdelay <= 0.0f )
                {
                    m_EntityFuncs.Trigger( m_iszTargetOnExit, pTeleEnt, self, m_iUseType );
                    m_CustomKeyValue.SetValue( pOther, '$f_trigger_zone_delay', m_fDelay );
                    g_Scheduler.SetTimeout( @this, 'DelayedReduce', 0.1f, @pOther );
                }
            }
        }

        void DelayedReduce( CBaseEntity@ pOther )
        {
            if( !IsLockedByMaster() && pOther !is null )
            {
                float fdelay;
                m_CustomKeyValue.GetValue( pOther, '$f_trigger_zone_delay', fdelay );

                if( fdelay > 0.0f )
                {
                    m_CustomKeyValue.SetValue( pOther, '$f_trigger_zone_delay', fdelay );
                    g_Scheduler.SetTimeout( @this, 'DelayedReduce', 0.1f, @pOther );
                }
            }
        }
    }
}
