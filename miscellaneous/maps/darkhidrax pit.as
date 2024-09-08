// Targetname of the camera if you want to do anything
const string bc_drone_targetname = 'drone';

// Target name of your func_train that will be the drone itself.
const string bc_drone_model_targetname = 'drone_parts';

// Target name of the trigger_script so the script itself can kill the drone
const string bc_trigger_script_name = 'controll_drone';

// Max health of the drone
const int bc_drone_max_health = 1000;

// View offset for the trigger_camera from your func_train's origin
const Vector bc_drone_view_offset = Vector( 0, 0, 40 );

// Trigger this entity when the drone is removed,
// !activator your func_train
// !caller the func_breakable ( drone's health )
const string bc_drone_trigger_on_destroy = '';

// Trigger this entity when a player stops using the drone
// !activator player
// caller your func_train
const string bc_drone_trigger_on_stop = '';

// Name of a game_text to use for displaying the drone's health
const string bc_drone_display_health = '';

void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );

	// restart player info
	if( useType == USE_OFF && pPlayer !is null )
	{
		g_Drone.Restore( pPlayer );
	}
	// a player want to use the drone
	else if( useType == USE_ON && pPlayer !is null )
	{
		if( pPlayer !is null )
		{
			g_Drone.StartUsing( pPlayer );
		}
	}
	// the drone has been killed
	else
	{
		g_Drone.DroneKilled();
	}
}

CDrone g_Drone;

final class CDrone
{
	private CBaseEntity@ pCamera;
	private CBaseEntity@ pDrone;
	private CBaseEntity@ pBreakable;
	private Vector VecPos;

	void DroneKilled()
	{
		for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; iPlayer++ )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
			if( pPlayer !is null ) pCamera.Use( pPlayer, pBreakable, USE_OFF, 0.0f );
		}

		g_EntityFuncs.FireTargets( bc_drone_trigger_on_destroy, pDrone, pBreakable, USE_TOGGLE, 0.0f );
		g_EntityFuncs.Remove( pBreakable ); @pBreakable = null;
	}

	void StartUsing( CBasePlayer@ pPlayer )
	{
		if( pCamera is null )
		{
			dictionary g_kvz;
			g_kvz[ 'targetname' ] = bc_drone_targetname;
			g_kvz[ 'spawnflags'] = '768';
			g_kvz[ 'max_player_count'] = '1';
			g_kvz[ 'hud_health'] = '1';
			g_kvz[ 'hud_flashlight'] = '1';
			g_kvz[ 'hud_weapons'] = '1';

			@pCamera = g_EntityFuncs.CreateEntity( 'trigger_camera', g_kvz, true );
			Retry( pPlayer ); return;
		}

		if( pDrone is null )
		{
			@pDrone = g_EntityFuncs.FindEntityByTargetname( null, bc_drone_model_targetname );
			Retry( pPlayer ); return;
		}

		if( pBreakable is null )
		{
			dictionary g_kvz;
			g_kvz[ 'target'] = bc_trigger_script_name;
			g_kvz[ 'classify'] = '2';
			g_kvz[ 'model'] = string( pDrone.pev.model );
			g_kvz[ 'displayname'] = 'Drone';
			g_kvz[ 'rendermode'] = '4';
			g_kvz[ 'renderamt'] = '0';
			g_kvz[ 'health'] = string( bc_drone_max_health );

			@pBreakable = g_EntityFuncs.CreateEntity( 'func_breakable', g_kvz, true );
			Retry( pPlayer ); return;
		}

		VecPos = pPlayer.pev.origin;

		pCamera.Use( pPlayer, null, USE_ON, 0.0f );
		pDrone.Use( pPlayer, pCamera, USE_ON, 0.0f );
		g_Scheduler.SetTimeout( @this, 'ThinkUsing', 0.1f, @pPlayer );
	}

	void Retry( CBasePlayer@ pPlayer )
	{
		g_Scheduler.SetTimeout( @this, 'StartUsing', 0.0f, @pPlayer );
	}

	void ThinkUsing( CBasePlayer@ pPlayer )
	{
		if( pPlayer !is null && pCamera !is null && pDrone !is null )
		{
			CBaseEntity@ pText = g_EntityFuncs.FindEntityByTargetname( null, bc_drone_display_health );

			if( pText !is null )
			{
				pText.pev.message = 'Drone\'s Health: ' + string( int( pBreakable.pev.health ) ) + '\n';
				pText.Use( pPlayer, null, USE_ON, 0.0f );
			}

			if( pPlayer.pev.origin != VecPos )
				g_EntityFuncs.SetOrigin( pPlayer, VecPos );

			// Block weapons momentarly
			pPlayer.BlockWeapons( pDrone );
			// Render them transparent so other players notice
			pPlayer.pev.rendermode = kRenderTransTexture;
			pPlayer.pev.renderamt = 100;

			g_EntityFuncs.SetOrigin( pCamera, pDrone.GetOrigin() + bc_drone_view_offset );
			pCamera.pev.angles = pPlayer.pev.angles;

			g_EntityFuncs.SetOrigin( pBreakable, pDrone.GetOrigin() + bc_drone_view_offset );
			pBreakable.pev.angles = pDrone.pev.angles;

        	g_PlayerFuncs.PrintKeyBindingString( pPlayer, "+use to stop\n"  );

			if( pPlayer.pev.button & IN_USE != 0  )
			{
				g_EntityFuncs.FireTargets( bc_drone_trigger_on_stop, pPlayer, pDrone, USE_TOGGLE, 0.0f );
				Restore( pPlayer ); return;
			}

			g_Scheduler.SetTimeout( @this, 'ThinkUsing', 0.00001f, @pPlayer );
		}
	}

	void Restore( CBasePlayer@ pPlayer )
	{
		if( pPlayer !is null )
		{
			pPlayer.UnblockWeapons( pDrone );
			pPlayer.pev.rendermode = kRenderNormal;
			pPlayer.pev.renderamt = 255;
			pCamera.Use( pPlayer, null, USE_OFF, 0.0f );
		}
	}
}