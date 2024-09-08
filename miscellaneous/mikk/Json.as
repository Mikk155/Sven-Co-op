class JSon
{
    dictionary labels;

    // prefix: "get"
    // description: Return the string of the given label in the JSon@ class
    string get( const string &in m_szFind )
    {
        string szString = String::EMPTY_STRING;
        array<string> strLabels = m_szFind.Split( ":" );

        if( strLabels.length() <= 1 )
        {
            szString = string( labels[ m_szFind ] );
        }
        else
        {
            dictionary plabel = getlabel( m_szFind.SubString( m_szFind.Find( ":", 0 ) + 1, m_szFind.Length() ) );
            szString = string( plabel[ strLabels[0] ] );
        }

        if( szString.StartsWith( "\"" ) && szString.EndsWith( "\"" ) )
        {
            szString = szString.SubString( 1, szString.Length() );
            szString = szString.SubString( 0, szString.Find( "\"", 0 ) );
        }

        return szString;
    }

    // prefix: "getlabel"
    // description: Return the dictionary of the given label in the JSon@ class
    dictionary getlabel( const string &in m_szFind )
    {
        array<string> strLabels = m_szFind.Split( ";" );

        dictionary pTemp = labels;

        for( uint i = 0; i < strLabels.length(); i++ )
        {
            pTemp = dictionary( pTemp[ strLabels[i] ] );
        }

        return pTemp;
    }

    // prefix: "getboolean"
    // description: Return the state of the given boolean in the JSon@ class
    bool getboolean( const string &in m_szFind )
    {
        string b = get( m_szFind );
        return ( b == "true" || b == "1" );
    }
}

class MKJson
{
    // prefix: "Mikk.Json.ReadJsonFile", "Parse", "Json"
    // description: Loads and parses a json file for configuring scripts via a JSon@ class
    // body: Mikk.Json
    JSon ReadJsonFile( const string &in m_szPath, JSon@ pJson = null )
    {
        if( m_szPath.IsEmpty() )
            return pJson;

        File@ pFile = g_FileSystem.OpenFile(
            ( m_szPath.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szPath +
            ( m_szPath.EndsWith( '.json' ) ? '' : '.json' ), OpenFile::READ
        );

        if( pFile is null || !pFile.IsOpen() )
            return pJson;

        bool Parsing = false;
        string line;
        dictionary Parse;

        dictionary g_Groups;
        int groups = -1;
        string lastGroup;

        g_Game.AlertMessage( at_console, "===========================================\n" );
        while( !pFile.EOFReached() )
        {
            string key, value;

            pFile.ReadLine( line );

            while( line[0] == " " )
                line = line.SubString( 1, line.Length() );

            if( line.Length() < 1 || line[0] == "/" && line[1] == "/" )
            {
                line = String::EMPTY_STRING;
                continue;
            }

            if( line[0] == "{" )
            {
                groups++;
                if( !lastGroup.IsEmpty() )
                    g_Groups[ groups ] = lastGroup;
                lastGroup = String::EMPTY_STRING;
                continue;
            }
            else if( line[0] == "}" )
            {
                groups--;
                continue;
            }

            if( line[0] == "\"" )
            {
                key = line.SubString( 1, line.Find( "\"", 1, String::CaseInsensitive ) - 1 );

                lastGroup = key;

                value = line.SubString( line.Find( ":", key.Length() ) + 1, line.Length() );

                while( value[0] == " " )
                    value = value.SubString( 1, value.Length() );

                if( value[0] == "{" )
                {
                    groups++;
                    g_Groups[ groups ] = key;
                    lastGroup = String::EMPTY_STRING;
                    continue;
                }
            }

            if( value.Find( ",", 0 ) > 0 )
                value = value.SubString( 0, value.RFind( ",", 0 ) );

            if( groups > 0 )
            {
                dictionary pTemp = pJson.labels;
                array<dictionary> pGroupInfo;

                for( int i = groups; i > 0; i-- )
                {
                    pTemp = dictionary( pTemp[ string( g_Groups[ groups ] ) ] );

                    if( i == groups )
                    {
                        pTemp[ key ] = value;
                        g_Game.AlertMessage( at_console, "[JSON] \"" + string( g_Groups[ i ] ) + "\" -> \"" + key + "\" -> " + value + "\n" );
                    }
                    pGroupInfo.insertLast( pTemp );
                }

                dictionary pTemp2 = pGroupInfo[ pGroupInfo.length() - 1 ];
                for( ; pGroupInfo.length() > 1; pGroupInfo.removeAt( pGroupInfo.length() - 1 ) )
                {
                    pTemp2[ string( g_Groups[ pGroupInfo.length() ] ) ] = pGroupInfo[ pGroupInfo.length() - 1 ];
                }

                pJson.labels[ string( g_Groups[ groups ] ) ] = pTemp2;
            }
            else
            {
                pJson.labels[ key ] = value;
            }

            if( groups == -1 )
                break;
        }

/*
Debug purposes, actually only works on two dictionary, i have to figure out what i am doing wrong

For example this will work
{
    "Group 1":
    {
        "Group 2":
        {
            "SI": true
        }
    }
}
This won't work
{
    "Group 1":
    {
        "Group 2":
        {
            "Group 3":
            {
                "SI": true
            }
        }
    }
}

const array<string> s1 = pJson.labels.getKeys();
dictionary d2 = dictionary( pJson.labels[ "Grupo 1" ] );
const array<string> s2 = d2.getKeys();
dictionary d3 = dictionary( d2[ "Grupo 2" ] );
const array<string> s3 = d3.getKeys();

g_Game.AlertMessage( at_console, "| ===========================================\n" );

for(uint i1 = 0; i1 < s1.length(); i1++)
{
    g_Game.AlertMessage( at_console, "| " + s1[i1] + " \"" + ( string( pJson.labels[ s1[i1] ] ).IsEmpty() ? "Dictionary" : string( pJson.labels[ s1[i1] ] ) ) + "\"\n" );
}
g_Game.AlertMessage( at_console, "===========================================\n" );

for(uint i2 = 0; i2 < s2.length(); i2++)
{
    g_Game.AlertMessage( at_console, "| " + s2[i2] + " \"" + ( string( d2[ s2[i2] ] ).IsEmpty() ? "Dictionary" : string( d2[ s2[i2] ] ) ) + "\"\n" );
}
g_Game.AlertMessage( at_console, "===========================================\n" );
for(uint i3 = 0; i3 < s3.length(); i3++)
{
    g_Game.AlertMessage( at_console, "| " + s3[i3] + " \"" + ( string( d3[ s3[i3] ] ).IsEmpty() ? "Dictionary" : string( d3[ s3[i3] ] ) ) + "\"\n" );
}
*/
        pFile.Close();
        return pJson;
    }
}