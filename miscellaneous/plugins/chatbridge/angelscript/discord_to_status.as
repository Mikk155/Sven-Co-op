namespace discord_to_status
{
    const string szPath = 'scripts/plugins/store/discord_to_status.json';

    void MapInit()
    {
        if( map != string( g_Engine.mapname ) )
        {
            map = string( g_Engine.mapname );
            restarts = 0;
        }
    }

    void PluginInit()
    {
        g_FileSystem.RemoveFile( szPath );
        seconds = 0;
        minutes = 0;
        hours = 0;
        days = 0;
    }

    void Write()
    {
        if( !pJson.get( "CHANNEL_STATUS:BOT" ).IsEmpty() )
        {
            g_FileSystem.RemoveFile( szPath );

            File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::WRITE );

            if( pFile !is null && pFile.IsOpen() )
            {
                int t, a, c=0;
                if( pJson.getboolean( "STATUS_ALIVEPLAYERS:LOG" ) )
                    GetPlayers( t, a );

                if( pJson.getboolean( "STATUS_CHECKPOINTS:LOG" ) )
                    for( CBaseEntity@ cp = g_EntityFuncs.FindEntityByClassname( null, "point_checkpoint" ); cp !is null; c++, @cp = g_EntityFuncs.FindEntityByClassname( cp, "point_checkpoint" ) ) {}

                string m_szTime = ( days > 0 ? string( days ) + ":" : "" ) + ( hours < 10 ? "0" : "" ) + string( hours ) + ":" + ( minutes < 10 ? "0" : "" ) + string( minutes ) + ":" + ( seconds < 10 ? "0" : "" ) + string( seconds );

                string IP = g_EngineFuncs.CVarGetString( "ip" );
                if( IP == "localhost" )
                {
                    if( g_PlayerFuncs.FindPlayerByIndex( 1 ) !is null )
                        IP = g_EngineFuncs.GetPlayerAuthId( g_PlayerFuncs.FindPlayerByIndex( 1 ).edict() );
                }

                pFile.Write( "{\n");
                pFile.Write( "    \"HOSTNAME\": \"" + g_EngineFuncs.CVarGetString( "hostname" ) + "\",\n" );
                pFile.Write( "    \"IP\": \"" + g_EngineFuncs.CVarGetString( "ip" ) + "\",\n" );
                pFile.Write( "    \"MAP\": \"" + string( g_Engine.mapname ) + "\",\n" );
                if( pJson.getboolean( "STATUS_PLAYERS:LOG" ) )
                    pFile.Write( "    \"PLAYERS\": \"" + string( t ) + "/" + string( g_Engine.maxClients ) + "\",\n" );
                if( pJson.getboolean( "STATUS_ALIVEPLAYERS:LOG" ) )
                    pFile.Write( "    \"STATUS_ALIVEPLAYERS\": \"" + string( a ) + "/" + string( t ) + "\",\n" );
                if( pJson.getboolean( "STATUS_CHECKPOINTS:LOG" ) )
                    pFile.Write( "    \"CURRENT_CHECKPOINTS\": \"" + string( c ) + "\",\n" );
                if( pJson.getboolean( "STATUS_RESTARTS:LOG" ) )
                    pFile.Write( "    \"RESTARTS\": \"" + string( restarts ) + "" + "\",\n" );
                if( pJson.getboolean( "STATUS_MAPTIME:LOG" ) )
                    pFile.Write( "    \"MAPTIME\": \"" + string( m_szTime ) + "\",\n" );
                pFile.Write( "    \"STATUS\":\n" );
                pFile.Write( "    {\n" );

                int writted = 0;
                for( int i = 1; i <= g_Engine.maxClients; i++ )
                {
                    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex( i );

                    if( pPlayer is null )
                        continue;

                    if( writted++ > 25 )
                        break;

                    if( writted > 1 )
                        pFile.Write( ",\n" );

                    pFile.Write( "        \"" + string( i ) + "\":\n" );
                    pFile.Write( "        {\n" );
                    pFile.Write( "            \"name\": \"" + string( pPlayer.pev.netname ) + "\",\n" );
                    pFile.Write( "            \"score\": \"" + string( int(pPlayer.pev.frags) ) + "/" + pPlayer.m_iDeaths + "\",\n" );
                    pFile.Write( "            \"state\": \"" + ParseLanguage( pJson, ( pPlayer.IsAlive() ? "MSG_ALIVE" : pPlayer.GetObserver().IsObserver() ? "MSG_OBSERVER" : "MSG_DEAD" ) ) + "\"\n" );
                    pFile.Write( "        }" );
                }
                pFile.Write( "\n    }\n" );

                pFile.Write( "}\n" );
                pFile.Close();
            }
        }
    }
}