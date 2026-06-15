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

        enum Error
        {
            OK = 0,
            FILE_NOT_FOUND,
            SYNTAX_ERROR,
            EMPTY_INPUT
        };

        /// Latest available version
        const Version Latest = Version::V2;

        // Console output temporal buffer
        string cout;

        // Set to true for displaying debug messages
        bool debug = false;

        class Logger
        {
            protected
                string module;

            string name;

            private
                void __SetModuleName__()
                {
                    this.module = g_Module.GetModuleName();
                    if( this.module != "MapModule" )
                        snprintf( this.module, "Plugin %1", this.module );
                }

            Logger()
            {
                __SetModuleName__();
            }

            Logger( const string&in Name )
            {
                __SetModuleName__();
                this.name = Name;
            }

            void error( bool fmt ) const {
                snprintf( cout, "[%1] %2 Error: %3\n", this.module, this.name, cout );
                g_EngineFuncs.ServerPrint(cout); cout.Clear();
            }

            void error( const string&in message ) const {
                snprintf( cout, "[%1] %2 Error: %3\n", this.module, this.name, message );
                g_EngineFuncs.ServerPrint(cout); cout.Clear();
            }

            void info( bool fmt ) const {
                snprintf( cout, "[%1] %2 Info: %3\n", this.module, this.name, cout );
                g_EngineFuncs.ServerPrint(cout); cout.Clear();
            }

            void info( const string&in message ) const {
                snprintf( cout, "[%1] %2 Info: %3\n", this.module, this.name, message );
                g_EngineFuncs.ServerPrint(cout); cout.Clear();
            }

            void debug( bool fmt ) const {
                if( meta_api::json::debug ) {
                    snprintf( cout, "[%1] %2 Debug: %3\n", this.module, this.name, cout );
                   g_EngineFuncs.ServerPrint(cout); cout.Clear();
                }
            }

            void debug( const string&in message ) const {
                if( meta_api::json::debug ) {
                    snprintf( cout, "[%1] %2 Debug: %3\n", this.module, this.name, message );
                    g_EngineFuncs.ServerPrint(cout); cout.Clear();
                }
            }
        }

        // Global json logger
        Logger g_Logger( "JSON" );

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
            // Convert the given Type to string for printing
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

            // Convert the given string to Type
            Type FromString( string&in type )
            {
                type.ToLowercase();
                if( type == "object" )
                    return Type::Object;
                if( type == "array" )
                    return Type::Array;
                if( type == "string" )
                    return Type::String;
                if( type == "integer" )
                    return Type::Integer;
                if( type == "float" || type == "number" )
                    return Type::Float;
                if( type == "boolean" || type == "bool" )
                    return Type::Boolean;
                if( type == "null" )
                    return Type::Null;
                if( type == "handle" )
                    return Type::Handle;
                return Type::Undefined;
            }
        }

        namespace parser
        {
            /// Represents a key-value pair. type defines in what "value_" the value is stored
            class KeyValuePair
            {
                string key;
                meta_api::json::Type type;
                string value_string;
                int value_int;
                float value_float;
                bool value_bool;

                void clear()
                {
                    this.key.Clear();
                    this.value_string.Clear();
                    this.type = meta_api::json::Type::Undefined;
                    this.value_float = 0.0f;
                    this.value_int = 0;
                    this.value_bool = false;
                }
            }

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

                Logger m_Logger( "JSON V" + int( this.GetVersion() ) );

                const meta_api::json::Logger@ get_Logger() const { return g_Logger; }
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
                            this.Logger.info( "Only Style::KandR is supported when Indentation::AllTogether. Enforcing Style::KandR..." );
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
                            this.Logger.error( "Can not instantiate a Serializer with other than Array or Object!" );
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
                        if( !this.m_Filename.EndsWith( ".json" ) )
                            this.m_Filename.opAddAssign( ".json" );

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

                        this.Logger.error( snprintf( cout, "Couldn't serialize content to file \"%1\"", this.m_Filename ) );
                        return String::EMPTY_STRING;
                    }

                    if( !this.Ok )
                    {
                        this.Logger.error( snprintf( cout, "Couldn't serialize content for \"%1\"", g_Module.GetModuleName() ) );
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
                        this.Logger.error( snprintf( cout, "Skiping unable to serialize empty value other than string. value of type %1 at key %2", type, key ) );
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
                            this.Logger.error( snprintf( cout, "Skiping unable to serialize value of type %1 at key %2 with value of %3", type, key, value ) );
                            break;
                        }
                    }
                }
            }

            /// Deserializer class.
            abstract class Deserializer : Parser
            {
                private
                    bool m_IsFile;

                /// Whatever the serialized object content comes from a .json text file
                const bool get_IsFile() const {
                    return this.m_IsFile;
                }

                private
                    meta_api::json::Error m_ErrorCode = meta_api::json::Error::OK;

                const meta_api::json::Error get_ErrorCode() const {
                    if( this.error > 0 )
                        return meta_api::json::Error::SYNTAX_ERROR;
                    return this.m_ErrorCode;
                }

                private
                    string m_FileName;

                /// The file name
                const string& get_FileName() const {
                    return this.m_FileName;
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
                                    this.Logger.error( snprintf( cout, "Unclosed multi line commentary at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
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
                    this.m_totalSize = this.m_CurrentLine = this.m_CurrentLinePosition = this.m_CurrentPosition = 0;
                    this.m_Buffer.Clear();
                    this.m_ErrorCode = meta_api::json::Error::OK;
                }

                ~Deserializer()
                {
                    this.Shutdown();
                }

                void SetSerialized( const string&in serialized )
                {
                    /// Is serialized a file path?
                    if( GetFilename( serialized, this.m_FileName ) )
                    {
                        this.m_IsFile = true;
                    }
                    else
                    {
                        this.m_Buffer = serialized;
                    }
                }

                /// Initialize object/array. loading a file if applicable
                const meta_api::json::Type Initialize()
                {
                    if( !this.IsFile && this.m_Buffer.IsEmpty() )
                    {
                        this.Logger.error( snprintf( cout, "Deserializer::Initialize Empty string provided or Deserializer::SetSerialized was never called!" ) );
                        this.m_ErrorCode = meta_api::json::Error::EMPTY_INPUT;
                        return meta_api::json::Type::Undefined;
                    }

                    if( this.IsFile )
                    {
                        this.Logger.info( snprintf( cout, "Reading file \"%1\"", this.m_FileName ) );

                        bool shouldVanillaLoad = true;

/// Metamod handles this with the internal file system getting the whole buffer in one go and loading the file with nlohmann/json
#if METAMOD_PLUGIN_ASLP
                        if( __METAMOD__ )
                        {
                            /*
                            auto type = meta_api::json::Type( aslp::json::Load( this.m_FileName ) ) );
                            if( type == meta_api::json::Type::Undefined )
                                this.Logger.error( snprintf( cout, "could not open file \"%1\"", this.m_FileName ) );
                            return type;
                            */
                        }
#endif
/// Otherwise we use the epic AS API to read line by line and parse ourselves x[

                        if( shouldVanillaLoad )
                        {
                            File@ fstream = g_FileSystem.OpenFile( this.m_FileName, OpenFile::READ );

                            if( fstream is null || !fstream.IsOpen() )
                            {
                                this.Logger.error( snprintf( cout, "could not open file \"%1\"", this.m_FileName ) );
                                this.m_ErrorCode = meta_api::json::Error::FILE_NOT_FOUND;
                                return meta_api::json::Type::Undefined;
                            }

                            while( !fstream.EOFReached() )
                            {
                                string line;
                                fstream.ReadLine( line );
                                snprintf( this.m_Buffer, "%1%2\n", this.m_Buffer, line );
                            }

                            fstream.Close();
                        }
                    }

                    this.m_totalSize = this.buffer.Length();

                    // nlohmann json ignores theses so i guess we'll do the same x[
                    if( this.m_totalSize >= 3 && this.m_Buffer[0] == '\xEF' && this.m_Buffer[1] == '\xBB' && this.m_Buffer[2] == '\xBF' )
                    {
                        this.m_Buffer = this.m_Buffer.SubString(3);
                        this.m_totalSize = this.m_Buffer.Length();
                    }

                    /// Seek to the first json object/array return Type::Undefined if "{" or "[" is not found
                    if( this.totalSize <= 1 ) // 2 is the minimun string size to define empty object/array
                    {
                        this.Logger.error( "The provided string is empty!" );
                        this.m_ErrorCode = meta_api::json::Error::EMPTY_INPUT;
                        return meta_api::json::Type::Undefined;
                    }

                    char check;

                    while( this.CurrentPosition < this.totalSize )
                    {
                        if( !SkipComments() )
                        {
                            this.m_ErrorCode = meta_api::json::Error::SYNTAX_ERROR;
                            break;
                        }

                        check = buffer[this.CurrentPosition];
                        this.AdvancePosition(1);

                        if( check == '[' )
                            return meta_api::json::Type::Array;
                        if( check == '{' )
                            return meta_api::json::Type::Object;

                        if( check != '\r' && check != ' ' && check != '\t' && check != '\n' )
                            break;
                    }
                    this.ErrorUnexpected( "{\" or \"[", check );
                    this.m_ErrorCode = meta_api::json::Error::SYNTAX_ERROR;
                    return meta_api::json::Type::Undefined;
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
                        this.Logger.error( snprintf( cout, "Unexpected token \"%1\" at %2 expected \"%3\"%4%5%6%7",
                                meta_api::json::parser::EscapeSequences( unexpected ),
                                this.GetCurrentLine(),
                                expected,
                                ( has_comment ? "" : " " ),
                                comment,
                                ( has_comment ? "" : "." ),
                                this.GetLastRead()
                            )
                        );
                        this.error++;
                        return false;
                    }

                private void CloseObject( const meta_api::json::Type&in ObjectType, bool had_comma, int pairs )
                {
                    dictionary@ currentData = this.m_Data[this.m_DataCurrent-1];

                    if( had_comma && pairs > 0 )
                    {
                        this.error++;
                        this.Logger.error( snprintf( cout, "Unexpected \",\" at the last key-value pair at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
                        return;
                    }

                    // End of main object reached. cry for any invalid remaining chars
                    if( this.m_DataCurrent == 1 )
                    {
                        while( this.CurrentPosition < this.totalSize )
                        {
                            if( this.SkipComments() )
                            {
                                char c = this.buffer[this.CurrentPosition];
                                this.AdvancePosition(1);

                                if( c != '\r' && c != ' ' && c != '\t' && c != '\n' )
                                {
                                    this.Logger.error( snprintf( cout, "Unexpected token \"%1\" at %2 expected end of string%3", string(c), this.GetCurrentLine(), this.GetLastRead() ) );
                                    this.error++;
                                    return;
                                }
                            }
                        }
                    }
                    else
                    {
                        this.m_Data.resize(--this.m_DataCurrent);
                        dictionary@ parentData = this.m_Data[this.m_DataCurrent-1];
                        parentData[ "just_parsed_child" ] = true;
                    }

                    if( debug )
                    {
                        this.Logger.debug( snprintf( cout, "%1: %2 %3", string( currentData[ "path" ] ), meta_api::json::Type::ToString(ObjectType), ( ObjectType == meta_api::json::Type::Array ? "]" : "}" ) ) );
                    }
                }

                /// Advance in the parser. updates key and value and type. if the type is an array the key contains the value index
                bool Advance( const meta_api::json::Type&in ObjectType, KeyValuePair@&out pair )
                {
                    if( !this.Ok )
                        return false;

                    if( pair is null )
                        @pair = meta_api::json::parser::KeyValuePair();
                    else
                        pair.clear();

#if METAMOD_PLUGIN_ASLP
                    if( __METAMOD__ )
                    {
                        /*
                        if( aslp::json::Update( pair ) )
                            return true;
                        return false;
                        */
                    }
#endif

                    const bool is_array = ( ObjectType == meta_api::json::Type::Array );
                    const bool is_object = ( ObjectType == meta_api::json::Type::Object );

                    if( !is_array && !is_object )
                    {
                        this.Logger.error( snprintf( cout, "can not Advance with type \"%1\". only supported Object or Array", ObjectType ) );
                        this.error++;
                        return false;
                    }

                    /// Get the data for the current object that is being deserialized.
                    dictionary@ data = this.m_Data[this.m_DataCurrent-1];

                    if( debug )
                    {
                        if( !data.exists( "path" ) )
                        {
                            data[ "path" ] = "\"<root>\"";
                            this.Logger.debug( snprintf( cout, "%1: %2 %3", string( data[ "path" ] ), meta_api::json::Type::ToString(ObjectType), ( ObjectType == meta_api::json::Type::Array ? "[" : "{" ) ) );
                        }
                    }

                    int pairs = int( data[ "pairs" ] );
                    bool had_comma = bool( data[ "had_comma" ] );

                    if( bool( data[ "stop" ] ) )
                    {
                        CloseObject( ObjectType, had_comma, pairs );
                        return false;
                    }

                    data[ "had_comma" ] = false;

                    // For arrays we want a numerical ordered index for keys
                    if( is_array )
                    {
                        int idx = int( data[ "array_index" ] );
                        pair.key = string(idx);
                        data[ "array_index" ] = ++idx;
                    }

                    bool reading_key = is_object;
                    bool reading_value = is_array;
                    bool expect_pair_separator = false;
                    bool in_string = false;
                    bool value_is_string = false;

                    while( this.CurrentPosition < this.totalSize )
                    {
                        if( !in_string && !this.SkipComments() )
                        {
                            return false;
                        }

                        char c( this.buffer[this.CurrentPosition] );
                        this.AdvancePosition(1);

                        if( in_string )
                        {
                            if( c == '"' )
                            {
                                if( reading_key )
                                {
                                    reading_key = false;
                                    expect_pair_separator = true;
                                }
                                in_string = false;
                                continue;
                            }

                            // escape sequences
                            if( c == '\\' )
                            {
                                string e;
                                char next( this.buffer[this.CurrentPosition] );

                                // Skip next read
                                this.AdvancePosition(1);

                                if( next == 'r' ) { e = '\r'; }
                                else if( next == '"' ) { e = "\""; }
                                else if( next == 'n' ) { e = "\n"; }
                                else if( next == 't' ) { e = "\t"; }
                                else if( next == '\\' ) { e = "\\\\"; }
                                // The game doesnt need these but if we want to share information with other programs it may need to be keept
                                else if( next == 'u' ) { e = "\\u"; }
                                else if( next == '/' ) { e = "\\/"; }
                                else if( next == 'b' ) { e = "\\b"; }
                                else if( next == 'f' ) { e = "\\f"; }
                                else
                                {
                                    this.Logger.error( snprintf( cout, "Non-escaped sequence \"%1\" at %2%3", string(next), this.GetCurrentLine(), this.GetLastRead() ) );
                                    this.error++;
                                    return false;
                                }

                                if( reading_key )
                                    pair.key.opAddAssign(e);
                                else if( reading_value )
                                    pair.value_string.opAddAssign(e);
                                continue;
                            }

                            if( reading_key )
                                pair.key.opAddAssign(c);
                            else if( reading_value )
                                pair.value_string.opAddAssign(c);
                            continue;
                        }

                        bool is_space = ( c == ' ' || c == '\t' );

                        if( c == '\r' )
                            continue;

                        if( is_space || c == '\n' )
                        {
                            if( is_array && !pair.value_string.IsEmpty() )
                                pair.value_string.opAddAssign(c);
                            continue;
                        }

                        if( bool( data[ "just_parsed_child" ] ) )
                        {
                            data[ "just_parsed_child" ] = false;

                            if( c == ',' )
                            {
                                had_comma = true;
                                continue;
                            }
                        }

                        if( expect_pair_separator )
                        {
                            if( c != ':' )
                                return ErrorUnexpected( ":", c, "Key-value separator" );

                            reading_value = true;
                            expect_pair_separator = false;
                            continue;
                        }

                        if( reading_value )
                        {
                            if( pair.key.IsEmpty() )
                            {
                                this.Logger.error( snprintf( cout, "Empty key name given at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
                                this.error++;
                                return false;
                            }

                            bool shouldParsePairs = false;
                            bool stop = false;

                            if( c == '"' )
                            {
                                if( value_is_string )
                                    return ErrorUnexpected( ",", c, "Continuous string literal" );
                                if( !pair.value_string.IsEmpty() )
                                    return ErrorUnexpected( c, pair.value_string, "Invalid characters before opening string sequence" );

                                in_string = true;
                                value_is_string = true;
                            }
                            else if( c == ',' )
                            {
                                shouldParsePairs = true;
                                data[ "had_comma" ] = had_comma = true;
                            }
                            else if( c == '}' || c == ']' )
                            {
                                if( c == '}' && is_array )
                                    return ErrorUnexpected( "]" , c, "End of child array" );
                                if( c == ']' && is_object )
                                    return ErrorUnexpected( "}" , c, "End of child object" );
                                stop = true;
                                shouldParsePairs = true;
                            }
                            else if( c == '[' || c == '{' )
                            {
                                if( !pair.value_string.IsEmpty() )
                                    return ErrorUnexpected( c, pair.value_string );

                                pair.type = ( c == '[' ? meta_api::json::Type::Array : meta_api::json::Type::Object );
                                this.m_Data.resize(++this.m_DataCurrent);

                                if( debug )
                                {
                                    string path;
                                    snprintf( path, "%1->\"%2\"", string( data[ "path" ] ), pair.key );

                                    dictionary@ childData = this.m_Data[this.m_DataCurrent-1];
                                    childData[ "path" ] = path;
                                    this.Logger.debug( snprintf( cout, "%1: %2 %3", path, meta_api::json::Type::ToString(pair.type), ( pair.type == meta_api::json::Type::Array ? "[" : "{" ) ) );
                                }
                                return true;
                            }
                            else
                            {
                                pair.value_string.opAddAssign(c);
                            }

                            if( pair.value_string.IsEmpty() && !value_is_string )
                            {
                                if( stop )
                                {
                                    CloseObject( ObjectType, had_comma, pairs );
                                    return false;
                                }
                            }

                            if( shouldParsePairs )
                            {
                                while( pair.value_string.EndsWith( ' ' ) || pair.value_string.EndsWith( '\n' ) )
                                {
                                    pair.value_string.Trim( ' ' );
                                    pair.value_string.Trim( '\n' );
                                }

                                if( pair.value_string.IsEmpty() && !value_is_string )
                                {
                                    if( had_comma && bool( data[ "had_comma" ] ) )
                                        return ErrorUnexpected( ( is_array ? "value" : "\"" ), c, "Double comma after value" );

                                    this.Logger.error( snprintf( cout, "Empty non-string value given at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
                                    this.error++;
                                    return false;
                                }

                                if( value_is_string )
                                {
                                    pair.type = meta_api::json::Type::String;
                                }
                                else if( g_Utility.IsStringInt( pair.value_string ) )
                                {
                                    pair.type =  meta_api::json::Type::Integer;
                                    pair.value_int = atoi( pair.value_string );
                                }
                                else if( g_Utility.IsStringFloat( pair.value_string ) )
                                {
                                    pair.type =  meta_api::json::Type::Float;
                                    pair.value_float = atof( pair.value_string );
                                }
                                else if( pair.value_string == "false" || pair.value_string == "true" )
                                {
                                    pair.type =  meta_api::json::Type::Boolean;
                                    pair.value_bool = ( pair.value_string == "true" );
                                }
                                else if( pair.value_string == "null" )
                                {
                                    pair.type =  meta_api::json::Type::Null;
                                }
                                else
                                {
                                    this.Logger.error( snprintf( cout, "Invalid non-string value \"%1\" at %2%3", EscapeSequences(pair.value_string), this.GetCurrentLine(), this.GetLastRead() ) );
                                    this.error++;
                                    return false;
                                }

                                if( debug )
                                {
                                    string quote = ( pair.type == meta_api::json::Type::String ? "\"" : "" );
                                    this.Logger.debug( snprintf( cout, "%1->\"%2\": %3%4%3 (%5)", string( data[ "path" ] ), pair.key, quote, pair.value_string, meta_api::json::Type::ToString(pair.type) ) );
                                }

                                if( stop )
                                {
                                    data[ "stop" ] = true;
                                }
                                /*
                                else if( !had_comma && pairs > 0 )
                                {
                                    this.error++;
                                    this.Logger.error( snprintf( cout, "Unexpected end of value without comma at %1%2", this.GetCurrentLine(), this.GetLastRead() ) );
                                    return false;
                                }
                                */

                                data[ "pairs" ] = ++pairs;

                                // Check for duplicated key names
                                array<string>@ keys;
                                if( !data.get( "keys", @keys ) )
                                {
                                    @keys = { pair.key };
                                    data[ "keys" ] = keys;
                                }
                                else if( keys.find( pair.key ) < 0 )
                                {
                                    keys.insertLast( pair.key );
                                }
                                else
                                {
                                    this.Logger.error( snprintf( cout, "Duplicated key name \"%1\" at %2%3", pair.key, this.GetCurrentLine(), this.GetLastRead() ) );
                                    this.error++;
                                    return false;
                                }

                                return true;
                            }

                            if( stop )
                            {
                                CloseObject( ObjectType, had_comma, pairs );
                                return false;
                            }

                            continue;
                        }

                        if( c == '}' || c == ']' )
                        {
                            if( c == '}' && is_array )
                                return ErrorUnexpected( "]", c );
                            if( c == ']' && is_object )
                                return ErrorUnexpected( "}", c );

                            CloseObject( ObjectType, had_comma, pairs );
                            return false;
                        }

                        if( reading_key )
                        {
                            if( c != '"' )
                                return ErrorUnexpected( "\"", c, "Key name" );
                            in_string = true;
                            continue;
                        }

                        this.error++;
                        this.Logger.error( snprintf( cout, "Unexpected \"%1\" at %2%3", c, this.GetCurrentLine(), this.GetLastRead() ) );
                        return false;
                    }

                    if( in_string )
                    {
                        this.error++;
                        this.Logger.error( "Reached end of parser with an unterminated string!" );
                    }

                    return false;
                }
            } // Deserializer
        } // parser
    } // json
} // meta_api
