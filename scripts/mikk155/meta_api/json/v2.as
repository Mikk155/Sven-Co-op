#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 2 of Json. conversion to/from class.
        namespace v2
        {
            enum Type
            {
                Undefined = 0,
                Handle,
                String,
                Float,
                Integer,
                Boolean,
                Object,
                Array
            };

            class json
            {
                protected
                    meta_api::json::v2::Type m_Type = Type::Undefined;

                // Current type of this object.
                const meta_api::json::v2::Type& get_Type() const {
                    return this.m_Type;
                }

                /// Unordered key-values
                dictionary m_KeyValues = {};

                /// Ordered key names
                array<string> m_KeyNames = {};

                /// Internal name where the value is stored for non object/array types
                const string& __Value__ { get const { return "__value__"; } }

                /// Internal value
                dictionaryValue get_Value()
                {
                    if( !this.m_KeyValues.exists( this.__Value__ ) )
                    {
                        dictionaryValue val;
                        this.m_KeyValues[ this.__Value__ ] = val;
                    }

                    return this.m_KeyValues[ this.__Value__ ];
                }

                void SetType( const meta_api::json::v2::Type&in type )
                {
                    switch( type )
                    {
                        case Type::String:
                        case Type::Handle:
                        case Type::Float:
                        case Type::Integer:
                        case Type::Boolean:
                        {
                            auto value = this.m_KeyValues[ this.__Value__ ];
                            this.Clear();
                            this.m_KeyValues.deleteAll();
                            this.m_KeyValues[ this.__Value__ ] = value;
                            this.m_KeyNames.resize(0);
                            break;
                        }
                        case Type::Object:
                        case Type::Array:
                        {
                            this.Clear();
                            break;
                        }
                    }

                    this.m_Type = type;
                }

                /// Set a value of any type. "value" could be set by using Value.opAssign(T) from this object
                void SetValue( const dictionaryValue&in value, const meta_api::json::v2::Type&in type )
                {
                    this.SetType(type);
                    this.m_KeyValues[ this.__Value__ ] = value;
                }

                meta_api::json::v2::json@ opAssign( meta_api::json::v2::json@ value )
                {
                    this.SetType( value.Type );
                    this.m_KeyValues = value.m_KeyValues;
                    this.m_KeyNames = value.m_KeyNames;
                    return this;
                }
                meta_api::json::v2::json@ opAssign( const float value ) { this.SetValue( this.Value.opAssign(value), Type::Float ); return this; }
                meta_api::json::v2::json@ opAssign( const int value ) { this.SetValue( this.Value.opAssign(value), Type::Integer ); return this; }
                meta_api::json::v2::json@ opAssign( const bool value ) { this.SetValue( this.Value.opAssign(value), Type::Boolean ); return this; }
                meta_api::json::v2::json@ opAssign( const string&in value ) { this.SetValue( this.Value.opAssign(value), Type::String ); return this; }

                float opConv() { return float( this.Value ); }
                int opConv() { return int( this.Value ); }
                bool opConv() { return bool( this.Value ); }
                string opConv() { return string( this.Value ); }

                json( meta_api::json::v2::json@ other ) { this.opAssign( other ); }
                json() { this.m_Type = meta_api::json::v2::Type::Object; }

                /// Clear all data. only the type remains and whatever this is an ordered object.
                void Clear()
                {
                    this.m_KeyValues.deleteAll();
                    this.m_KeyNames.resize(0);
                }

                /// Get the length of the object. for non object/array this is 1. zero if undefined value.
                uint Length()
                {
                    switch( this.Type )
                    {
                        case Type::Object:
                        case Type::Array:
                            return this.m_KeyValues.getSize();
                        case Type::String:
                        case Type::Handle:
                        case Type::Float:
                        case Type::Integer:
                        case Type::Boolean:
                            return 1;
                        case Type::Undefined:
                        default:
                            return 0;
                    }
                }

                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, meta_api::json::v2::json@ value )
                {
                    meta_api::json::v2::json@ old = cast<meta_api::json::v2::json@>( this.m_KeyValues[ keyName ] );
                    @this.m_KeyValues[ keyName ] = value;
                    return @old;
                }

                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const bool value ) {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const int value ) {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const float value ) {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const string&in value ) {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }

                /// Get the value&out and return whatever the value exists or not. if strict is false floats and booleans are converted to integer and returned.
                bool Get( const string&in keyName, meta_api::json::v2::json@&out value ) {
                    return ( this.m_KeyValues.exists( keyName ) && ( @value = cast<meta_api::json::v2::json@>( this.m_KeyValues[ keyName ] ) ) !is null );
                }
                /// Get the value&out and return whatever the value exists or not
                bool Get( const string&in keyName, bool&out value, bool strict = true ) {
                    meta_api::json::v2::json@ obj;
                    if( this.Get( keyName, obj ) )
                    {
                        if( strict && obj.Type != meta_api::json::v2::Type::Boolean )
                            return false;

                        switch( obj.Type )
                        {
                            case meta_api::json::v2::Type::Integer:
                                value = ( int( obj.Value ) > 0 );
                                return true;
                            case meta_api::json::v2::Type::Float:
                                value = ( int( float( obj.Value ) ) > 0 );
                                return true;
                            case meta_api::json::v2::Type::Boolean:
                                value = bool( obj.Value );
                                return true;
                        }
                    }
                    return false;
                }
                /// Get the value&out and return whatever the value exists or not. if strict is false floats and booleans are converted to integer and returned.
                bool Get( const string&in keyName, int&out value, bool strict = true ) {
                    meta_api::json::v2::json@ obj;
                    if( this.Get( keyName, obj ) )
                    {
                        if( strict && obj.Type != meta_api::json::v2::Type::Integer )
                            return false;

                        switch( obj.Type )
                        {
                            case meta_api::json::v2::Type::Boolean:
                                value = ( bool( obj.Value ) ? 1 : 0 );
                                return true;
                            case meta_api::json::v2::Type::Float:
                                value = int( float( obj.Value ) );
                                return true;
                            case meta_api::json::v2::Type::Integer:
                                value = int( obj.Value );
                                return true;
                        }
                    }
                    return false;
                }
                /// Get the value&out and return whatever the value exists or not. if strict is false integers and booleans are converted to float and returned.
                bool Get( const string&in keyName, float&out value, bool strict = true ) {
                    meta_api::json::v2::json@ obj;
                    if( this.Get( keyName, obj ) )
                    {
                        if( strict && obj.Type != meta_api::json::v2::Type::Float )
                            return false;

                        switch( obj.Type )
                        {
                            case meta_api::json::v2::Type::Boolean:
                                value = ( bool( obj.Value ) ? 1.0f : 0.0f );
                                return true;
                            case meta_api::json::v2::Type::Integer:
                                value = float( int( obj.Value ) );
                                return true;
                            case meta_api::json::v2::Type::Float:
                                value = float( obj.Value );
                                return true;
                        }
                    }
                    return false;
                }
                /// Get the value&out and return whatever the value exists or not
                bool Get( const string&in keyName, string&out value ) {
                    meta_api::json::v2::json@ obj;
                    if( this.Get( keyName, obj ) && obj.Type == meta_api::json::v2::Type::String ) {
                        value = string( obj.Value );
                        return true;
                    }
                    return false;
                }

                /// Get the first occurrence of value
                meta_api::json::v2::json@ First( const string&in keyName )
                {
                    meta_api::json::v2::json@ value;
                    this.Get( keyName, value );
                    return value;
                }

                /// Get the first occurrence of value or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// In this json case if the default value is null we will initialize a instance and return that
                meta_api::json::v2::json@ FirstOrDefault( const string&in keyName, meta_api::json::v2::json@ value = null, bool store = false )
                {
                    if( !this.Get( keyName, value ) )
                    {
                        if( value is null )
                            @value = meta_api::json::v2::json();
                        if( store )
                            this.Set( keyName, value );
                    }
                    return value;
                }
                /// Get the first occurrence of value or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false integers and floats are converted to boolean and returned.
                bool FirstOrDefault( const string&in keyName, bool value, bool store = false, bool strict = true )
                {
// https://github.com/anjo76/angelscript/issues/70
#if FALSE
                    if( !this.Get( keyName, value, strict ) && store )
                        this.Set( keyName, value );
                    return value;
#endif
                    bool temp = value; 
                    if( !this.Get( keyName, temp, strict ) )
                    {
                        if( store )
                            this.Set( keyName, value );
                        return value;
                    }
                    return temp;
                }
                /// Get the first occurrence of value or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and floats are converted to integer and returned.
                int FirstOrDefault( const string&in keyName, int value, bool store = false, bool strict = true )
                {
// https://github.com/anjo76/angelscript/issues/70
#if FALSE
                    if( !this.Get( keyName, value, strict ) && store )
                        this.Set( keyName, value );
                    return value;
#endif
                    int temp = value; 
                    if( !this.Get( keyName, temp, strict ) )
                    {
                        if( store )
                            this.Set( keyName, value );
                        return value;
                    }
                    return temp;
                }
                /// Get the first occurrence of value or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and integers are converted to float and returned.
                float FirstOrDefault( const string&in keyName, float value, bool store = false, bool strict = true )
                {
// https://github.com/anjo76/angelscript/issues/70
#if FALSE
                    if( !this.Get( keyName, value, strict ) && store )
                        this.Set( keyName, value );
                    return value;
#endif
                    float temp = value; 
                    if( !this.Get( keyName, temp, strict ) )
                    {
                        if( store )
                            this.Set( keyName, value );
                        return value;
                    }
                    return temp;
                }
                /// Get the first occurrence of value or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and integers are converted to float and returned.
                string FirstOrDefault( const string&in keyName, string&in value = String::EMPTY_STRING, bool store = false ) {
// https://github.com/anjo76/angelscript/issues/70
#if FALSE
                    if( !this.Get( keyName, value, strict ) && store )
                        this.Set( keyName, value );
                    return value;
#endif
                    string temp = value; 
                    if( !this.Get( keyName, temp ) )
                    {
                        if( store )
                            this.Set( keyName, value );
                        return value;
                    }
                    return temp;
                }

                // Used to sort array and ordered items
                protected
                    uint __unique_index__ = 0;

                meta_api::json::v2::json@ push_back( meta_api::json::v2::json@ value )
                {
                    if( this.Type != meta_api::json::v2::Type::Array )
                    {
                        print( snprintf( cout, "ERROR: Couldn't push_back to a json that is not an array!" ) );
                        @value = null; value.push_back(null);
                    }

                    __unique_index__++;
                    string keyName = string( __unique_index__ );
                    this.Set( keyName, value );
                    this.m_KeyNames.insertLast( keyName );
                    return value;
                }

                meta_api::json::v2::json@ opIndex( uint index )
                {
                    return this.First( this.m_KeyNames[ index ] );
                }

                meta_api::json::v2::json@ push_back( const bool value ) { return this.push_back( meta_api::json::v2::json().opAssign(value) ); }
                meta_api::json::v2::json@ push_back( const int value ) { return this.push_back( meta_api::json::v2::json().opAssign(value) ); }
                meta_api::json::v2::json@ push_back( const float value ) { return this.push_back( meta_api::json::v2::json().opAssign(value) ); }
                meta_api::json::v2::json@ push_back( const string&in value ) { return this.push_back( meta_api::json::v2::json().opAssign(value) ); }
            }

            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return a valid handle
            **/
            bool Deserialize( const string&in str, meta_api::json::v2::json@&out obj )
            {
                __Position__ = __Size__ = 0;

                // Instantiate obj if null
                if( obj is null )
                    @obj = meta_api::json::v2::json();

                // AS copy
                string serialized = String::EMPTY_STRING;

                string filename;
                if( GetFilename( str, filename ) )
                {
                    print( snprintf( cout, "Reading file \"%1\"", filename ), Version::V2 );

                    auto fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

                    if( fstream is null || !fstream.IsOpen() )
                    {
                        print( snprintf( cout, "ERROR: could not open file \"%1\"", filename ), Version::V2 );
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
                    serialized = str;

                __Size__ = serialized.Length();

                if( __Size__ == 0 )
                {
                    print( "Error: The provided string is empty", Version::V2 );
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
                    print( "Error: The provided string only contains whitespaces", Version::V2 );
                    return false;
                }

                char c( serialized[start_idx] );
                __Position__ = start_idx + 1;

                if( c == '[' )
                {
                    if( !ParseArray( serialized, @obj ) )
                        return false;
                }
                else if( c == '{' )
                {
                    if( !ParseObject( serialized, @obj ) )
                        return false;
                }
                else
                {
                    print( snprintf( cout, "ERROR: (Pos %1): Invalid format. Expected '{' or '[' at the beginning of the JSON", string( start_idx ) ), Version::V2 );
                    return false;
                }

                return true;
            }

            bool ParseObject( const string&in serialized, meta_api::json::v2::json@ obj )
            {
                obj.SetType( meta_api::json::v2::Type::Object );

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

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        ParseObject( serialized, @objChild );
                        obj.Set( key, objChild );
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

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        ParseArray( serialized, @objChild );
                        obj.Set( key, objChild );
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
                                obj.Set( key, value );
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj.Set( key, atof( value ) );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj.Set( key, atoi( value ) );
                            }
                            else if( value == "false" )
                            {
                                obj.Set( key, false );
                            }
                            else if( value == "true" )
                            {
                                obj.Set( key, true );
                            }
                            else if( value == "null" )
                            {
                                obj.Set( key, null );
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj.Set( key, value );
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

            bool ParseArray( const string&in serialized, meta_api::json::v2::json@ obj )
            {
                obj.SetType( meta_api::json::v2::Type::Array );

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

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        ParseObject( serialized, @objChild );
                        obj.push_back( objChild );
                        just_parsed_child = true;
                    }
                    else if( c == '[' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a sub-array", string( __Position__ ) ), Version::V1 );
                            return false;
                        }

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        ParseArray( serialized, @objChild );
                        obj.push_back( objChild );
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
                                obj.push_back( value );
                            }
                            else if( g_Utility.IsStringFloat( value ) )
                            {
                                obj.push_back( atof( value ) );
                            }
                            else if( g_Utility.IsStringInt( value ) )
                            {
                                obj.push_back( atoi( value ) );
                            }
                            else if( value == "false" )
                            {
                                obj.push_back( false );
                            }
                            else if( value == "true" )
                            {
                                obj.push_back( true );
                            }
                            else if( value == "null" )
                            {
                                obj.push_back( null );
                            }
                            else if( value != String::EMPTY_STRING )
                            {
                                obj.push_back( value );
                            }
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
        }
    }
}
