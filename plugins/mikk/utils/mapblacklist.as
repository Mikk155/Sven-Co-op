void mapblacklist( const string &in m_iszConfigFile, bool &out m_bMatched )
{
    m_bMatched = false;

    File@ pFile = g_FileSystem.OpenFile( m_iszConfigFile, OpenFile::READ );

    if( pFile is null || !pFile.IsOpen() )
    {
        g_Game.AlertMessage( at_console, 'Can NOT open "' + m_iszConfigFile + '"\n' );
        return;
    }
 
    string strMap = string( g_Engine.mapname );

    strMap.ToLowercase();

    string line;

    while( !pFile.EOFReached() )
    {
        pFile.ReadLine( line );
        line.Trim();

        if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
        {
            continue;
        }

        line.ToLowercase();

        if( strMap == line )
        {
            m_bMatched = true;
            return;
        }

        if( line.EndsWith( "*", String::CaseInsensitive ) )
        {
            line = line.SubString( 0, line.Length()-1 );

            if( strMap.Find( line ) != Math.SIZE_MAX )
            {
                m_bMatched = true;
                return;
            }
        }
    }
    pFile.Close();
}