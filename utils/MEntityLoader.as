/*
-debug init entities DEBUG_LEVEL_ALMOST
*/

MEntityLoader m_EntityLoader;

final class MEntityLoader
{
    bool LoadFromFile( const string iszFileLoad, string iszClassname = String::INVALID_INDEX )
    {
        string line, key, value;
        dictionary g_Keyvalues;

        File@ pFile = g_FileSystem.OpenFile( iszFileLoad, OpenFile::READ );

        if( pFile is null or !pFile.IsOpen() )
        {
            m_Debug.Server( '[MEntityLoader::LoadFromFile] Can not open \'' + iszFileLoad + '\' entities not initialised!', DEBUG_LEVEL_IMPORTANT );
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

                if( m_EntityFuncs.CreateEntity( g_Keyvalues ) !is null )
                    m_Debug.Server( '[MEntityLoader::LoadFromFile] Initialised "'+string(g_Keyvalues[ 'classname' ])+'"', DEBUG_LEVEL_ALMOST );
                else
                    m_Debug.Server( '[MEntityLoader::LoadFromFile] Failed to Initialise"'+string(g_Keyvalues[ 'classname' ])+'"', DEBUG_LEVEL_ALMOST );
                m_Debug.Server( '[MEntityLoader::LoadFromFile] =====================================', DEBUG_LEVEL_ALMOST );

                g_Keyvalues.deleteAll();
                continue;
            }

            key = line.SubString( 0, line.Find( '" "') );
            key.Replace( '"', '' );

            value = line.SubString( line.Find( '" "'), line.Length() );
            value.Replace( '" "', '' );
            value.Replace( '"', '' );

            g_Keyvalues[ key ] = value;
            m_Debug.Server( '[MEntityLoader::LoadFromFile] "' + key + '"" "' + value + '"', DEBUG_LEVEL_ALMOST );
        }
        pFile.Close();

        m_Debug.Server( '[MEntityLoader::LoadFromFile] Finished reading "' + iszFileLoad + '"', DEBUG_LEVEL_IMPORTANT );
        return true;
    }
}