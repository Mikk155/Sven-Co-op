namespace PlayersConnected
{
    void MapInit()
    {
        if( pJson.getboolean( "PLAYERS_START:LOG" ) )
        {
            g_Scheduler.SetTimeout( "PlayersConnected", g_SurvivalMode.GetDelayBeforeStart() + 2.0f );
        }
    }

    void PlayersConnected()
    {
        int a;

        GetPlayers( a );

        if( a == 0 )
        {
            ParseMSG( ParseLanguage( pJson, "NOPLAYERS" ) );
        }
        else
        {
            dictionary pReplacement;
            pReplacement["number"] = string( a );
            pReplacement["s"] = ( a == 1 ? "" : "s" );
            ParseMSG( ParseLanguage( pJson, "CONNECTEDPLAYERS", pReplacement ) );
        }
    }
}