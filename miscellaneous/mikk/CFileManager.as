class CMKFileManager
{
    void GetMultiLanguageMessages( dictionary& out g_Dictionary, const string& in m_iszPath )
    {
        File@ pFile = g_FileSystem.OpenFile( m_iszPath, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            g_Game.AlertMessage( at_error, '[CMKFileManager] WARNING! Can not open file "'+ m_iszPath + '" No messages loaded.' + '\n' );
            return;
        }

        string m_iszLine, m_iszLabel;

        bool matched = false;

        dictionary g_Label;

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( m_iszLine );

            if( m_iszLine.Length() < 1 || m_iszLine[0] == '{' || m_iszLine[0] == ';' )
            {
                continue;
            }

            if( matched )
            {
                if( m_iszLine[0] == '}' )
                {
                    g_Dictionary[ m_iszLabel ] = g_Label;
                    g_Game.AlertMessage( at_console, 'added label ' + m_iszLabel + ' g_Label ' + string( g_Label[ 'english' ] ) + '\n' );
                    g_Label.deleteAll();
                    matched = false;
                    continue;
                }

                array<string> strSplits = { String::EMPTY_STRING, String::EMPTY_STRING };

                strSplits = m_iszLine.Split( ':' );

                // Fix for my own split :$
                if( strSplits.length() > 2 )
                {
                    string m_iszFix = strSplits[1];

                    for( uint ui = 2; ui < strSplits.length(); ui++ )
                    {
                        m_iszFix = m_iszFix + ':' + strSplits[ui];
                    }

                    g_Label[ MakeQuotaString( strSplits[0] ) ] = MakeQuotaString( m_iszFix );
                }
                else if( strSplits.length() == 2 )
                {
                    g_Label[ MakeQuotaString( strSplits[0] ) ] = MakeQuotaString( strSplits[1] );
                }
            }
            else
            {
                m_iszLabel = m_iszLine;
                matched = true;
            }
        }
        pFile.Close();
    }

    bool IsPluginInstalled( string m_iszPluginName, bool bCaseSensitive = false )
    {
        array<string> PluginsList = g_PluginManager.GetPluginList();

        if( bCaseSensitive )
        {
            return ( PluginsList.find( m_iszPluginName ) >= 0 );
        }

        for( uint ui = 0; ui < PluginsList.length(); ui++ )
        {
            if( PluginsList[ui].ToLowercase() == m_iszPluginName.ToLowercase() )
            {
                return true;
            }
        }
        return false;
    }

    string MakeQuotaString( string m_iszString )
    {
        m_iszString = m_iszString.SubString( m_iszString.Find( '"' ) + 1, m_iszString.Length() );
        m_iszString = m_iszString.SubString( 0, m_iszString.Find( '"' ) );
        return m_iszString;
    }

    bool GetKeyAndValue( const string iszFileLoad, dictionary & out g_KeyValues, const bool blReplaceDict = false )
    {
        string line, key, value;

        File@ pFile = g_FileSystem.OpenFile( iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            return false;
        }

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

            if( blReplaceDict )
            {
                g_KeyValues[ key ] = value;
            }
            else if( string( g_KeyValues[ key ] ).IsEmpty() )
            {
                g_KeyValues[ key ] = value;
            }
        }
        pFile.Close();
        return true;
    }

    bool IsStringInFile( const string m_iszPath, string m_iszComparator, const bool bLowerCase = true )
    {
        File@ pFile = g_FileSystem.OpenFile( m_iszPath, OpenFile::READ );

        if( pFile is null || !pFile.IsOpen() )
        {
            return false;
        }

        if( bLowerCase )
        {
            m_iszComparator.ToLowercase();
        }

        string line;
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
                    return true;
                }
            }
            else if( m_iszComparator.StartsWith( '*' ) )
            {
                SubString.SubString( 1, SubString.Length() );

                if( line.Find( SubString ) != Math.SIZE_MAX )
                {
                    return true;
                }
            }
        }
        pFile.Close();
        return false;
    }

    bool LoadEntFile( const string iszFileLoad, string iszClassname = String::INVALID_INDEX )
    {
        string line, key, value;
        dictionary g_Keyvalues;

        File@ pFile = g_FileSystem.OpenFile( iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            return false;
        }

        while( !pFile.EOFReached() )
        {
            pFile.ReadLine( line );

            if( line.Length() < 1 || line[0] == '/' && line[1] == '/' || line[0] == '{' )
            {
                continue;
            }

            if( line[0] == '}' )
            {
                if( iszClassname != String::INVALID_INDEX )
                {
                    g_Keyvalues[ 'classname' ] = iszClassname;
                }

                g_Keyvalues.deleteAll();
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            g_Keyvalues[ key ] = value;
        }
        pFile.Close();

        return true;
    }
}