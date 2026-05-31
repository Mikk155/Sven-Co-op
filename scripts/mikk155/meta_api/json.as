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

        bool debug = false;

        namespace print
        {
            void __print__( const string &in type, const string&in message, const Version &in version )
            {
                string moduleName = g_Module.GetModuleName();

                if( moduleName != "MapModule" )
                    snprintf( moduleName, "Plugin %1", moduleName );

                snprintf( cout, "[JSON v%1] [%2] %3: %4\n", int(version), moduleName, type, message );
                g_EngineFuncs.ServerPrint(cout);
                cout.Clear();
            }

            void error( bool fmt, const Version &in version = meta_api::json::Latest ) {
                __print__( "Error", cout, version );
            }
            void error( const string &in message, const Version &in version = Latest ) {
                __print__( "Error", message, version );
            }

            void info( bool fmt, const Version &in version = meta_api::json::Latest ) {
                __print__( "Info", cout, version );
            }
            void info( const string &in message, const Version &in version = Latest ) {
                __print__( "Info", message, version );
            }

            void debug( bool fmt, const Version &in version = meta_api::json::Latest ) {
                __print__( "Debug", cout, version );
            }
            void debug( const string &in message, const Version &in version = Latest ) {
                __print__( "Debug", message, version );
            }
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

        namespace Type
        {
            const string& ToString( const meta_api::json::Type&in type )
            {
                switch( type )
                {
                    case meta_api::json::Type::Handle: return "Handle";
                    case meta_api::json::Type::String: return "String";
                    case meta_api::json::Type::Float: return "Float";
                    case meta_api::json::Type::Integer: return "Integer";
                    case meta_api::json::Type::Boolean: return "Boolean";
                    case meta_api::json::Type::Object: return "Object";
                    case meta_api::json::Type::Array: return "Array";
                    case meta_api::json::Type::Null: return "Null";
                }

                return "Undefined";
            }
        }

        namespace parser
        {
            abstract class Parser
            {
                // -TODO Move methods meant to be overrided to interface: https://github.com/anjo76/angelscript/issues/68

                protected
                    uint error = 0;

                /// Return whatever all is been parsed with no issues
                const bool get_Ok() const {
                    return ( this.error == 0 );
                }

                // Parser version.
                const meta_api::json::Version GetVersion() const { return Version::Undefined; }
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
                    uint m_Depth = 1;

                private
                    meta_api::json::Version version;

                const meta_api::json::Version GetVersion() const override { return this.version; }

                Serializer@ Object( const meta_api::json::Type&in type )
                {
                    return Serializer( this.m_Depth + 1, String::EMPTY_STRING, type, this.m_Style, this.m_Indents, this.GetVersion() );
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
                            print::info( "Only Style::KandR is supported when Indentation::AllTogether. Enforcing Style::KandR...", this.GetVersion() );
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
                            print::error( "Can not instantiate a Serializer with other than Array or Object!", this.GetVersion() );
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

                        print::error( snprintf( cout, "Couldn't serialize content to file \"%1\"", this.m_Filename ), this.GetVersion() );
                        return String::EMPTY_STRING;
                    }

                    if( !this.Ok )
                    {
                        print::error( snprintf( cout, "Couldn't serialize content for \"%1\"", g_Module.GetModuleName() ), this.GetVersion() );
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
                        print::error( snprintf( cout, "Skiping unable to serialize empty value other than string. value of type %1 at key %2", type, key ), this.GetVersion() );
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

                    if( this.m_Type != meta_api::json::Type::Array )
                    {
                        this.m_Buffer.opAddAssign( EscapeSequences( key, true ) );
                        this.m_Buffer.opAddAssign( ':' );

                        if( this.m_Style == meta_api::json::parser::Style::AllMan && this.m_Indents != meta_api::json::parser::Indentation::AllTogether )
                            this.m_Buffer.opAddAssign( ' ' );
                    }

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
                            print::error( snprintf( cout, "Skiping unable to serialize value of type %1 at key %2 with value of %3", type, key, value ), this.GetVersion() );
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
                    uint m_CurrentLine = 1;

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
                            print::error( snprintf( cout, "ERROR: could not open file \"%1\"", filename ) );
                            return false;
                        }
                        */
                    }
#endif
/// Otherwise we use the epic AS API to read line by line x[

                    File@ fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                    if( fstream is null || !fstream.IsOpen() )
                    {
                        print::error( snprintf( cout, "could not open file \"%1\"", filename ), this.GetVersion() );
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
                            if( check == '*' && buffer[this.CurrentPosition + 1] == '/' )
                            {
                                this.AdvancePosition(1);
                                multi_line_commentary = false;
                            }
                        }
                        else if( check == '/' )
                        {
                            check = buffer[this.CurrentPosition+1];

                            if( check == '*' )
                            {
                                if( this.m_Buffer.Find( '*/', this.CurrentPosition, String::CompareType::CaseSensitive ) == String::INVALID_INDEX )
                                {
                                    print::error( snprintf( cout, "Unclosed multi line commentary at %1%2", this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                                    this.error++;
                                    return false;
                                }
                                this.AdvancePosition(1);
                                multi_line_commentary = true;
                            }
                            else if( check == '/' )
                            {
                                this.AdvancePosition(1);
                                single_line_commentary = true;
                            }
                            else
                            {
                                break;
                            }
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

                /// Get the last read string formated as " Last read:\n%1"
                string GetLastRead()
                {
                    string str;
                    int start = Math.max( 0, int( this.CurrentPosition - 64 ) );
                    int end = int( this.CurrentPosition );
                    snprintf( str, " Last read:\n%1", buffer.SubString( start, end ) );
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

                        print::info( snprintf( cout, "Reading file \"%1\"", filename ), this.GetVersion() );

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
                        print::error( "The provided string is empty!", this.GetVersion() );
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
                        print::error( snprintf( cout, "Unexpected token \"%1\" at line %2 expected \"{\" or \"[\"%3", meta_api::json::parser::EscapeSequences( string(check) ), this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );

                    return m_Initialized;
                }

                /// Handles persistent information for the current object at end and parents to start
                private
                    array<dictionary> m_Data(1);
                private
                    uint m_DataCurrent = 1;

                private
                    bool ErrorUnexpected( const string&in expected, const string&in unexpected, const string&in comment = String::EMPTY_STRING )
                    {
                        bool has_comment = comment.IsEmpty();
                        print::error( snprintf( cout, "Unexpected token \"%1\" at %2 expected \"%3\"%4%5%6%7",
                                unexpected,
                                this.GetCurrentLine(),
                                expected,
                                ( has_comment ? "" : " " ),
                                comment,
                                ( has_comment ? "" : "." ),
                                this.GetLastRead()
                            ), this.GetVersion()
                        );
                        this.error++;
                        return false;
                    }

                private
                    bool ValueType( const string&in key, const string&in value, bool value_is_string, meta_api::json::Type&out type )
                    {
                        bool has_data = ( !value.IsEmpty() || value_is_string );

                        if( has_data )
                        {
                            if( value_is_string )
                            {
                                type = meta_api::json::Type::String;
                                return true;
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                type =  meta_api::json::Type::Float;
                                return true;
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                type =  meta_api::json::Type::Integer;
                                return true;
                            }
                            else if( value == "false" || value == "true" )
                            {
                                type =  meta_api::json::Type::Boolean;
                                return true;
                            }
                            else if( value == "null" )
                            {
                                type =  meta_api::json::Type::Null;
                                return true;
                            }
                        }

                        return false;
                    }

                /// Advance in the parser. updates key and value and type. if the type is an array the key contains the value index
                bool Advance( const meta_api::json::Type&in ObjectType, meta_api::json::Type&out type, string&out key, string&out value )
                {
                    const bool is_array = ( ObjectType == meta_api::json::Type::Array );
                    const bool is_object = ( ObjectType == meta_api::json::Type::Object );

                    if( !is_array && !is_object )
                    {
                        print::error( snprintf( cout, "can not Advance with type \"%1\". only supported Object or Array", ObjectType ), this.GetVersion() );
                        this.error++;
                        return false;
                    }

                    // Clear up data
                    key = value = String::EMPTY_STRING;
                    type = meta_api::json::Type::Undefined;

                    /// Get the data for the current object that is being deserialized.
                    dictionary@ data = this.m_Data[this.m_DataCurrent-1];

                    /// Are we inside a string?
                    bool in_string = false;
                    bool is_escaped = false;

                    bool reading_key = is_object;
                    bool value_is_string = false;
                    bool value_is_complete = false;

                    data[ "has_comma" ] = bool( data[ "has_comma" ] );

                    if( is_array )
                    {
                        int idx = int( data[ "array_index" ] );
                        key = string(idx);
                        data[ "array_index" ] = ++idx;
                    }

                    while( this.CurrentPosition < this.totalSize )
                    {
                        if( bool( data[ "break_loop" ] ) )
                        {
                            // End of main object reached. cry for invalid remaining chars
                            if( this.m_DataCurrent == 1 )
                            {
                                this.AdvancePosition(1);

                                while( this.CurrentPosition < this.totalSize )
                                {
                                    if( this.SkipComments() )
                                    {
                                        char c = this.buffer[this.CurrentPosition];
                                        this.AdvancePosition(1);
                                        if( !this.IsIgnoredChar(c) )
                                        {
                                            this.error++;
                                            print::error( snprintf( cout, "Unexpected token \"%1\" at %2 expected end of file%3", string(c), this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                                            return false;
                                        }
                                    }
                                }
                            }

                            this.m_Data.resize(--this.m_DataCurrent);
                            return false;
                        }

                        if( !this.SkipComments() )
                            return false;

                        char c( this.buffer[this.CurrentPosition] );

                        if( bool( data[ "child_parsed" ] ) )
                        {
                            data[ "child_parsed" ] = false;
                            data[ "last_was_object" ] = true;

                            if( c == ',' )
                            {
                                data[ "has_comma" ] = false;
                                this.AdvancePosition(1);
                                continue;
                            }
                        }

                        this.AdvancePosition(1);

                        bool was_escaped = is_escaped;
                        is_escaped = false;

                        if( in_string )
                        {
                            if( c == '"' )
                            {
                                if( !was_escaped )
                                {
                                    in_string = false;
                                    if( !reading_key )
                                    {
                                        value_is_string = true;
                                    }
                                    continue;
                                }
                            }
                            else if( c == '\\' )
                            {
                                if( !was_escaped )
                                {
                                    is_escaped = true;
                                    continue;
                                }
                            }
                            else if( c == 'n' )
                            {
                                if( was_escaped )
                                    c = '\n';
                            }
                            else if( c == 't' )
                            {
                                if( was_escaped )
                                    c = '\t';
                            }
                            else if( c == 'r' )
                            {
                                if( was_escaped )
                                    c = '\r';
                            }

                            if( reading_key )
                            {
                                key.opAddAssign(c);
                            }
                            else
                            {
                                value.opAddAssign(c);
                            }
                            continue;
                        }

                        if( this.IsIgnoredChar(c) )
                        {
                            continue;
                        }

                        bool has_comma = bool( data[ "has_comma" ] );
                        data[ "has_comma" ] = false;

                        bool last_was_object = bool( data[ "last_was_object" ] );
                        data[ "last_was_object" ] = false;

                        if( c == ',' )
                        {
                            if( has_comma )
                            {
                                print::error( snprintf( cout, "invalid double coma at %1%2", this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                                this.error++;
                                return false;
                            }

                            data[ "has_comma" ] = true;

                            if( !last_was_object )
                            {
                                if( this.ValueType( key, value, value_is_string, type ) )
                                    return true;
                                this.error++;
                                print::error( snprintf( cout, "Invalid unquoted value \"%1\" for key \"%2\" at %3%4", value, key, this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                            }
                            return false;
                        }
                        else if( c == '}' || c == ']' )
                        {
                            if( is_object && c != '}' )
                                return ErrorUnexpected( "}", c, "Close Object token" );
                            if( is_array && c != ']' )
                                return ErrorUnexpected( "]", c, "Close Array token" );

                            if( has_comma )
                            {
                                this.error++;
                                print::error( snprintf( cout, "Invalid comma for last value at %1%2", this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                                return false;
                            }

                            data[ "break_loop" ] = true;

                            if( !last_was_object )
                            {
                                if( this.ValueType( key, value, value_is_string, type ) )
                                    return true;
                                this.error++;
                                if( is_object )
                                    print::error( snprintf( cout, "Invalid unquoted value \"%1\" for key \"%2\" at %3%4", value, key, this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                                else
                                    print::error( snprintf( cout, "Invalid unquoted value \"%1\" id \"%2\" at %3%4", value, key, this.GetCurrentLine(), this.GetLastRead() ), this.GetVersion() );
                            }
                            return false;
                        }
                        else if( reading_key )
                        {
                            if( c == ':' )
                            {
                                if( key.IsEmpty() )
                                    return ErrorUnexpected( '"', c, "got an empty key" );
                                reading_key = false;
                            }
                            else if( c == '"' )
                            {
                                in_string = true;
                            }
                            else
                            {
                                return ErrorUnexpected( ( key.IsEmpty() ? '"' : ':' ), c, "key-value separator" );
                            }
                        }
                        else if( c == '[' || c == '{' )
                        {
                            type = ( c == '[' ? meta_api::json::Type::Array : meta_api::json::Type::Object );
                            this.m_Data.resize(++this.m_DataCurrent);
                            data[ "child_parsed" ] = true;
                            return true;
                        }
                        else if( c == '"' )
                        {
                            if( !value.IsEmpty() )
                                return ErrorUnexpected( ",", c, "Missing comma at end of value" );

                            in_string = true;

                            if( is_object )
                            {
                            }
                        }
                        else
                        {
                            value.opAddAssign(c);
                        }
                    }

                    this.error++;
                    print::error( snprintf( cout, "Unexpected end of file. expecting \"%1\"", is_object ? "}" : "]" ) );
                    return false;
                }
            } // Deserializer
        } // parser
    } // json
} // meta_api
