/*
-TODO
game_trigger_iterator
classname filter
targetname filter
invert filter
custom keyvalue filter
*/
#include "utils"
namespace trigger_system
{
    array<string> EverythingElse;
    array<string> Entities;

    void Register( array<string> inEntities = Entities, array<string> inEverythingElse = EverythingElse )
    {
		if( inEntities.length() < 1 )
		{
			Entities =
			{
				"func_button",
				"button_target",
				"func_rot_button",
				"momentary_rot_button",
				"trigger_entity_iterator",
				"trigger_respawn",
				"trigger_multiple",
				"trigger_once",
				"trigger_relay",
				"item_*",
				"ammo_*",
				"weapon_*",
				"info_player*",
				"func_breakable*",
				"func_tank*",
				"info_teleport_destination"
			};
		}
		else
		{
			Entities = inEntities;
		}
		if( inEverythingElse.length() < 1 )
		{
			EverythingElse =
			{
				"grenade",
				"env_sprite",
				"func_train",
				"func_tracktrain",
				"item_*",
				"ammo_*",
				"weapon_*"
			};
		}
		else
		{
			EverythingElse = inEverythingElse;
		}

		g_Scheduler.SetTimeout( "FindTriggerEntities", 1.0f );
    }

    enum trigger_multiple_flags
    {
        MONSTERS = 1,
        NOCLIENTS = 2,
        PUSHABLES = 4,
        EVERTHINGELSE = 8,
        IterateAllOccupants = 64
    };

