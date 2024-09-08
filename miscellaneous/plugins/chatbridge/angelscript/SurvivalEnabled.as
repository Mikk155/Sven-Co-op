namespace SurvivalEnabled
{
    void MapInit()
    {
        if( g_SurvivalMode.IsEnabled() && pJson.getboolean( "SURVIVAL_START:LOG" ) )
            g_Scheduler.SetTimeout( "SurvivalEnabled", g_SurvivalMode.GetDelayBeforeStart() + 2.0f );
    }

    void SurvivalEnabled()
    {
        ParseMSG( ParseLanguage( pJson, "SURVIVALSTART" ) );
    }
}