// Call CSurvival::DupeFixSurvivalOff( true, true, true );
// Change the true to false for disable the next features in order
// The first argument defines Show/hide survival mode countdown messages
// The second argument defines Block drop weapons while survival is Off
// If all the arguments is false then this script will not work.

namespace CSurvival
{
	// The third argument defines Do a blip noise when survival is enabled
	const bool bSurvivalEnabled = g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1 && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1;

	const bool bDropWeapEnabled = g_EngineFuncs.CVarGetFloat("mp_dropweapons") == 1;

	float flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );

	void AmmoDupeFix( const bool blcooldown = true , const bool bldrop = true , const bool blaudio = true )
	{
		if( !blcooldown && !bldrop && !blaudio ) return;

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