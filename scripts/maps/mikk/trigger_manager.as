#include "utils"
namespace trigger_manager
{
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "trigger_manager::entity", "trigger_manager" );

        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#trigger_manager"
            "\nAuthor: Mikk"
            "\nGithub: github.com/Mikk155"
            "\nDescription: Entity that can be used as a intermediary for firing other entities. this include a lot of features, the original usage was the same as a trigger_relay.\n"
        );
    }

    class entity : ScriptBaseEntity, ScriptBaseCustomEntity
    {
        EHandle Eactivator = null, Ecaller = null;
		private int USETYPE = 4;
		private string trigger_if_master, trigger_if_locked, strTarget, activator, caller;
		private bool Reactivated = true;

        bool KeyValue( const string& in szKey, const string& in szValue )
        {
            ExtraKeyValues( szKey, szValue );
            if( szKey == "activator" )
			{
				activator = szValue;
			}
            else if( szKey == "caller" )
			{
				caller = szValue;
			}
            else if( szKey == "USETYPE" )
			{
				USETYPE = atoi( szValue );
			}
            else if( szKey == "trigger_if_master" )
			{
				trigger_if_master = szValue;
			}
            else if( szKey == "trigger_if_locked" )
			{
				trigger_if_master = szValue;
			}
            else
			{
				return BaseClass.KeyValue( szKey, szValue );
			}
            return true;
        }

        void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
        {
			if( master() )
			{
				strTarget = trigger_if_master;
			}
			else if( !Reactivated )
			{
				strTarget = trigger_if_locked;
			}
			else
			{
				strTarget = self.pev.target;
			}

			if( activator == '!activator' or activator.IsEmpty() )
			{
				if( pActivator !is null ) Eactivator = pActivator; else Eactivator = self;
			}
            else if( activator == "!caller" )
            {
				if( pCaller !is null ) Eactivator = pCaller; else Eactivator = self;
            }
            else if( activator == "!attacker" )
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
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, activator );
                if( pEnt !is null ) Eactivator = pEnt; else Eactivator = self;
            }

			if( caller == '!activator' )
			{
				if( pActivator !is null ) Ecaller = pActivator; else Ecaller = self;
			}
            else if( caller == "!caller" or caller.IsEmpty() )
            {
				if( pCaller !is null ) Ecaller = pCaller; else Ecaller = self;
            }
            else if( caller == "!attacker" )
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
                CBaseEntity@ pEnt = g_EntityFuncs.FindEntityByTargetname( pEnt, caller );
                if( pEnt !is null ) Eactivator = pEnt; else Eactivator = self;
            }

			USE_TYPE NewUseType;

			if( USETYPE == 0 )
			{
				NewUseType = USE_OFF;
			}
			else if( USETYPE == 1 )
			{
				NewUseType = USE_ON;
			}
			else if( USETYPE == 2 )
			{
				NewUseType = USE_KILL;
			}
			else if( USETYPE == 3 )
			{
				NewUseType = USE_TOGGLE;
			}
			else if( USETYPE == 4 )
			{
				NewUseType = useType;
			}
			else if( USETYPE == 5 )
			{
				NewUseType = ( useType == USE_OFF ? USE_ON : useType == USE_ON ? USE_OFF : USE_TOGGLE );
			}

			if( spawnflag( 2 ) and g_Util.GetCKV( Eactivator.GetEntity(), "$i_fireonce_" + self.entindex() ) == '1' )
			{
				return;
			}

            g_Util.Trigger( strTarget, Eactivator.GetEntity(), Ecaller.GetEntity(), NewUseType, delay );
			
			if( spawnflag( 1 ) )
			{
				g_EntityFuncs.Remove( self );
			}
			
			if( spawnflag( 2 ) )
			{
				g_Util.SetCKV( Eactivator.GetEntity(), "$i_fireonce_" + self.entindex(), '1' );
			}
			
			if( wait > 0.0 )
			{
				Reactivated = false;
				g_Scheduler.SetTimeout( @this, "ReActivation", wait );
			}
        }
		
		void ReActivation()
		{
			Reactivated = true;
		}
    }
}
// End of namespace