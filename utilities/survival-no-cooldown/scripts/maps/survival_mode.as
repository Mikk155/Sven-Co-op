/*
	Script by -Mikk
	
	Special thanks to Outerbeast and Gaftherman for help.
	https://github.com/Outerbeast
	https://github.com/Gaftherman
*/

void SurvivalModeMapInit()
{
	const bool bSurvivalEnabled = g_EngineFuncs.CVarGetFloat("mp_survival_starton") == 1 && g_EngineFuncs.CVarGetFloat("mp_survival_supported") == 1;

	const bool bDropWeapEnabled = g_EngineFuncs.CVarGetFloat("mp_dropweapons") == 1;

	float flSurvivalStartDelay = g_EngineFuncs.CVarGetFloat( "mp_survival_startdelay" );
	
	if( bSurvivalEnabled )
	{
		g_SurvivalMode.Disable();
		g_Scheduler.SetTimeout( "SurvivalModeEnable", flSurvivalStartDelay );
		g_EngineFuncs.CVarSetFloat( "mp_survival_startdelay", 0 );
		g_EngineFuncs.CVarSetFloat( "mp_survival_starton", 0 );
		g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
	}
	if( bDropWeapEnabled )
	{
		g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 0 );
	}
}

void SurvivalModeEnable()
{
    g_SurvivalMode.Activate( true );
	
	if( bDropWeapEnabled )
	{
		g_EngineFuncs.CVarSetFloat( "mp_dropweapons", 1 );
	}
	
    NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
    message.WriteString( "spk buttons/bell1" );
    message.End();
}