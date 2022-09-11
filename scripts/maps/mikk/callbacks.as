/*
	Usage:
	
	"m_iszScriptFile" "mikk/callbacks"

*/

// Enable to see debugs
bool DebugMode = false;

HUDTextParams HudParams;

namespace CTriggerScripts
{
	/*
		Call via monster's TriggerCondition to get the killer entity as activator instead of the monster who die.
		"netname" "things that the killer will fire"
		"targetname" "monster's TriggerTarget"
		"m_iszScriptFunctionName" "CTriggerScripts::GetKillerTriggerTarget"
		"m_iMode" "1"
	*/
	void GetKillerTriggerTarget( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		CBaseEntity@ pInflictor = g_EntityFuncs.Instance( pActivator.pev.dmg_inflictor );
		CBaseMonster@ pMonsterActivator = cast<CBaseMonster@>(pActivator);
		CBaseEntity@ pTriggerScript = null;

		while( ( @pTriggerScript = g_EntityFuncs.FindEntityByClassname( pTriggerScript, "trigger_script" )) !is null )
		{
			if( string( pMonsterActivator.m_iszTriggerTarget ) == string( pTriggerScript.pev.targetname ) )
			{
				if( DebugMode ) { g_Game.AlertMessage( at_console, "TS DEBUG-: Monster Fire it's condition.\nfound " + pTriggerScript.pev.classname + "\n netname " + pTriggerScript.pev.netname + " has been fired.\n" ); }
				g_EntityFuncs.FireTargets( pTriggerScript.pev.netname, pInflictor, pInflictor, USE_TOGGLE );
			}
		}
	}


	/*
		Call for Toggle survival mode.

		"m_iszScriptFunctionName" "CTriggerScripts::ToggleSurvivalMode"
		"m_iMode" "1"
	*/
	void ToggleSurvivalMode( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		if( !g_SurvivalMode.IsActive()
		or !g_SurvivalMode.IsEnabled() )
		{
			g_SurvivalMode.Activate( true );
			g_SurvivalMode.Enable();
			if( DebugMode ) { g_Game.AlertMessage( at_console, "TS DEBUG-: Survival mode has been enabled\n" ); }
		}
		else
		{
			g_SurvivalMode.Disable();
			if( DebugMode ) { g_Game.AlertMessage( at_console, "TS DEBUG-: Survival mode has been disabled\n" ); }
		}
	}


