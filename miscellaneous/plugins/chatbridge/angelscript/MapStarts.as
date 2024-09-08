namespace MapStarts
{
    void MapInit()
    {
        if( pJson.getboolean( "SERVER_MAPSTART:LOG" ) )
        {
            dictionary pReplacement;
            pReplacement["name"] = string( g_Engine.mapname );
            ParseMSG( ParseLanguage( pJson, "STARTMAP", pReplacement ) );
        }
    }
}