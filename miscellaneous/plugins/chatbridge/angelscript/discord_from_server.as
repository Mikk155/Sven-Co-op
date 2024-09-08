void ParseMSG( const string &in m_szMessage )
{
    if( !m_szMessage.IsEmpty() )
        discord_from_server::m_szWritte += m_szMessage + "\n";
}

namespace discord_from_server
{
    string m_szWritte;

    const string szPath = 'scripts/plugins/store/discord_from_server.txt';

    void PluginInit()
    {
        g_FileSystem.RemoveFile( szPath );
    }

    void Write()
    {
        if( !m_szWritte.IsEmpty() )
        {
            File@ pFile = g_FileSystem.OpenFile( szPath, OpenFile::APPEND );

            if( pFile !is null && pFile.IsOpen() )
            {
                dictionary pReplacement = pJson.getlabel( "REPLACE" );
                pReplacement[ "@everyone" ] = "~everyone";
                pReplacement[ "@here" ] = "~here";

                const array<string> strFrom = pReplacement.getKeys();

                for( uint i = 0; i < strFrom.length(); i++ )
                    m_szWritte.Replace( strFrom[i], string( pReplacement[ strFrom[i] ] ) );

                pFile.Write( '\n' + m_szWritte );
                m_szWritte = String::EMPTY_STRING;
                pFile.Close();
            }
        }
    }
}