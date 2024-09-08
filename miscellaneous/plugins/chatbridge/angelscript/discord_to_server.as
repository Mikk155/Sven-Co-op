namespace discord_to_server
{
    array<string> m_szRead;

    const string szPath = 'scripts/plugins/store/discord_to_server.txt';

    void PluginInit()
    {
        g_FileSystem.RemoveFile( szPath );
    }

    void Read()
    {
        File@ pRead = g_FileSystem.OpenFile( szPath, OpenFile::READ );

        if( pRead !is null && pRead.IsOpen() )
        {
            string line;
            while( !pRead.EOFReached() )
            {
                pRead.ReadLine( line );

                if( line.Length() >= 1 )
                    m_szRead.insertLast( line );
            }
            pRead.Close();
            g_FileSystem.RemoveFile( szPath );
        }
    }

    void PrintMessage()
    {
        for( int i = 0; i < atoi( pJson.get( "MESSAGES_PER_SECOND:BOT" ) ) && m_szRead.length() > 1 && m_szRead[0] != "" && !m_szRead[0].IsEmpty(); i++ )
        {
            if( pJson.get( "PREFIX:BOT" ) != "" && m_szRead[0][0] == pJson.get( "PREFIX:BOT" ) )
            {
                string command = m_szRead[0].SubString( 1, m_szRead[0].Length() );

                if( command != "" )
                {
                    g_EngineFuncs.ServerCommand( command + '\n' );
                    g_EngineFuncs.ServerExecute();

                    if( pJson.getboolean( "ADMIN_COMMAND:LOG" ) )
                    {
                        dictionary pReplacement;
                        pReplacement["cmd"] = "\"" + command + "\"";
                        string msg = ParseLanguage( pJson, "MSG_MOD_COMMAND", pReplacement );
                        g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, msg + "\n" );
                        ParseMSG( msg );
                    }
                }
            }
            else
            {
                g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, m_szRead[0] + "\n" );

                if( pJson.getboolean( "BRIDGE_RELOG:LOG" ) )
                    ParseMSG( m_szRead[0] );
            }

            m_szRead.removeAt(0);
        }
    }
}