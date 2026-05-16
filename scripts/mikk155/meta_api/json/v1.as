#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 1 of Json. conversion to/from dictionary.
        /// Array items are converted into a dictionary object where the key names are the item indexing.
        namespace v1
        {
            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return {}
            **/
            bool Deserialize( const string&in str, dictionary&out obj )
            {
                __Position__ = __Size__ = 0;

                // AS copy
                string serialized = String::EMPTY_STRING;

                string filename;
                if( GetFilename( str, filename ) )
                {
                    print( snprintf( cout, "Reading file \"%1\"", filename ), Version::V1 );

/// Metamod handles this with the internal file system getting the whole buffer in one go
#if METAMOD_PLUGIN_ASLP
                    if( __METAMOD__ ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
                    {
                        if( !aslp::json::Deserialize( filename, obj ) )
                        {
                            print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ), Version::V1 );
                            return false;
                        }
                        return true;
                    }
#endif
/// Otherwise we use the shit API to read line by line x[

                    auto fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                    if( fstream is null || !fstream.IsOpen() )
                    {
                        print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ), Version::V1 );
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

                    fstream.Close();
                }

                // No file loaded?
                if( serialized.IsEmpty() )
                {
                    serialized = str;
                    serialized.Trim( ' ' ); // Saves on iterations
                }

