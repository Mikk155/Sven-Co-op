namespace meta_api
{
    namespace json
    {
        uint __position__;
        uint __size__;

        // Lambda used for AS string parsing
        funcdef dictionary __ParseObject__( const string&in serialized, __ParseObject__@ ParseObject, __ParseObject__@ ParseArray );

        /**
        *   @brief Deserializes str into obj, if file is true then str is a path to a file
        **/
        bool Deserialize( const string&in str, dictionary&out obj, bool file = false )
        {
            // AS copy
            string serialized = String::EMPTY_STRING;

            if( file )
            {
                string filename;
                snprintf( filename, "scripts/%1/%2.json", ( g_Module.GetModuleName() =="MapModule" ? "maps" : "plugins" ), str );

#if METAMOD_PLUGIN_ASLP
            if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
                return g_EngineFuncs.JsonDeserialize( filename, obj );
#endif

                auto fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                if( fstream is null || !fstream.IsOpen() )
                {
                    g_Game.AlertMessage( at_console, "[JSON] Error: Couldn't open file \"%1\"\n", filename );
                    return false;
                }

                while( !fstream.EOFReached() )
                {
                    string line;
                    fstream.ReadLine( line );

                    // Saves some time when iterating the characters.
                    line.Trim( ' ' );

                    if( line.IsEmpty() || ( line[0] == '/' && line[1] == '/' ) )
                        continue;

                    serialized += line;
                }
            }

#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return g_EngineFuncs.JsonDeserialize( str, obj );
#endif

            if( !file )
            {
                serialized = str;
                serialized.Trim( ' ' );
            }

            auto ParseObject = __ParseObject__( function( const string&in serialized, __ParseObject__@ ParseObject, __ParseObject__@ ParseArray )
            {
                dictionary obj;

                string key = String::EMPTY_STRING;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;
                
                bool reading_key = true;
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( __position__ < __size__ )
                {
                    char c( serialized[__position__] );

                    __position__++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( in_string )
                    {
                        if( c == '"' && !was_escaped )
                        {
                            in_string = false;
                            
                            if( !reading_key )
                            {
                                value_is_string = true;
                            }
                            
                            continue;
                        }
                        else if( c == '\\' && !was_escaped )
                        {
                            is_escaped = true;
                            continue;
                        }

                        if( was_escaped )
                        {
                            if( c == 'n' ) c = '\n';
                            else if( c == 't' ) c = '\t';
                            else if( c == 'r' ) c = '\r';
                        }

                        if( reading_key )
                        {
                            key += c;
                        }
                        else
                        {
                            value += c;
                        }
                    }
                    else if( c == '"' )
                    {
                        if( reading_key && key != String::EMPTY_STRING )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Expected ':' after key\n", string( __position__ ) );
                            return obj;
                        }
                        else if( !reading_key && ( value != String::EMPTY_STRING || value_is_string || just_parsed_child ) )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' after value for key \"%2\"\n", string( __position__ ), key );
                            return obj;
                        }

                        in_string = true;
                    }
                    else if( c == ':' )
                    {
                        if( !reading_key )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Unexpected colon ':' in value\n", string( __position__ ) );
                            return obj;
                        }
                        if( key == String::EMPTY_STRING )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Found ':' without a preceding valid key\n", string( __position__ ) );
                            return obj;
                        }

                        reading_key = false;
                    }
                    else if( c == '{' )
                    {
                        if( reading_key )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Objects are not allowed as keys\n", string( __position__ ) );
                            return obj;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' before opening a new object\n", string( __position__ ) );
                            return obj;
                        }

                        obj[ key ] = ParseObject( serialized, ParseObject, ParseArray );
                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( reading_key )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Arrays are not allowed as keys\n", string( __position__ ) );
                            return obj;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' before opening an array\n", string( __position__ ) );
                            return obj;
                        }

                        obj[ key ] = ParseArray( serialized, ParseObject, ParseArray );
                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == '}' )
                    {
                        if( c == ',' && reading_key && key == String::EMPTY_STRING )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Unexpected comma ','. Expected a key\n", string( __position__ ) );
                            return obj;
                        }

                        if( key != String::EMPTY_STRING )
                        {
                            if( !reading_key && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                            {
                                g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing value for key \"%2\"\n", string( __position__ ), key );
                                return obj;
                            }

                            if( value_is_string )
                            {
                                obj[ key ] = value;
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj[ key ] = atof( value );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj[ key ] = atoi( value );
                            }
                            else if( value == "false" )
                            {
                                obj[ key ] = false;
                            }
                            else if( value == "true" )
                            {
                                obj[ key ] = true;
                            }
                            else if( value == "null" )
                            {
                                obj[ key ] = null;
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj[ key ] = value;
                            }
                        }

                        key = String::EMPTY_STRING;
                        value = String::EMPTY_STRING;
                        reading_key = true;
                        value_is_string = false;
                        just_parsed_child = false;

                        if( c == '}' )
                        {
                            break;
                        }
                    }
                    else if( c != ' ' && c != '\n' && c != '\r' && c != '\t' )
                    {
                        if( reading_key )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Keys must be enclosed in quotes. Invalid character: \"%2\"\n", string( __position__ ), string( c ) );
                            return obj;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child )
                            {
                                g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' after value for key \"%2\"\n", string( __position__ ), key );
                                return obj;
                            }

                            value += c;
                        }
                    }
                }

                return obj;
            } );

            auto ParseArray = __ParseObject__( function( const string&in serialized, __ParseObject__@ ParseObject, __ParseObject__@ ParseArray )
            {
                dictionary obj;

                uint item_index = 0;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;
                
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( __position__ < __size__ )
                {
                    char c( serialized[__position__] );

                    __position__++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( in_string )
                    {
                        if( c == '"' && !was_escaped )
                        {
                            in_string = false;
                            value_is_string = true;
                            continue;
                        }
                        else if( c == '\\' && !was_escaped )
                        {
                            is_escaped = true;
                            continue;
                        }

                        if( was_escaped )
                        {
                            if( c == 'n' ) c = '\n';
                            else if( c == 't' ) c = '\t';
                            else if( c == 'r' ) c = '\r';
                        }

                        value += c;
                    }
                    else if( c == '"' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing separating ',' in array before quotes\n", string( __position__ ) );
                            return obj;
                        }

                        in_string = true;
                    }
                    else if( c == '{' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' before opening an object in array\n", string( __position__ ) );
                            return obj;
                        }

                        obj[ string( item_index ) ] = ParseObject( serialized, ParseObject, ParseArray );
                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing ',' before opening a sub-array\n", string( __position__ ) );
                            return obj;
                        }

                        obj[ string( item_index ) ] = ParseArray( serialized, ParseObject, ParseArray );
                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == ']' )
                    {
                        if( c == ',' && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Duplicate comma ',' or empty value in array\n", string( __position__ ) );
                            return obj;
                        }

                        bool has_data = ( value != String::EMPTY_STRING ) || value_is_string || just_parsed_child;

                        if( has_data )
                        {
                            if( value_is_string )
                            {
                                obj[ string( item_index ) ] = value;
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj[ string( item_index ) ] = atof( value );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj[ string( item_index ) ] = atoi( value );
                            }
                            else if( value == "false" )
                            {
                                obj[ string( item_index ) ] = false;
                            }
                            else if( value == "true" )
                            {
                                obj[ string( item_index ) ] = true;
                            }
                            else if( value == "null" )
                            {
                                obj[ string( item_index ) ] = null;
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj[ string( item_index ) ] = value;
                            }

                            item_index++;
                        }

                        value = String::EMPTY_STRING;
                        value_is_string = false;
                        just_parsed_child = false;

                        if( c == ']' )
                        {
                            break;
                        }
                    }
                    else if( c != ' ' && c != '\n' && c != '\r' && c != '\t' )
                    {
                        if( value_is_string || just_parsed_child )
                        {
                            g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Missing separating ',' in array\n", string( __position__ ) );
                            return obj;
                        }

                        value += c;
                    }
                }

                return obj;
            } );

            __size__ = serialized.Length();

            if( __size__ == 0 )
            {
                g_Game.AlertMessage( at_console, "[JSON] Error: The provided string is empty\n" );
                return false;
            }

            uint start_idx = 0;

            while( start_idx < __size__ )
            {
                char check( serialized[start_idx] );
                
                if( check == ' ' || check == '\n' || check == '\r' || check == '\t' )
                {
                    start_idx++;
                }
                else
                {
                    break;
                }
            }

            if( start_idx >= __size__ )
            {
                g_Game.AlertMessage( at_console, "[JSON] Error: The provided string only contains whitespaces\n" );
                return false;
            }

            char c( serialized[start_idx] );
            __position__ = start_idx + 1;

            if( c == '[' )
            {
                obj = ParseArray( serialized, ParseObject, ParseArray );
            }
            else if( c == '{' )
            {
                obj = ParseObject( serialized, ParseObject, ParseArray );
            }
            else
            {
                g_Game.AlertMessage( at_console, "[JSON] Error (Pos %1): Invalid format. Expected '{' or '[' at the beginning of the JSON\n", string( start_idx ) );
                return false;
            }

            __position__ = __size__ = 0;

            return !( obj.isEmpty() );
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
