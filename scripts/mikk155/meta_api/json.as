namespace meta_api
{
    namespace json
    {
#if METAMOD_PLUGIN_ASLP
        // Set to false for testing vanilla behaviour. so we don't need to restart with metamod off.
        bool __METAMOD__ = true;
#endif

        enum Version
        {
            Undefined = 0,
            V1 = 1,
            V2
        };

        /// Latest available version
        const Version Latest = Version::V2;

        // Console output temporal buffer
        string cout;

        // Print cout to console if "developer" is greater than zero
        void print( bool fmt, const Version &in version = Latest ) {
            g_Game.AlertMessage( at_console, "[JSON v%1] %2\n", int(version), cout );
            cout = String::EMPTY_STRING;
        }

        // Print cout to console if "developer" is greater than zero
        void print( const string &in message, const Version &in version = Latest ) {
            print( snprintf( cout, message ), version );
        }

        /**
        *   @brief return whatever str is a valid file name and formats the output filename
        *   IsCache: if true the path is at the store/ folder
        **/
        bool GetFilename( string&in str, string&out filename, bool IsCache = false )
        {
            if( str.EndsWith( ".json" ) )
            {
                bool isPlugin = ( g_Module.GetModuleName() != "MapModule" );
                string moduleFolder = ( isPlugin ? "plugins/" : "maps/" );

                if( str.StartsWith( "scripts/" ) )
                {
                    str = str.SubString(8);
                }

                if( str.StartsWith( moduleFolder ) )
                {
                    str = str.SubString( moduleFolder.Length() );
                }

                snprintf( filename, "scripts/%1%2%3", moduleFolder, ( IsCache ? "store/" : String::EMPTY_STRING ), str );

                return true;
            }

            return false;
        }

        // This is not meant to be useable but for storing an existent but null value in json.
        enum Null { Null = 0 };

        /// Type of value
        enum Type
        {
            Undefined = 0,
            Handle,
            String,
            Float,
            Integer,
            Boolean,
            Object,
            Array,
            Null
        };

        namespace parser
        {
            abstract class Parser
            {
                // -TODO Move methods meant to be overrided to interface: https://github.com/anjo76/angelscript/issues/68

                // Parser version.
                const meta_api::json::Version GetVersion() const { return Version::Undefined; }

                // Print cout to console if "developer" is greater than zero
                void print( bool fmt ) {
                    meta_api::json::print( fmt, this.GetVersion() );
                }

                // Print cout to console if "developer" is greater than zero
                void print( const string &in message ) {
                    meta_api::json::print( message, this.GetVersion() );
                }
            }

            enum Indentation
            {
                /// Everything together, no spaces or new lines, hard to read faster to parse.
                AllTogether = -1,
                /// Zero spaces but everything goes on a new line
                NoIndentation,
                /// A single space for each object
                OneSpace,
                /// One tab (\t) space for each object
                OneTabSpace,
            };

            enum Style
            {
                /// Each opening of array/object ("{" and "[") goes on their own line
                AllMan = 0,
                /// Each opening of array/object ("{" and "[") goes after the value's colon (":")
                KandR
            };

            /// Escape sequences from string, if add_quitation is true we also add a suffix and prefix quote
            // -TODO iterate to see something isn't actually escaped
            string EscapeSequences( string&in str, bool add_quotation = false )
            {
                str.Replace( "\\", "\\\\" );
                str.Replace( "\"", "\\\"" );
                str.Replace( "\n", "\\n" );
                str.Replace( "\r", "\\r" );
                str.Replace( "\t", "\\t" );
                if( add_quotation )
                    snprintf( str, "\"%1\"", str );
                return str;
            }

            /// Serializer class.
            final class Serializer : Parser
            {
                private
                    string m_Buffer;
                private
                    meta_api::json::parser::Indentation m_Indents = meta_api::json::parser::Indentation::AllTogether;
                private
                    meta_api::json::parser::Style m_Style = meta_api::json::parser::Style::AllMan;
                private
                    meta_api::json::Type m_Type = meta_api::json::Type::Object;
                private
                    string m_Filename;
                private
                    uint error = 0;
                private
                    uint m_Depth = 1;

                private
                    meta_api::json::Version version;

                const meta_api::json::Version GetVersion() const override { return this.version; }

                /// Return whatever all is been parsed with no issues
                const bool get_Ok() const {
                    return ( this.error == 0 );
                }

                Serializer@ Object( const meta_api::json::Type&in type )
                {
                    return Serializer( this.m_Depth + 1, String::EMPTY_STRING, this.m_Type, this.m_Style, this.m_Indents, this.GetVersion() );
                }

                Serializer(
                    uint depth,
                    const string&in filename,
                    const meta_api::json::Type&in type,
                    const meta_api::json::parser::Style&in style,
                    const meta_api::json::parser::Indentation&in indents,
                    const meta_api::json::Version&in version
                )
                {
                    this.m_Depth = depth;
                    this.m_Indents = indents;
                    this.m_Style = style;
                    this.m_Filename = filename;
                    this.version = version;

                    if( this.m_Indents == meta_api::json::parser::Indentation::AllTogether && this.m_Style != meta_api::json::parser::Style::KandR )
                    {
                        if( depth == 0 )
                        {
                            print( "Only Style::KandR is supported when Indentation::AllTogether. Enforcing Style::KandR..." );
                        }

                        this.m_Style = meta_api::json::parser::Style::KandR;
                    }

                    if( this.m_Depth > 1 )
                    {
                        if( this.m_Style == meta_api::json::parser::Style::AllMan && this.m_Indents != meta_api::json::parser::Indentation::AllTogether )
                            this.m_Buffer.opAddAssign( '\n' );

                        switch( this.m_Indents )
                        {
                            case meta_api::json::parser::Indentation::OneSpace:
                            {
                                for( uint ui = 0; ui < this.m_Depth; ui++ )
                                    this.m_Buffer.opAddAssign( ' ' );
                                break;
                            }
                            case meta_api::json::parser::Indentation::OneTabSpace:
                            {
                                for( uint ui = 0; ui < this.m_Depth; ui++ )
                                    this.m_Buffer.opAddAssign( '\t' );
                                break;
                            }
                            case meta_api::json::parser::Indentation::NoIndentation:
                            case meta_api::json::parser::Indentation::AllTogether:
                            default:
                            {
                                break;
                            }
                        }
                    }

                    switch( type )
                    {
                        case meta_api::json::Type::Array:
                        {
                            this.m_Buffer.opAddAssign( '[' );
                            this.m_Type = type;
                            break;
                        }
                        case meta_api::json::Type::Object:
                        {
                            this.m_Buffer.opAddAssign( '{' );
                            this.m_Type = type;
                            break;
                        }
                        default:
                        {
                            print( "Error: Can not instantiate a Serializer with other than Array or Object!" );
                            this.error++;
                            break;
                        }
                    }
                }

                string Serialize()
                {
                    switch( this.m_Indents )
                    {
                        case meta_api::json::parser::Indentation::NoIndentation:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::OneSpace:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            for( uint ui = 0; this.m_Depth > 1 && ui < this.m_Depth; ui++ )
                                this.m_Buffer.opAddAssign( ' ' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::OneTabSpace:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            for( uint ui = 0; this.m_Depth > 1 && ui < this.m_Depth; ui++ )
                                this.m_Buffer.opAddAssign( '\t' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::AllTogether:
                        default:
                        {
                            break;
                        }
                    }

                    switch( this.m_Type )
                    {
                        case meta_api::json::Type::Array:
                        {
                            this.m_Buffer.opAddAssign( ']' );
                            break;
                        }
                        case meta_api::json::Type::Object:
                        {
                            this.m_Buffer.opAddAssign( '}' );
                            break;
                        }
                    }

                    // Write to a file
                    if( !this.m_Filename.IsEmpty() )
                    {
                        snprintf( this.m_Filename, "%1.json", this.m_Filename );

                        if( meta_api::json::GetFilename( this.m_Filename, this.m_Filename ) )
                        {
                            // Any errors? Then write a empty object ONLY if the file doesn't exists already.
                            if( !this.Ok )
                            {
                                File@ fstream = g_FileSystem.OpenFile( this.m_Filename, OpenFile::READ );

                                if( fstream is null )
                                {
                                    @fstream = g_FileSystem.OpenFile( this.m_Filename, OpenFile::WRITE );

                                    if( fstream !is null && fstream.IsOpen() )
                                    {
                                        fstream.Write( "{}" );
                                        fstream.Close();
                                    }
                                }
                                return String::EMPTY_STRING;
                            }

                            File@ file = g_FileSystem.OpenFile( this.m_Filename, OpenFile::WRITE );

                            if( file !is null && file.IsOpen() )
                            {
                                file.Write( this.m_Buffer );
                                file.Close();
                                return this.m_Buffer;
                            }
                        }

                        print( snprintf( cout, "ERROR: Couldn't serialize content to file \"%1\"", this.m_Filename ) );
                        return String::EMPTY_STRING;
                    }

                    if( !this.Ok )
                    {
                        print( snprintf( cout, "ERROR: Couldn't serialize content for \"%1\"", g_Module.GetModuleName() ) );
                        return String::EMPTY_STRING;
                    }

                    return this.m_Buffer;
                }

                private
                    bool m_HasAnyKey = false;

                /// Insert a key-value
                void KeyValue( const string&in key, const string&in value, const meta_api::json::Type&in type )
                {
                    if( value.IsEmpty() && type != meta_api::json::Type::String )
                    {
                        print( snprintf( cout, "Error: Skiping unable to serialize empty value other than string. value of type %1 at key %2", type, key ) );
                        return;
                    }

                    if( this.m_HasAnyKey )
                        this.m_Buffer.opAddAssign( ',' );
                    else
                        this.m_HasAnyKey = true;

                    switch( this.m_Indents )
                    {
                        case meta_api::json::parser::Indentation::NoIndentation:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::OneSpace:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            for( uint ui = 0; ui <= this.m_Depth; ui++ )
                                this.m_Buffer.opAddAssign( ' ' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::OneTabSpace:
                        {
                            this.m_Buffer.opAddAssign( '\n' );
                            for( uint ui = 0; ui <= this.m_Depth; ui++ )
                                this.m_Buffer.opAddAssign( '\t' );
                            break;
                        }
                        case meta_api::json::parser::Indentation::AllTogether:
                        default:
                        {
                            break;
                        }
                    }

                    this.m_Buffer.opAddAssign( EscapeSequences( key, true ) );
                    this.m_Buffer.opAddAssign( ':' );

                    if( this.m_Style == meta_api::json::parser::Style::AllMan && this.m_Indents != meta_api::json::parser::Indentation::AllTogether )
                        this.m_Buffer.opAddAssign( ' ' );

                    switch( type )
                    {
                        case meta_api::json::Type::String:
                        {
                            this.m_Buffer.opAddAssign( EscapeSequences( value, true ) );
                            break;
                        }
                        case meta_api::json::Type::Float:
                        case meta_api::json::Type::Integer:
                        case meta_api::json::Type::Array:
                        case meta_api::json::Type::Object:
                        {
                            this.m_Buffer.opAddAssign( value );
                            break;
                        }
                        case meta_api::json::Type::Boolean:
                        {
                            this.m_Buffer.opAddAssign( ( value == '1' || value == "true" ? "true" : "false" ) );
                            break;
                        }
                        case meta_api::json::Type::Null:
                        {
                            this.m_Buffer.opAddAssign( "null" );
                            break;
                        }
                        case meta_api::json::Type::Undefined:
                        case meta_api::json::Type::Handle:
                        default:
                        {
                            print( snprintf( cout, "Error: Skiping unable to serialize value of type %1 at key %2 with value of %3", type, key, value ) );
                            break;
                        }
                    }
                }
            }

            /// Deserializer class. inherit from this overriding the GetVersion method from the Parser interface
            abstract class Deserializer : Parser
            {
                private
                    meta_api::json::Type m_Initialized = meta_api::json::Type::Undefined;

                /// Return whatever the object is propertly initialized for parsing data
                const bool get_Initialized() const
                {
                    switch( m_Initialized )
                    {
                        case meta_api::json::Type::Array:
                        case meta_api::json::Type::Object:
                            return true;
                        default:
                            return false;
                    }
                }

                private
                    bool m_IsFile;

                /// Whatever the serialized object content comes from a .json text file
                const bool get_IsFile() const {
                    return this.m_IsFile;
                }

                private
                    uint m_totalSize;

                /// Total size of the buffer
                const uint get_totalSize() const {
                    return this.m_totalSize;
                }

                private
                    string m_Buffer;

                /// buffer string
                const string& get_buffer() const {
                    return this.m_Buffer;
                }

                private
                    uint m_CurrentPosition = 0;

                /// Current position in the buffer
                const uint get_CurrentPosition() const {
                    return this.m_CurrentPosition;
                }

                private
                    uint m_CurrentLine = 0;

                /// Current line reading in buffer
                const uint get_CurrentLine() const {
                    return this.m_CurrentLine;
                }

                private
                    uint m_CurrentLinePosition = 0;

                /// Current position reading in line in buffer
                const uint get_CurrentLinePosition() const {
                    return this.m_CurrentLinePosition;
                }

                /// Move the position index ahead by one or more if given argument. returns the new position.
                uint AdvancePosition( uint overhead = 1 )
                {
                    // Call every time on reading new characters for updating position for error messages
                    for( uint ui = 0; ui < overhead; ui++ )
                    {
                        char character( this.buffer[ this.CurrentPosition ] );

                        if( character == '\r' )
                            continue;

                        this.m_CurrentLinePosition++;

                        if( character == '\n' )
                        {
                            this.m_CurrentLine++;
                            this.m_CurrentLinePosition = 0;
                        }
                    }

                    this.m_CurrentPosition += overhead;

                    return this.m_CurrentPosition;
                }

                /// Get the current line and position formated as "L[%line:%position]"
                string GetCurrentLine()
                {
                    string line;
                    snprintf( line, "L[%1:%2]", this.CurrentLine, this.CurrentLinePosition );
                    return line;
                }

                /// Metamod handles this with the internal file system getting the whole buffer in one go
                bool LoadFromFile( const string&in filename )
                {
/// Metamod handles this with the internal file system getting the whole buffer in one go
#if METAMOD_PLUGIN_ASLP
                    if( __METAMOD__ )
                    {
                        // -TODO Inject metamod FileSystem call to load the buffer in one go
                        /*
                        if( !aslp::FileSystem::ReadAll( filename, this.buffer ) )
                        {
                            print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ) );
                            return false;
                        }
                        */
                    }
#endif
/// Otherwise we use the epic AS API to read line by line x[

                    File@ fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                    if( fstream is null || !fstream.IsOpen() )
                    {
                        print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ) );
                        return false;
                    }

                    while( !fstream.EOFReached() )
                    {
                        string line;
                        fstream.ReadLine( line );

                        /* // We want it as-is for error messages tracking line position
                        // Saves some time when iterating the characters.
                        line.Trim( ' ' );

                        if( !line.IsEmpty() && !( line.Length() >= 2 && line[0] == '/' && line[1] == '/' ) ) */
                            snprintf( this.m_Buffer, "%1%2\n", this.m_Buffer, line );
                    }

                    fstream.Close();

                    return true;
                }

                /// Advance the position index skiping comments. if the method returns false break the iteration as we've reached the end of the buffer!
                bool SkipComments()
                {
                    bool single_line_commentary = false;
                    bool multi_line_commentary = false;

                    while( this.CurrentPosition < this.totalSize )
                    {
                        char check( buffer[this.CurrentPosition] );

                        if( single_line_commentary )
                        {
                            if( check == '\n' )
                            {
                                single_line_commentary = false;
                            }
                        }
                        else if( multi_line_commentary )
                        {
                            if( check == '*' && ( this.CurrentPosition + 1 < this.totalSize ) && buffer[this.CurrentPosition + 1] == '/' )
                            {
                                multi_line_commentary = false;
                            }
                        }
                        else if( check == '/' )
                        {
                            check = buffer[this.CurrentPosition+1];

                            if( check == '*' )
                                multi_line_commentary = true;
                            else if( check == '/' )
                                single_line_commentary = true;
                        }
                        else
                        {
                            break;
                        }

                        // Comment started. keep going on
                        this.AdvancePosition(1);
                    }
                    return ( this.CurrentPosition < this.totalSize );
                }

                bool IsIgnoredChar( const char&in c )
                {
                    return ( c == ' ' || c == '\n' || c == '\r' || c == '\t' );
                }

                /// Get the last read string formated as " Last read: %1"
                string GetLastRead()
                {
                    string str = buffer;
                    str = str.SubString( 0, this.CurrentPosition - 1 );
                    str = str.SubString( Math.max( 0, str.Length() - 32 ) );
                    if( !str.IsEmpty() )
                        snprintf( str, " Last read: %1", str );
                    return str;
                }

                /// Manual deletion of data if we can call this before the GC
                void Shutdown()
                {
                    this.m_IsFile = false;
                    this.m_Initialized = meta_api::json::Type::Undefined;
                    this.m_totalSize = this.m_CurrentLine = this.m_CurrentLinePosition = this.m_CurrentPosition = 0;
                    this.m_Buffer.Clear();
                }

                ~Deserializer()
                {
                    this.Shutdown();
                }

                /// Initialize object.
                const meta_api::json::Type Initialize( const string&in serialized )
                {
                    /// Is serialized a file path?
                    string filename;
                    if( GetFilename( serialized, filename ) )
                    {
                        this.m_IsFile = true;

                        print( snprintf( cout, "Reading file \"%1\"", filename ) );

                        if( !LoadFromFile( filename ) )
                        {
                            return m_Initialized;
                        }
                    }
                    else
                    {
                        this.m_Buffer = serialized;
                    }

                    this.m_totalSize = this.buffer.Length();

                    /// Seek to the first json object/array return Type::Undefined if "{" or "[" is not found
                    if( this.totalSize <= 0 )
                    {
                        print( "Error: The provided string is empty!" );
                        return meta_api::json::Type::Undefined;
                    }

                    char check;

                    while( this.CurrentPosition < this.totalSize )
                    {
                        if( !SkipComments() )
                            break;

                        check = buffer[this.CurrentPosition];
                        this.AdvancePosition(1);

                        if( check == "[" )
                        {
                            m_Initialized = meta_api::json::Type::Array;
                            break;
                        }
                        else if( check == "{" )
                        {
                            m_Initialized = meta_api::json::Type::Object;
                            break;
                        }
                        else if( !this.IsIgnoredChar(check) )
                        {
                            break;
                        }
                    }

                    if( m_Initialized == meta_api::json::Type::Undefined )
                        print( snprintf( cout, "Unexpected token \"%1\" at line %2 expected \"{\" or \"[\"%3", meta_api::json::parser::EscapeSequences( string(check) ), this.GetCurrentLine(), this.GetLastRead() ) );

                    return m_Initialized;
                }

                /// Advance in the parser. updates key and value and type. data is a dummy object we use for internal operations, provide a empty dictionary per object/array
                bool Advance( const meta_api::json::Type&in ObjectType, meta_api::json::Type&out type, string&out key, string&out value, dictionary@ data )
                {
                    if( ObjectType != meta_api::json::Type::Array && ObjectType != meta_api::json::Type::Object )
                    {
                        print( snprintf( cout, "ERROR: can not Advance with type \"%1\". only supported Object or Array", ObjectType ) );
                        return false;
                    }

                    key = value = String::EMPTY_STRING;
                    type = meta_api::json::Type::Undefined;

                    bool in_string = false;
                    bool is_escaped = false;
                    
                    bool reading_key = true;
                    bool value_is_string = false;
                    bool value_is_complete = false;
                    bool found_end = false;

                    while( this.CurrentPosition < this.totalSize )
                    {
                        if( !this.SkipComments() )
                            break;

                        char c( this.buffer[this.CurrentPosition] );

                        this.AdvancePosition(1);

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
                                print( snprintf( cout, "ERROR: Expected ':' after key at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
                                return false;
                            }
                            else if( !reading_key && ( value != String::EMPTY_STRING || value_is_string || bool( data[ "just_parsed_child" ] ) ) )
                            {
                                print( snprintf( cout, "ERROR: Missing ',' after value for key \"%1\" at %2%3", key, this.GetCurrentLine(), this.GetLastRead() ) );
                                return false;
                            }

                            in_string = true;
                        }
                        else if( c == ':' )
                        {
                            if( !reading_key )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Unexpected colon ':' in value", string( this.CurrentPosition ) ) );
                                return false;
                            }
                            if( key == String::EMPTY_STRING )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Found ':' without a preceding valid key", string( this.CurrentPosition ) ) );
                                return false;
                            }

                            reading_key = false;
                        }
                        else if( c == '{' )
                        {
                            if( reading_key )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Objects are not allowed as keys", string( this.CurrentPosition ) ) );
                                return false;
                            }
                            if( value != String::EMPTY_STRING || value_is_string || bool( data[ "just_parsed_child" ] ) )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a new object", string( this.CurrentPosition ) ) );
                                return false;
                            }

                            data[ "just_parsed_child" ] = true;
                            data[ "can_close" ] = true;
                            type = meta_api::json::Type::Object;
                            return true;
                        }
                        else if( c == '[' )
                        {
                            if( reading_key )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Arrays are not allowed as keys", string( this.CurrentPosition ) ) );
                                return false;
                            }
                            if( value != String::EMPTY_STRING || value_is_string || bool( data[ "just_parsed_child" ] ) )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an array", string( this.CurrentPosition ) ) );
                                return false;
                            }

                            data[ "just_parsed_child" ]= true;
                            data[ "can_close" ] = true;
                            type = meta_api::json::Type::Array;
                            return true;
                        }
                        else if( c == ',' || c == '}' )
                        {
                            if( c == '}' && key == String::EMPTY_STRING && !bool( data[ "can_close" ] ) )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Trailing comma before closing object", string( this.CurrentPosition ) ) );
                                return false;
                            }

                            if( c == ',' && reading_key && key == String::EMPTY_STRING )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Unexpected comma ','. Expected a key", string( this.CurrentPosition ) ) );
                                return false;
                            }

                            if( key != String::EMPTY_STRING )
                            {
                                if( !reading_key && value == String::EMPTY_STRING && !value_is_string && !bool( data[ "just_parsed_child" ] ) )
                                {
                                    print( snprintf( cout, "ERROR: (Pos %1): Missing value for key \"%2\"", string( this.CurrentPosition ), key ) );
                                    return false;
                                }

                                data[ "can_close" ] = true;

                                if( value_is_string )
                                {
                                    type = meta_api::json::Type::String;
                                    return true;
                                }

                                if( value == String::EMPTY_STRING )
                                {
                                    // -TODO Case error
                                    return false;
                                }

                                if( g_Utility.IsStringFloat( value ) )
                                {
                                    type = meta_api::json::Type::Float;
                                    return true;
                                }

                                if( g_Utility.IsStringInt( value ) )
                                {
                                    type = meta_api::json::Type::Integer;
                                    return true;
                                }

                                if( value == "false" || value == "true" )
                                {
                                    type = meta_api::json::Type::Boolean;
                                    return true;
                                }

                                if( value == "null" )
                                {
                                    type = meta_api::json::Type::Null;
                                    return true;
                                }

                                print( snprintf( cout, "ERROR: (Pos %1): Invalid unquoted value \"%2\" for key \"%3\"", string( this.CurrentPosition ), value, key ) );
                                return false;
                            }

                            key = String::EMPTY_STRING;
                            value = String::EMPTY_STRING;
                            reading_key = true;
                            value_is_string = false;
                            value_is_complete = false;
                            data[ "just_parsed_child" ] = false;

                            if( c == ',' )
                                data[ "can_close" ] = false;

                            if( c == '}' )
                            {
                                found_end = true;
                                break;
                            }
                        }
                        else if( this.IsIgnoredChar( c ) )
                        {
                            if( !reading_key && value != String::EMPTY_STRING )
                                value_is_complete = true;
                        }
                        else
                        {
                            if( reading_key )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Keys must be enclosed in quotes. Invalid character: \"%2\"", string( this.CurrentPosition ), string( c ) ) );
                                return false;
                            }
                            else
                            {
                                if( value_is_string || bool( data[ "just_parsed_child" ] ) || value_is_complete )
                                {
                                    print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( this.CurrentPosition ), key ) );
                                    return false;
                                }

                                value += c;
                            }
                        }
                    }

                    if( in_string )
                    {
                        print( snprintf( cout, "ERROR: Unterminated string in object" ) );
                        return false;
                    }

                    if( !found_end )
                    {
                        print( snprintf( cout, "ERROR: Unterminated object. Expected '}'" ) );
                        return false;
                    }

                    return true;
                }
            } // Deserializer
        } // parser
    } // json
} // meta_api