/// Metamod handles this with the internal nlohmann/json library
#if METAMOD_PLUGIN_ASLP
                if( __METAMOD__ ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
                {
                    if( !aslp::json::Deserialize( serialized, obj ) )
                    {
                        print( "ERROR: could not parse object", Version::V1 );
                        return false;
                    }
                    return true;
                }
#endif
/// Otherwise we read the string in AS char by char x[

                __Size__ = serialized.Length();

                if( __Size__ == 0 )
                {
                    print( "Error: The provided string is empty", Version::V1 );
                    return false;
                }

                uint start_idx = 0;

                while( start_idx < __Size__ )
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

                if( start_idx >= __Size__ )
                {
                    print( "Error: The provided string only contains whitespaces", Version::V1 );
                    return false;
                }

                char c( serialized[start_idx] );
                __Position__ = start_idx + 1;

                if( c == '[' )
                {
                    if( !ParseArray( serialized, obj ) )
                        return false;
                }
                else if( c == '{' )
                {
                    if( !ParseObject( serialized, obj ) )
                        return false;
                }
                else
                {
                    print( snprintf( cout, "ERROR: (Pos %1): Invalid format. Expected '{' or '[' at the beginning of the JSON", string( start_idx ) ), Version::V1 );
                    return false;
                }

                return true;
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            **/
            string Serialize( int indents, dictionary@ obj )
            {
                return SerializeObject( obj, indents, 0 );
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            *   filename: a file name to write in "scripts/(module type)/store/(filename).json"
            *   Return whatever the content was written
            **/
            bool Serialize( dictionary@ obj, string filename, int indents = -1 )
            {
                snprintf( filename, "scripts/%1/store/%2.json", ( g_Module.GetModuleName() == "MapModule" ? "maps" : "plugins" ), filename );

                auto file = g_FileSystem.OpenFile( filename, OpenFile::WRITE );

                if( file !is null && file.IsOpen() )
                {
                    file.Write( Serialize( indents, obj ) );
                    file.Close();
                    return true;
                }

                print( snprintf( cout, "ERROR: Couldn't serialize content to \"%1\"", filename ), Version::V1 );

                return false;
            }

            bool ParseObject( const string&in serialized, dictionary@ obj = null )
            {
                obj.deleteAll();

                string key = String::EMPTY_STRING;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;
                
                bool reading_commentary = false;
                bool single_commentary = false;
                bool reading_key = true;
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( __Position__ < __Size__ )
                {
                    char c( serialized[__Position__] );

                    __Position__++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( reading_commentary )
                    {
                        if( single_commentary )
                        {
                            if( c == '\n' )
                                single_commentary = reading_commentary = false;
                        }
                        else if( c == '/' && serialized[__Position__ - 2] == '*' )
                        {
                            reading_commentary = false;
                        }
                        continue;
                    }
                    else if( in_string )
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
                            print( snprintf( cout, "ERROR: (Pos %1): Expected ':' after key", string( __Position__ ) ), Version::V1 );
                            return false;
                        }
                        else if( !reading_key && ( value != String::EMPTY_STRING || value_is_string || just_parsed_child ) )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( __Position__ ), key ), Version::V1 );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == ':' )
                    {
                        if( !reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Unexpected colon ':' in value", string( __Position__ ) ), Version::V1 );
                            return false;
                        }
                        if( key == String::EMPTY_STRING )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Found ':' without a preceding valid key", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        reading_key = false;
                    }
                    else if( c == '{' )
                    {
                        if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Objects are not allowed as keys", string( __Position__ ) ), Version::V1 );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a new object", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        dictionary objChild;
                        ParseObject( serialized, @objChild );
                        obj[ key ] = objChild;
                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Arrays are not allowed as keys", string( __Position__ ) ), Version::V1 );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an array", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        dictionary objChild;
                        ParseArray( serialized, @objChild );
                        obj[ key ] = objChild;
                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == '}' )
                    {
                        if( c == ',' && reading_key && key == String::EMPTY_STRING )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Unexpected comma ','. Expected a key", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        if( key != String::EMPTY_STRING )
                        {
                            if( !reading_key && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing value for key \"%2\"", string( __Position__ ), key ), Version::V1 );
                                return false;
                            }

                            if( value_is_string )
                            {
                                obj.set( key, value );
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj.set( key, atof( value ) );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj.set( key, atoi( value ) );
                            }
                            else if( value == "false" )
                            {
                                obj.set( key, false );
                            }
                            else if( value == "true" )
                            {
                                obj.set( key, true );
                            }
                            else if( value == "null" )
                            {
                                obj.set( key, string("__null__") );
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj.set( key, value );
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
                        if( c == '/' && serialized[__Position__] == '*' )
                        {
                            reading_commentary = true;
                        }
                        else if( c == '/' && serialized[__Position__] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                        }
                        else if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Keys must be enclosed in quotes. Invalid character: \"%2\"", string( __Position__ ), string( c ) ), Version::V1 );
                            return false;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( __Position__ ), key ), Version::V1 );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                return true;
            }

            bool ParseArray( const string&in serialized, dictionary@ obj )
            {
                obj.deleteAll();

                uint item_index = 0;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;

                bool reading_commentary = false;
                bool single_commentary = false;
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( __Position__ < __Size__ )
                {
                    char c( serialized[__Position__] );

                    __Position__++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( reading_commentary )
                    {
                        if( single_commentary )
                        {
                            if( c == '\n' )
                                single_commentary = reading_commentary = false;
                        }
                        else if( c == '/' && serialized[__Position__ - 2] == '*' )
                        {
                            reading_commentary = false;
                        }
                        continue;
                    }
                    else if( in_string )
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
                            print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array before quotes", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == '{' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an object in array", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        dictionary objChild;
                        ParseObject( serialized, @objChild );
                        obj.set( string( item_index ), objChild );
                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a sub-array", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        dictionary objChild;
                        ParseArray( serialized, @objChild );
                        obj.set( string( item_index ), objChild );
                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == ']' )
                    {
                        if( c == ',' && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Duplicate comma ',' or empty value in array", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        bool has_data = ( value != String::EMPTY_STRING ) || value_is_string || just_parsed_child;

                        if( has_data )
                        {
                            if( value_is_string )
                            {
                                obj.set( string( item_index ), value );
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj.set( string( item_index ), atof( value ) );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj.set( string( item_index ), atoi( value ) );
                            }
                            else if( value == "false" )
                            {
                                obj.set( string( item_index ), false );
                            }
                            else if( value == "true" )
                            {
                                obj.set( string( item_index ), true );
                            }
                            else if( value == "null" )
                            {
                                obj.set( string( item_index ), string("__null__") );
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj.set( string( item_index ), value );
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
                        if( c == '/' && serialized[__Position__] == '*' )
                        {
                            reading_commentary = true;
                        }
                        else if( c == '/' && serialized[__Position__] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array", string( __Position__ ) ), Version::V1 );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                return true;
            }

            string SerializeObject( dictionary@ obj, int indents, int depth )
            {
                if( obj is null )
                    return "{}";

                array<string>@ keys = obj.getKeys();
                
                if( keys.length() == 0 )
                {
                    return "{}";
                }

                bool is_array = true;
                for( uint i = 0; i < keys.length(); i++ )
                {
                    if( !obj.exists( string( i ) ) )
                    {
                        is_array = false;
                        break;
                    }
                }

                string newline = ( indents >= 0 ) ? "\n" : "";
                
                string indent_str = String::EMPTY_STRING;
                string indent_inner = String::EMPTY_STRING;

                if( indents > 0 )
                {
                    int inner_tabs = depth > 0 ? indents * depth : indents;
                    for( int i = 1; i <= inner_tabs; i++ )
                    {
                        indent_str += " ";
                    }

                    indent_inner = indent_str;
                    for( int i = 1; i <= indents; i++ )
                    {
                        indent_inner += " ";
                    }
                }

                string buffer = ( depth > 0 ? newline + indent_str : '' ) + ( is_array ? "[" : "{" ) + newline;

                for( uint ui = 0; ui < keys.length(); ui++ )
                {
                    string key = is_array ? string( ui ) : keys[ui];

                    buffer += ( depth > 0 ? indent_inner : indent_str );

                    if( !is_array )
                    {
                        string escaped_key = key;
                        escaped_key.Replace( "\\", "\\\\" );
                        escaped_key.Replace( "\"", "\\\"" );
                        escaped_key.Replace( "\n", "\\n" );
                        escaped_key.Replace( "\r", "\\r" );
                        escaped_key.Replace( "\t", "\\t" );
                        
                        buffer += "\"" + escaped_key + "\": ";
                    }

                    string strValue;
                    dictionary@ objValue = null; 
                    int iValue;
                    float fValue;

                    if( obj.get( key, strValue ) )
                    {
                        if( strValue == "__null__" )
                        {
                            buffer += "null";
                        }
                        else if( strValue == "false" )
                        {
                            buffer += "false";
                        }
                        else if( strValue == "true" )
                        {
                            buffer += "true";
                        }
                        else
                        {
                            strValue.Replace( "\\", "\\\\" );
                            strValue.Replace( "\"", "\\\"" );
                            strValue.Replace( "\n", "\\n" );
                            strValue.Replace( "\r", "\\r" );
                            strValue.Replace( "\t", "\\t" );
                            
                            buffer += "\"" + strValue + "\"";
                        }
                    }
                    else if( obj.get( key, @objValue ) )
                    {
                        buffer += SerializeObject( objValue, indents, depth + 1 );
                    }
                    else if( obj.get( key, fValue ) )
                    {
                        buffer += string( fValue );
                    }
                    else if( obj.get( key, iValue ) )
                    {
                        buffer += string( iValue );
                    }
                    else
                    {
                        buffer += "null";
                    }

                    if( ui < keys.length() - 1 )
                    {
                        buffer += "," + newline;
                    }
                    else
                    {
                        buffer += newline;
                    }
                }

                buffer += ( depth > 0 ? indent_str : '' ) + ( is_array ? "]" : "}" );

                return buffer;
            }

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

            /**
            *   @brief converts the given obj to a list of string.
            *   NOTE: Any type that is not a string will be skipped.
            **/
            array<string> ToArray( dictionary@ obj )
            {
                uint size = obj.getSize();

                array<string> List( size );

                for( uint ui = 0; ui < size; ui++ )
                {
                    string value;
                    if( !obj.get( string( ui ), value ) )
                        return {};
                    List[ ui ] = value;
                }

                return List;
            }

            /**
            *   @brief converts the given obj to a list of string.
            *   NOTE: Any type that is not a string will be skipped.
            **/
            array<string> ToArray( dictionaryValue&in obj )
            {
                return ToArray( cast<dictionary>( obj ) );
            }

            /**
            *   @brief converts the given obj to a list of dictionaryValue
            **/
            array<dictionaryValue> ToAnyArray( dictionary@ obj )
            {
                uint size = obj.getSize();

                array<dictionaryValue> List( size );

                for( uint ui = 0; ui < size; ui++ )
                {
                    dictionaryValue value;
                    if( !obj.get( string( ui ), value ) )
                        return {};
                    List[ ui ] = value;
                }

                return List;
            }
        }
    }
}
