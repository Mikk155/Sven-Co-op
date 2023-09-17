MVirtualFileSystem m_FileSystem;

final class MVirtualFileSystem
{
    bool IsStringInFile( const string m_iszPath, string m_iszComparator, const bool bLowerCase = true )
    {
        string asname = "[MVirtualFileSystem::IsStringInFile] ";

        File@ pFile = g_FileSystem.OpenFile( m_iszPath, OpenFile::READ );

        if( pFile is null || !pFile.IsOpen() )
        {
            m_Debug.Server( asname+"Can NOT open file '" + m_iszPath + "'" );
            return false;
        }

        if( bLowerCase )
        {
            m_iszComparator.ToLowercase();
        }

        string line, iszt;
        bool bMatched = false;

        while( !pFile.EOFReached() )
        {
            string SubString = m_iszComparator;
            pFile.ReadLine( line );
            line.Trim();

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' )
                continue;

            line.ToLowercase();

            if( m_iszComparator == line )
            {
                bMatched = true;
                pFile.Close();
                break;
            }
            else if( m_iszComparator.EndsWith( '*' ) )
            {
                SubString.SubString( 0, SubString.Length()-1 );

                if( line.Find( SubString ) != Math.SIZE_MAX )
                {
                    bMatched = true;
                    iszt = "with ending wildcard";
                    break;
                }
            }
            else if( m_iszComparator.StartsWith( '*' ) )
            {
                SubString.SubString( 1, SubString.Length() );

                if( line.Find( SubString ) != Math.SIZE_MAX )
                {
                    bMatched = true;
                    iszt = "with starting wildcard";
                    break;
                }
            }
        }

        pFile.Close();

        m_Debug.Server( asname+"Opened file '" + m_iszPath + "' for matching string '" + m_iszComparator + "'" );

        if( bMatched )
        {
            m_Debug.Server( asname+"Match '" + line + "' "+iszt );
            return true;
        }

        m_Debug.Server( asname+"Nothing matched in the file." );

        return false;
    }

    bool GetKeyAndValue( const string iszFileLoad, dictionary & out g_KeyValues, const bool blReplaceDict = false )
    {
        string line, key, value;

        File@ pFile = g_FileSystem.OpenFile( /* 'scripts/maps/' + */ iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            m_Debug.Server( 'GetKeyAndValue Can not open file '+ iszFileLoad + ' No dictionary loaded.' );
            return false;
        }

        m_Debug.Server( 'GetKeyAndValue Se abrio '+ iszFileLoad + '.' );

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' and line[1] == '/' )
            {
                continue;
            }

            key = line.SubString( 1, line.Find( '" "' ) - 1 );

            value = line.SubString( line.Find( '" "' ) + 3, line.Length() );

            value = value.SubString( 0, value.Length() - 1 );

            /*
            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );*/

    
            if( blReplaceDict )
            {
                g_KeyValues[ key ] = value;
            }
            else if( string( g_KeyValues[ key ] ).IsEmpty() )
            {
                g_KeyValues[ key ] = value;
            }
            m_Debug.Server( '('+key+') ('+value+')', DEBUG_LEVEL_ALMOST );
        }
        pFile.Close();
        return true;
    }
}