	/*
		Call for trigger something depending the ammt of players connected
		Your entities logics should be named "players_+(number of players)" stack your map logics up to 32

		"m_iszScriptFunctionName" "CTriggerScripts::currentplayers"
		"m_iMode" "1"
	*/
	void GetPlayersConnected( CBaseEntity@ pActivator,CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
	{
		g_EntityFuncs.FireTargets( "players_" + g_PlayerFuncs.GetNumPlayers(), null, null, USE_TOGGLE, 0.0f, 0.0f );
		if( DebugMode ) { g_Game.AlertMessage( at_console, "TS DEBUG-: found players. fired entity players_" + g_PlayerFuncs.GetNumPlayers() +"\n" ); }
	}


	/*
		Call for implementation of "Stealth" in Episode-One series.

		"m_iszScriptFunctionName" "CTriggerScripts::Stealth"
		"m_iMode" "2"
		"target" "name of the monster to watch for"
		"netname" "entity to teleport the player at location when he is seen by the monster target"
		"message" "Fire target for !activator when he is seen"
	*/
	void Stealth( CBaseEntity@ pTriggerScript )
	{
		CBaseEntity@ pEnemy = null;
		while( ( @pEnemy = g_EntityFuncs.FindEntityByTargetname( pEnemy, string( pTriggerScript.pev.target ) )) !is null )
		{
			CBaseMonster@ pMoster = cast<CBaseMonster@>(pEnemy);
			
			if( pMoster.m_hEnemy.GetEntity() !is null )
			{
				CBaseEntity@ pTeleport = null;
				while( ( @pTeleport = g_EntityFuncs.FindEntityByTargetname( pTeleport, pTriggerScript.pev.netname )) !is null )
				{
					pMoster.m_hEnemy.GetEntity().SetOrigin( pTeleport.pev.origin );
					g_EntityFuncs.FireTargets( string(pTriggerScript.pev.message), pMoster.m_hEnemy.GetEntity(), pMoster.m_hEnemy.GetEntity(), USE_TOGGLE, 0.0f, 0.0f );
				}

				pMoster.m_hEnemy = null;
			}
		}
	}


	/*
		Call for Render something progressively
		
		"m_iszScriptFunctionName" "CTriggerScripts::RenderProgressive"
		"m_iMode" "2"
		"target" "entity to affect"
		"renderamt" "value to change progressively"
	*/
	void RenderProgressive(CBaseEntity@ pTriggerScript)
	{
		CBaseEntity@ pEntity = null;
		while((@pEntity = g_EntityFuncs.FindEntityByTargetname(pEntity, pTriggerScript.pev.target)) !is null)
		{
			if( pTriggerScript.pev.renderamt > pEntity.pev.renderamt )
			{
				pEntity.pev.renderamt += 1;
			}
			else
			{
				pEntity.pev.renderamt -= 1;
			}

			if( pEntity.pev.renderamt == pTriggerScript.pev.renderamt )
			{
				g_EntityFuncs.FireTargets( ""+pTriggerScript.pev.targetname+"", null, null, USE_TOGGLE );
			}
		}
	}


	/*
		Call for showing a timer as "The game will start in X seconds"
		
		"m_iszScriptFunctionName" "CTriggerScripts::ShowTimer"
		"m_iMode" "2"
		"m_flThinkDelta" "1.0"
		"health" "time in seconds"
		"netname" "fire when time expire"
	*/
	void ShowTimer( CBaseEntity@ pTriggerScript )
	{
		// TODO feature pal game_text_custom para mostrar un timer.
		HudParams.x = -1;
		HudParams.y = 0.90;
		HudParams.effect = 0;
		HudParams.r1 = RGBA_SVENCOOP.r;
		HudParams.g1 = RGBA_SVENCOOP.g;
		HudParams.b1 = RGBA_SVENCOOP.b;
		HudParams.a1 = 0;
		HudParams.r2 = RGBA_SVENCOOP.r;
		HudParams.g2 = RGBA_SVENCOOP.g;
		HudParams.b2 = RGBA_SVENCOOP.b;
		HudParams.a2 = 0;
		HudParams.fadeinTime = 0; 
		HudParams.fadeoutTime = 0.25;
		HudParams.holdTime = 2;
		HudParams.fxTime = 0;
		HudParams.channel = 3;

		for( int iPlayer = 1; iPlayer <= g_PlayerFuncs.GetNumPlayers(); ++iPlayer )
		{
			CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( iPlayer );

			if( pPlayer is null || !pPlayer.IsConnected() )
				continue;

			CustomKeyvalues@ ckLenguage = pPlayer.GetCustomKeyvalues();
			CustomKeyvalue ckLenguageIs = ckLenguage.GetKeyvalue("$f_lenguage");
			int iLanguage = int(ckLenguageIs.GetFloat());
			
			if(iLanguage == 1 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "El juego comenzara en "+int(pTriggerScript.pev.health)+" segundos.\n" );
			else if(iLanguage == 2 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Portuguese "+int(pTriggerScript.pev.health)+" .\n" );
			else if(iLanguage == 3 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "German "+int(pTriggerScript.pev.health)+" .\n" );
			else if(iLanguage == 4 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "French "+int(pTriggerScript.pev.health)+" .\n" );
			else if(iLanguage == 5 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Italian "+int(pTriggerScript.pev.health)+" .\n" );
			else if(iLanguage == 6 )
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "Esperanto "+int(pTriggerScript.pev.health)+" .\n" );
			else
				g_PlayerFuncs.HudMessage( pPlayer, HudParams, "The game will start in "+int(pTriggerScript.pev.health)+" seconds.\n" );
        }

		pTriggerScript.pev.health -= 1;
		
		if( int( pTriggerScript.pev.health) <= 0 )
		{
			g_EntityFuncs.FireTargets( string( pTriggerScript.pev.netname ), pTriggerScript, pTriggerScript, USE_TOGGLE );
			g_EntityFuncs.Remove( pTriggerScript );
		}
	}


	// Start of DupeFix script
	
	// Call GM::DupeFixSurvivalOff( true, true, true );
	// Change the true to false for disable the next features in order
	// The first argument defines Show/hide survival mode countdown messages
	// The second argument defines Block drop weapons while survival is Off
	// The third argument defines Do a blip noise when survival is enabled
	const bool bSurvivalEnabled = g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1 && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1;

	const bool bDropWeapEnabled = g_EngineFuncs.CVarGetFloat("mp_dropweapons") == 1;

	float flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );

	void DupeFixSurvivalOff( const bool blcooldown = true , const bool bldrop = true , const bool blaudio = true )
	{
		if( bSurvivalEnabled )
		{
			if( blcooldown )
			{
				g_SurvivalMode.Disable();
				g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
				g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 0 );
				g_Scheduler.SetTimeout( "SurvivalModeEnable", flSurvivalStartDelay );
			}
		}
		if( bDropWeapEnabled && bldrop )
		{
			g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
			g_Scheduler.SetTimeout( "SetDrop", flSurvivalStartDelay );
		}
		if( blaudio )
		{
			g_Scheduler.SetTimeout( "SetAudio", flSurvivalStartDelay );
		}
	}

	void SurvivalModeEnable()
	{
		g_SurvivalMode.Activate( true );
	}

	void SetDrop()
	{
		g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 1 );
	}

	void SetAudio()
	{
		NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
		message.WriteString( "spk buttons/bell1" );
		message.End();
	}
	// Ends of DupeFix script
}
// End of namespace