namespace meta_api
{
    namespace json
    {
        /**
        *   @brief Deserializes str into obj
        **/
        bool Deserialize( const string&in str, dictionary&out obj )
        {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return g_EngineFuncs.JsonDeserialize( str, obj );
#endif
            // Make a copy to work with
            string serialized = str;

            // Is this a file we need to open?
            if( str.StartsWith( "scripts/" ) )
            {
                if( !str.EndsWith( ".json" ) )
                {
                    g_Game.AlertMessage( at_console, "[JSON] Only .json format files can be parsed.\n" );
                    return false;
                }

                auto file = g_FileSystem.OpenFile( str, OpenFile::READ );

                if( file is null || !file.IsOpen() )
                {
                    g_Game.AlertMessage( at_console, "[JSON] Couldn't open file %1\n", str );
                    return false;
                }

                serialized = String::EMPTY_STRING;

                while( !file.EOFReached() )
                {
                    string line;
                    file.ReadLine( line );

                    // Saves some time when iterating the characters.
                    line.Trim( ' ' );

                    if( line.IsEmpty() || ( line[0] == '/' && line[1] == '/' ) )
                        continue;

                    serialized += line;
                }
            }

            return true;
        }

#if FALSE
        /**
        *   @brief Serializes a obj into str with the given indents
        **/
        bool Serialize( dictionary@ obj, string&out str, int indents = -1 )
        {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return g_EngineFuncs.JsonSerialize( obj, str, indents );
#endif
            // -TODO manual dictionary parsing
            return false;
        }
#endif

        /**
        *   @brief Return whatever the given obj has an object at key containing the current map name in it.
        **/
        bool IsMapListed( dictionary@ obj, const string&in key = "map_blacklist" )
        {
            dictionary map_blacklist;
            if( obj.get( key, map_blacklist ) )
            {
                string mapname = string( g_Engine.mapname );

                for( uint ui = 0; ui < map_blacklist.getSize(); ui++ )
                {
                    if( mapname == string( map_blacklist[ ui ] ) )
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}
