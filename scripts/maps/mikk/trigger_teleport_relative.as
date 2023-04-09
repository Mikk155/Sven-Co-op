#include "utils"
namespace trigger_teleport_relative
{
    class trigger_teleport_relative : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        private string m_iszTargetOnExit;
		private Vector m_vStartPoint, m_vEndPoint;
		private int m_iAllowMonsters;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "m_vStartPoint" ) 
            {
				g_Utility.StringToVector( m_vStartPoint, szValue );
            }
            else if( szKey == "m_vEndPoint" ) 
            {
				g_Utility.StringToVector( m_vEndPoint, szValue );
            }
            else if( szKey == "m_iszTargetOnExit" ) 
            {
                m_iszTargetOnExit = szValue;
            }
            else if( szKey == "m_iAllowMonsters" ) 
            {
                m_iAllowMonsters = atoi( szValue );
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
			if( spawnflag( 1 ) )
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
            if( pTeleEnt !is null && !master() )
            {
				if( m_iAllowMonsters == 1 && !pTeleEnt.IsPlayer() )
				{
					return;
				}

                Vector VecDif = ( m_vStartPoint - pTeleEnt.pev.origin );
                Vector VecRes = ( m_vEndPoint - VecDif );
                g_EntityFuncs.SetOrigin( pTeleEnt, VecRes );
				g_Util.Trigger( m_iszTargetOnExit, pTeleEnt, self, USE_TOGGLE, delay );
            }
        }
    }
	bool Register = g_Util.CustomEntity( 'trigger_teleport_relative::trigger_teleport_relative','trigger_teleport_relative' );
}