	void FindTriggerEntities()
	{
		for( uint i = 0; i < Entities.length(); ++i )
		{
			CBaseEntity@ pEntity = null;

			while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, Entities[i] ) ) !is null)
			{
				if(g_Util.GetCKV( pEntity, "$i_tsystem_usetype" ) != ''
				or g_Util.GetCKV( pEntity, "$i_tsystem_individual" ) == '1'
				or g_Util.GetCKV( pEntity, "$i_tsystem_delay" ) != ''
				or pEntity.pev.ClassNameIs( 'trigger_multiple' ) && pEntity.pev.SpawnFlagBitSet( IterateAllOccupants ) )
				{
					g_Util.Debug( '[trigger_system]:' );
					g_Util.Debug( 'Created a trigger_script intermediary for entity with target "' + pEntity.pev.target + '"' );
					if( g_Util.GetCKV( pEntity, "$i_tsystem_usetype" ) != '' ) g_Util.Debug( '$i_tsystem_usetype "' + g_Util.GetCKV( pEntity, "$i_tsystem_usetype" ) + '"' );
					if( g_Util.GetCKV( pEntity, "$i_tsystem_individual" ) == '1' ) g_Util.Debug( '$i_tsystem_individual "' + g_Util.GetCKV( pEntity, "$i_tsystem_individual" ) + '"' );
					if( g_Util.GetCKV( pEntity, "$i_tsystem_delay" ) != '' ) g_Util.Debug( '$i_tsystem_delay "' + g_Util.GetCKV( pEntity, "$i_tsystem_delay" ) + '"' );
					if( pEntity.pev.ClassNameIs( 'trigger_multiple' ) && pEntity.pev.SpawnFlagBitSet( IterateAllOccupants ) ) g_Util.Debug( 'trigger_multiple flag IterateAllOccupants "' + string( pEntity.pev.SpawnFlagBitSet( IterateAllOccupants ) )  + '"' );

					CreateScript( pEntity );
				}
			}
		}

        g_Util.ScriptAuthor.insertLast
        (
            "Script: https://github.com/Mikk155/Sven-Co-op#trigger_system"
            "\nAuthor: Mikk"
            "\nGithub: github.com/Mikk155"
            "\nDescription: Allow Trigger-Type entities to fire its target only once per activator set a custom USE_TYPE and a custom delay time, "
			"Also allow trigger_multiple to fire its target for every one inside its volume.\n"
        );
	}

	void CreateScript( CBaseEntity@ pEntity )
	{
		string Target = string( pEntity.pev.target );

		dictionary g_keyvalues =
		{
			{ "m_iszScriptFunctionName","trigger_system::UseT" },
			{ "targetname", "TriggerSystem_" + Target }
		};
		CBaseEntity@ pScript = g_EntityFuncs.CreateEntity( "trigger_script", g_keyvalues );

		if( pScript !is null )
		{
			g_EntityFuncs.DispatchKeyValue( pEntity.edict(), "target", "TriggerSystem_" + Target );
		}
	}

    void UseT( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
    {
        if( pCaller is null )
		{
			g_Util.Debug( 'Null !caller' );
			return;
		}

		g_Util.Debug( '[trigger_system]:' );

		string target = string( pCaller.pev.target ).Replace( 'TriggerSystem_', '' );

		int iIndividual = atoi( g_Util.GetCKV( pCaller, "$i_tsystem_individual" ) );
		float iDelay = atof( g_Util.GetCKV( pCaller, "$i_tsystem_delay" ) );

		USE_TYPE NewUseType = USE_TOGGLE;

		if( g_Util.GetCKV( pCaller, "$i_tsystem_usetype" ) != '' )
		{
			int iUseType = atoi( g_Util.GetCKV( pCaller, "$i_tsystem_usetype" ) );

			if( iUseType == 0 )
			{
				NewUseType = USE_OFF;
				g_Util.Debug( 'USE_TYPE Set to USE_OFF' );
			}
			else if( iUseType == 1 )
			{
				NewUseType = USE_ON;
				g_Util.Debug( 'USE_TYPE Set to USE_ON' );
			}
			else if( iUseType == 2 )
			{
				NewUseType = USE_KILL;
				g_Util.Debug( 'USE_TYPE Set to USE_KILL' );
			}
			else
			{
				NewUseType = USE_TOGGLE;
				g_Util.Debug( 'USE_TYPE Set to USE_TOGGLE' );
			}
		}

		if( iIndividual > 0 )
		{
			if( pActivator is null )
			{
				return;
			}
			else if( atoi( g_Util.GetCKV( pActivator, "$i_fireonce_" + target ) ) == 1 )
			{
				return;
			}
			else
			{
				g_Util.SetCKV( pActivator, "$i_fireonce_" + target, '1' );
			}
		}

		if( pCaller.pev.ClassNameIs( 'trigger_multiple' ) && pCaller.pev.SpawnFlagBitSet( IterateAllOccupants ) )
		{
			g_Util.Debug( '[trigger_system.IterateAllOccupants]:' );
			if( pCaller.pev.SpawnFlagBitSet( MONSTERS ) )
			{
				g_Util.Debug( 'Iterates "monsters"' );
				IterateInVolume( target, pActivator, pCaller, NewUseType, iDelay, 'monster*' );
			}
			if( !pCaller.pev.SpawnFlagBitSet( NOCLIENTS ) )
			{
				g_Util.Debug( 'Iterates "player"' );
				IterateInVolume( target, pActivator, pCaller, NewUseType, iDelay, 'player' );
			}
			if( pCaller.pev.SpawnFlagBitSet( PUSHABLES ) )
			{
				g_Util.Debug( 'Iterates "func_pushable"' );
				IterateInVolume( target, pActivator, pCaller, NewUseType, iDelay, 'func_pushable' );
			}
			if( pCaller.pev.SpawnFlagBitSet( EVERTHINGELSE ) )
			{
				for( uint ui = 0; ui < EverythingElse.length(); ++ui )
				{
					g_Util.Debug( 'Iterates "' + EverythingElse[ui] + '"' );
					IterateInVolume( target, pActivator, pCaller, NewUseType, iDelay, EverythingElse[ui] );
				}
			}
		}
		else
		{
			g_Util.Trigger( target, pActivator, pCaller, NewUseType, iDelay );
		}
    }

	void IterateInVolume( const string& in target, CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE NewUseType, float iDelay, const string& in szClassname )
	{
		CBaseEntity@ pEntity = null;

		while( ( @pEntity = g_EntityFuncs.FindEntityByClassname( pEntity, szClassname ) ) !is null )
		{
			if( pEntity.IsPlayer() && pEntity.IsAlive()
			or pEntity.IsMonster() && pEntity.IsAlive() )
			{
				if( pCaller.Intersects( pEntity ) )
				{
					g_Util.Trigger( target, pEntity, pCaller, NewUseType, iDelay );
				}
			}
		}
	}
}
// End of namespace