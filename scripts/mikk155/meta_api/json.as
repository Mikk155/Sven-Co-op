namespace meta_api
{
    namespace json
    {
#if METAMOD_PLUGIN_ASLP
        // Set to false for testing vanilla behaviour. so we don't need to restart with metamod off.
        bool gpUseMetaod = true;
#endif

        /**
        *   @brief return whatever str is a valid file name and formats the output filename
        **/
        bool GetFilename( const string&in str, string&out filename )
        {
            if( str.EndsWith( ".json" ) )
            {
                bool isPlugin = ( g_Module.GetModuleName() != "MapModule" );
                string moduleFolder = ( isPlugin ? "plugins/" : "maps/" );

                if( str.StartsWith( "scripts/" ) || str.StartsWith( moduleFolder ) )
                {
                    g_Game.AlertMessage( at_console, "[Json] Error: you can not define folders before of \"scripts/%1\"\n", moduleFolder );
                    return false;
                }

                snprintf( filename, "scripts/%1%2", moduleFolder, str );

                return true;
            }

            return false;
        }

        // Json validator version
        enum Version
        {
            /// Json conversion to dictionary. array items are converted into a dictionary object where the key names are the item indexing.
            V1 = 1
        };

        /// Json validator
        class Validator
        {
            /// Using protected property accessor so you can write inheritances of Validator
            protected
                string m_Serialized;

            Validator( const string&in serialized )
            {
                this.SetSerialized( serialized );
            }

            Validator() {}

            /// Set the serialized text/filename
            Validator@ SetSerialized( const string&in serialized ) {
                this.m_Serialized = serialized;
                return this;
            }

            protected
                Version m_Version = Version::V1;

            /// Set the deserializer version (Defaults to V1)
            Validator@ SetVersion( const Version&in version ) {
                this.m_Version = version;
                return this;
            }

            // Get parser version
            Version get_Version() {
                return this.m_Version;
            }

            protected
                bool m_AllOk = false;

            /// Return whatever the everything was parsed propertly.
            const bool get_Ok() {
                return this.m_AllOk;
            }

            protected
                string cout;

            void print( bool fmt ) {
                g_Game.AlertMessage( at_console, "[JSON v%1] %2\n", int(this.Version), cout );
            }

            void print( const string&in message ) {
                print( snprintf( cout, message ) );
            }

            protected
                uint m_Position;
            protected
                uint m_Size;

            protected bool ParseObject( const string&in serialized,
                dictionary@ obj = null
            )
            {
                switch( this.Version )
                {
                    case Version::V1:
                    default:
                    {
                        obj.deleteAll();
                        break;
                    }
                }

                string key = String::EMPTY_STRING;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;
                
                bool reading_commentary = false;
                bool single_commentary = false;
                bool reading_key = true;
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( this.m_Position < this.m_Size )
                {
                    char c( serialized[this.m_Position] );

                    this.m_Position++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( reading_commentary )
                    {
                        if( single_commentary )
                        {
                            if( c == '\n' )
                                single_commentary = reading_commentary = false;
                        }
                        else if( c == '/' && serialized[this.m_Position - 2] == '*' )
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
                            this.print( snprintf( cout, "ERROR: (Pos %1): Expected ':' after key", string( this.m_Position ) ) );
                            return false;
                        }
                        else if( !reading_key && ( value != String::EMPTY_STRING || value_is_string || just_parsed_child ) )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( this.m_Position ), key ) );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == ':' )
                    {
                        if( !reading_key )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Unexpected colon ':' in value", string( this.m_Position ) ) );
                            return false;
                        }
                        if( key == String::EMPTY_STRING )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Found ':' without a preceding valid key", string( this.m_Position ) ) );
                            return false;
                        }

                        reading_key = false;
                    }
                    else if( c == '{' )
                    {
                        if( reading_key )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Objects are not allowed as keys", string( this.m_Position ) ) );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a new object", string( this.m_Position ) ) );
                            return false;
                        }

                        switch( this.Version )
                        {
                            case Version::V1:
                            default:
                            {
                                dictionary objChild;
                                this.ParseObject( serialized, @objChild );
                                obj[ key ] = objChild;
                                break;
                            }
                        }

                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( reading_key )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Arrays are not allowed as keys", string( this.m_Position ) ) );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an array", string( this.m_Position ) ) );
                            return false;
                        }

                        switch( this.Version )
                        {
                            case Version::V1:
                            default:
                            {
                                dictionary objChild;
                                this.ParseArray( serialized, @objChild );
                                obj[ key ] = objChild;
                                break;
                            }
                        }

                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == '}' )
                    {
                        if( c == ',' && reading_key && key == String::EMPTY_STRING )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Unexpected comma ','. Expected a key", string( this.m_Position ) ) );
                            return false;
                        }

                        if( key != String::EMPTY_STRING )
                        {
                            if( !reading_key && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                            {
                                this.print( snprintf( cout, "ERROR: (Pos %1): Missing value for key \"%2\"", string( this.m_Position ), key ) );
                                return false;
                            }

                            if( value_is_string )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, value );
                                        break;
                                    }
                                }
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, atof( value ) );
                                        break;
                                    }
                                }
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, atoi( value ) );
                                        break;
                                    }
                                }
                            }
                            else if( value == "false" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, false );
                                        break;
                                    }
                                }
                            }
                            else if( value == "true" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, true );
                                        break;
                                    }
                                }
                            }
                            else if( value == "null" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, string("__null__") );
                                        break;
                                    }
                                }
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( key, value );
                                        break;
                                    }
                                }
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
                        if( c == '/' && serialized[this.m_Position] == '*' )
                        {
                            reading_commentary = true;
                        }
                        else if( c == '/' && serialized[this.m_Position] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                        }
                        else if( reading_key )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Keys must be enclosed in quotes. Invalid character: \"%2\"", string( this.m_Position ), string( c ) ) );
                            return false;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child )
                            {
                                this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( this.m_Position ), key ) );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                return true;
            }

            protected bool ParseArray( const string&in serialized, dictionary@ obj )
            {
                switch( this.Version )
                {
                    case Version::V1:
                    default:
                    {
                        obj.deleteAll();
                        break;
                    }
                }

                uint item_index = 0;
                string value = String::EMPTY_STRING;
                bool in_string = false;
                bool is_escaped = false;

                bool reading_commentary = false;
                bool single_commentary = false;
                bool value_is_string = false;
                bool just_parsed_child = false;

                while( this.m_Position < this.m_Size )
                {
                    char c( serialized[this.m_Position] );

                    this.m_Position++;

                    bool was_escaped = is_escaped;
                    is_escaped = false;

                    if( reading_commentary )
                    {
                        if( single_commentary )
                        {
                            if( c == '\n' )
                                single_commentary = reading_commentary = false;
                        }
                        else if( c == '/' && serialized[this.m_Position - 2] == '*' )
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
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array before quotes", string( this.m_Position ) ) );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == '{' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an object in array", string( this.m_Position ) ) );
                            return false;
                        }

                        switch( this.Version )
                        {
                            case Version::V1:
                            default:
                            {
                                dictionary objChild;
                                this.ParseObject( serialized, @objChild );
                                obj.set( string( item_index ), objChild );
                                break;
                            }
                        }

                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a sub-array", string( this.m_Position ) ) );
                            return false;
                        }

                        switch( this.Version )
                        {
                            case Version::V1:
                            default:
                            {
                                dictionary objChild;
                                this.ParseArray( serialized, @objChild );
                                obj.set( string( item_index ), objChild );
                                break;
                            }
                        }

                        just_parsed_child = true;
                    }
                    else if( c == ',' || c == ']' )
                    {
                        if( c == ',' && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                        {
                            this.print( snprintf( cout, "ERROR: (Pos %1): Duplicate comma ',' or empty value in array", string( this.m_Position ) ) );
                            return false;
                        }

                        bool has_data = ( value != String::EMPTY_STRING ) || value_is_string || just_parsed_child;

                        if( has_data )
                        {
                            if( value_is_string )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), value );
                                        break;
                                    }
                                }
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), atof( value ) );
                                        break;
                                    }
                                }
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), atoi( value ) );
                                        break;
                                    }
                                }
                            }
                            else if( value == "false" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), false );
                                        break;
                                    }
                                }
                            }
                            else if( value == "true" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), true );
                                        break;
                                    }
                                }
                            }
                            else if( value == "null" )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), string("__null__") );
                                        break;
                                    }
                                }
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                switch( this.Version )
                                {
                                    case Version::V1:
                                    default:
                                    {
                                        obj.set( string( item_index ), value );
                                        break;
                                    }
                                }
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
                        if( c == '/' && serialized[this.m_Position] == '*' )
                        {
                            reading_commentary = true;
                        }
                        else if( c == '/' && serialized[this.m_Position] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child )
                            {
                                this.print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array", string( this.m_Position ) ) );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                return true;
            }

            bool Deserialize( dictionary&out obj )
            {
                // Clear up in case a validator gets reused
                this.m_Position = this.m_Size = 0;

                // AS copy
                string serialized = String::EMPTY_STRING;

                string filename;
                if( GetFilename( this.m_Serialized, filename ) )
                {
                    this.print( snprintf( cout, "Reading file \"%1\"", filename ) );

/// Metamod handles this with the internal file system getting the whole buffer in one go
#if METAMOD_PLUGIN_ASLP
                    if( gpUseMetaod ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
                    {
                        if( !aslp::json::Deserialize( filename, obj ) ) // -TODO Update metamod so we send the Validator pointer/options
                        {
                            this.print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ) );
                            return false;
                        }
                        return true;
                    }
#endif
/// Otherwise we use the shit API to read line by line x[

                    auto fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                    if( fstream is null || !fstream.IsOpen() )
                    {
                        this.print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ) );
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
                    serialized = this.m_Serialized;
                    serialized.Trim( ' ' ); // Saves on iterations
                }

/// Metamod handles this with the internal nlohmann/json library
#if METAMOD_PLUGIN_ASLP
                if( gpUseMetaod ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
                {
                    if( !aslp::json::Deserialize( serialized, obj ) ) // -TODO Update metamod so we send the Validator pointer/options
                    {
                        this.print( "ERROR: could not parse object" );
                        return false;
                    }
                    return true;
                }
#endif
/// Otherwise we read the string in AS char by char x[

                this.m_Size = serialized.Length();

                if( this.m_Size == 0 )
                {
                    this.print( "Error: The provided string is empty\n" );
                    return false;
                }

                uint start_idx = 0;

                while( start_idx < this.m_Size )
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

                if( start_idx >= this.m_Size )
                {
                    this.print( "Error: The provided string only contains whitespaces" );
                    return false;
                }

                char c( serialized[start_idx] );
                m_Position = start_idx + 1;

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
                    this.print( snprintf( cout, "ERROR: (Pos %1): Invalid format. Expected '{' or '[' at the beginning of the JSON", string( start_idx ) ) );
                    return false;
                }

                this.m_AllOk = true;
                return true;
            }
        }
    }
}
