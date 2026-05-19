#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 2 of Json. conversion to/from class.
        /// Work in progress. expect API changes.
        namespace v2
        {
            // This is not meant to be useable but for storing an existent but null value in json.
            enum Null { Null = 0 };

            /// Type of value that json is containing
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

            /// Json is a complete wrapper to dictionary and array the main difference is that json is ordered.
            /// If something is missing you can either pull request or just inherit from this class and make your specific changes according to your needs.
            class json
            {
                protected
                    meta_api::json::v2::Type m_Type = Type::Undefined;

                // Current type of this object.
                const meta_api::json::v2::Type& get_Type() const {
                    return this.m_Type;
                }

                /// Return whatever this object contains a boolean value
                bool is_boolean() const { return ( this.Type ==  meta_api::json::v2::Type::Boolean ); }
                /// Return whatever this object contains a integer value
                bool is_number_integer() const { return ( this.Type ==  meta_api::json::v2::Type::Integer ); }
                /// Return whatever this object contains a float value
                bool is_number_float() const { return ( this.Type ==  meta_api::json::v2::Type::Float ); }
                /// Return whatever this object contains a float value
                bool is_string() const { return ( this.Type ==  meta_api::json::v2::Type::String ); }
                /// Return whatever this object contains a json object value
                bool is_object() const { return ( this.Type ==  meta_api::json::v2::Type::Object ); }
                /// Return whatever this object contains a json array value
                bool is_array() const { return ( this.Type ==  meta_api::json::v2::Type::Array ); }
                /// Return whatever this object contains a "null" value
                bool is_null() const { return ( this.Type ==  meta_api::json::v2::Type::Null ); }
                /// Return whatever this object contains a handle value
                bool is_handle() const { return ( this.Type ==  meta_api::json::v2::Type::Handle ); }
                /// Return whatever this object contains a json array or object value
                bool is_structured() const { return ( this.is_object() || this.is_array() ); }
                /// Return whatever this object contains number either float or integer
                bool is_number() const { return ( this.is_number_integer() || this.is_number_float() ); }
                bool is_number_unsigned() const { return ( this.is_number_integer() && int( this.m_KeyValues[ this.__Value__ ] ) >= 0 ); }

                protected
                    string m_Name;

                /// Key name of this object
                const string& get_Name() const
                {
                    return this.m_Name;
                }

                void __SetName__( const string&in keyName )
                {
                    this.m_Name = keyName;
                }

                /// Unordered key-values
                dictionary m_KeyValues = {};

                /// Ordered key names
                array<string> m_KeyNames = {};

                // All key-values
                array<string>@ get_Keys()
                {
                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::Object:
                        case meta_api::json::v2::Type::Array:
                        {
                            return @this.m_KeyNames;
                        }
                        case meta_api::json::v2::Type::String:
                        case meta_api::json::v2::Type::Float:
                        case meta_api::json::v2::Type::Integer:
                        case meta_api::json::v2::Type::Boolean:
                        case meta_api::json::v2::Type::Null:
                        default:
                            return null;
                    }
                }

                /// Internal name where the value is stored for non object/array types
                const string& __Value__ { get const { return "__value__"; } }

                /// Internal value
                dictionaryValue@ get_Value()
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
                        case Type::Object:
                        case Type::Array:
                        {
                            this.Clear();
                            break;
                        }
                        case Type::String:
                        case Type::Handle:
                        case Type::Float:
                        case Type::Integer:
                        case Type::Boolean:
                        case Type::Null:
                        default:
                        {
                            dictionaryValue@ value = this.m_KeyValues[ this.__Value__ ];
                            this.Clear();
                            this.m_KeyValues.deleteAll();
                            this.m_KeyValues[ this.__Value__ ] = value;
                            this.m_KeyNames.resize(0);
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

                /// ======================================
                /// opAssign
                /// ======================================
                meta_api::json::v2::json@ opAssign( meta_api::json::v2::json@ value )
                {
                    this.SetType( value.Type );

                    this.m_KeyValues = value.m_KeyValues;
                    this.m_KeyNames = value.m_KeyNames;

                    // No. because we're still allocated on a different owner
                    // this.m_Name = value.m_Name;

                    return this;
                }

                meta_api::json::v2::json@ opAssign( const float value ) { this.SetValue( this.Value.opAssign(value), Type::Float ); return this; }
                meta_api::json::v2::json@ opAssign( const int value ) { this.SetValue( this.Value.opAssign(value), Type::Integer ); return this; }
                meta_api::json::v2::json@ opAssign( const bool value ) { this.SetValue( this.Value.opAssign(value), Type::Boolean ); return this; }
                meta_api::json::v2::json@ opAssign( const string&in value ) { this.SetValue( this.Value.opAssign(value), Type::String ); return this; }
                meta_api::json::v2::json@ opAssign( const meta_api::json::v2::Null&in value ) { this.SetValue( this.Value.opAssign(value), Type::Null ); return this; }

                /// ======================================
                /// opConv
                /// ======================================
                float opConv() { return float( this.Value ); }
                int opConv() { return int( this.Value ); }
                bool opConv() { return bool( this.Value ); }
                string opConv() { return string( this.Value ); }

                /// ======================================
                /// Constructors
                /// ======================================
                json( meta_api::json::v2::json@ other ) { this.opAssign( other ); }
                json() { this.m_Type = meta_api::json::v2::Type::Object; }

                /**
                *   @brief Deserializes str
                *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
                *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return a valid handle
                **/
                bool Load( const string&in str )
                {
                    return Deserialize( str, this );
                }

                /// ======================================
                /// Object/Array methods
                /// ======================================

                /// Clear all data. only the type remains and whatever this is an ordered object.
                void Clear()
                {
                    this.m_KeyValues.deleteAll();
                    this.m_KeyNames.resize(0);
                }

                /// Return whatever this objects contains the given key
                bool Contains( const string&in keyName )
                {
                    return this.m_KeyValues.exists( keyName );
                }

                /// Get the length of the object.
                /// For non object/array this is -1
                /// For null values this is -2
                int Length()
                {
                    switch( this.Type )
                    {
                        case Type::Object:
                        case Type::Array:
                            return this.m_KeyNames.length();
                        case Type::String:
                        case Type::Handle:
                        case Type::Float:
                        case Type::Integer:
                        case Type::Boolean:
                            return -1;
                        case Type::Null:
                        case Type::Undefined:
                        default:
                            return -2;
                    }
                }

                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, meta_api::json::v2::json@ value )
                {
                    meta_api::json::v2::json@ old = cast<meta_api::json::v2::json@>( this.m_KeyValues[ keyName ] );

                    if( value is null )
                    {
                        print( snprintf( cout, "ERROR: Couldn't set null json value for key \"%1\"", keyName ), Version::V2 );
                        return @old;
                    }

                    /// Ordering
                    int keyIndex = this.m_KeyNames.find( keyName );

                    if( keyIndex >= 0 )
                    {
                        this.m_KeyNames[keyIndex] = keyName;
                    }
                    else
                    {
                        this.m_KeyNames.insertLast( keyName );
                    }

                    @this.m_KeyValues[ keyName ] = value;
                    value.__SetName__( keyName );

                    return @old;
                }

                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const bool value )
                {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const int value )
                {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const float value )
                {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, const string&in value )
                {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }
                meta_api::json::v2::json@ Set( const string&in keyName, const meta_api::json::v2::Null&in value )
                {
                    return @this.Set( keyName, meta_api::json::v2::json().opAssign(value) );
                }

                /// Get the value&out and return whatever the value exists or not.
                /// If strict is false floats and booleans are converted to integer and returned.
                bool Get( const string&in keyName, meta_api::json::v2::json@&out value )
                {
                    return ( this.m_KeyValues.exists( keyName ) && ( @value = cast<meta_api::json::v2::json@>( this.m_KeyValues[ keyName ] ) ) !is null );
                }

                /// Get the value&out and return whatever the value exists or not
                /// If strict is false floats and integers are converted to boolean and returned.
                bool Get( bool&out value, bool strict = true )
                {
                    if( strict && this.Type != meta_api::json::v2::Type::Boolean )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::Integer:
                            value = ( int( this.Value ) > 0 );
                            return true;
                        case meta_api::json::v2::Type::Float:
                            value = ( int( float( this.Value ) ) > 0 );
                            return true;
                        case meta_api::json::v2::Type::Boolean:
                            value = bool( this.Value );
                            return true;
                        default:
                            return false;
                    }
                }

                /// Get the value&out and return whatever the value exists or not
                /// If strict is false floats and integers are converted to boolean and returned.
                bool Get( const string&in keyName, bool&out value, bool strict = true )
                {
                    meta_api::json::v2::json@ obj;
                    return ( this.Get( keyName, obj ) && obj.Get( value, strict ) );
                }

                /// Get the value&out and return whatever the value exists or not.
                /// If strict is false floats and booleans are converted to integer and returned.
                bool Get( int&out value, bool strict = true )
                {
                    if( strict && this.Type != meta_api::json::v2::Type::Integer )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::Boolean:
                            value = ( bool( this.Value ) ? 1 : 0 );
                            return true;
                        case meta_api::json::v2::Type::Float:
                            value = int( float( this.Value ) );
                            return true;
                        case meta_api::json::v2::Type::Integer:
                            value = int( this.Value );
                            return true;
                        default:
                            return false;
                    }
                }

                /// Get the value&out and return whatever the value exists or not.
                /// If strict is false floats and booleans are converted to integer and returned.
                bool Get( const string&in keyName, int&out value, bool strict = true )
                {
                    meta_api::json::v2::json@ obj;
                    return ( this.Get( keyName, obj ) && obj.Get( value, strict ) );
                }

                /// Get the value&out and return whatever the value exists or not.
                /// If strict is false integers and booleans are converted to float and returned.
                bool Get( float&out value, bool strict = true )
                {
                    if( strict && this.Type != meta_api::json::v2::Type::Float )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::Boolean:
                            value = ( bool( this.Value ) ? 1.0f : 0.0f );
                            return true;
                        case meta_api::json::v2::Type::Integer:
                            value = float( int( this.Value ) );
                            return true;
                        case meta_api::json::v2::Type::Float:
                            value = float( this.Value );
                            return true;
                        default:
                            return false;
                    }
                }

                /// Get the value&out and return whatever the value exists or not.
                /// If strict is false integers and booleans are converted to float and returned.
                bool Get( const string&in keyName, float&out value, bool strict = true )
                {
                    meta_api::json::v2::json@ obj;
                    return ( this.Get( keyName, obj ) && obj.Get( value, strict ) );
                }

                /// Get the value&out and return whatever the value exists or not
                bool Get( string&out value )
                {
                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::String:
                            value = string( this.Value );
                            return true;
                        default:
                            return false;
                    }
                }

                /// Get the value&out and return whatever the value exists or not
                bool Get( const string&in keyName, string&out value )
                {
                    meta_api::json::v2::json@ obj;
                    return ( this.Get( keyName, obj ) && obj.Get( value ) );
                }

                /// Get the stored value at the given key name or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// In this json case if the default value is null we will initialize a instance and return that
                meta_api::json::v2::json@ ValueOrDefault( const string&in keyName, meta_api::json::v2::json@ value = null, bool store = false )
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
                /// Get the stored value at the given key name or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false integers and floats are converted to boolean and returned.
                bool ValueOrDefault( const string&in keyName, bool value, bool store = false, bool strict = true )
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
                /// Get the stored value at the given key name or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and floats are converted to integer and returned.
                int ValueOrDefault( const string&in keyName, int value, bool store = false, bool strict = true )
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
                /// Get the stored value at the given key name or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and integers are converted to float and returned.
                float ValueOrDefault( const string&in keyName, float value, bool store = false, bool strict = true )
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
                /// Get the stored value at the given key name or a default value if not exists.
                /// If store is true the default value is stored in data if not exists
                /// If strict is false booleans and integers are converted to float and returned.
                string ValueOrDefault( const string&in keyName, string&in value, bool store = false )
                {
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

                /// ======================================
                /// Array methods
                /// ======================================
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( meta_api::json::v2::json@ value )
                {
                    if( this.Type != meta_api::json::v2::Type::Array )
                    {
                        print( snprintf( cout, "ERROR: Couldn't Append to a json that is not an array!" ), Version::V2 );
                        return null;
                    }

                    if( value is null )
                    {
                        print( snprintf( cout, "ERROR: Couldn't Append a null json value!" ), Version::V2 );
                        return null;
                    }

                    this.Set( string( __unique_index__++ ), value );
                    return value;
                }

                /// Get the value at the given key
                meta_api::json::v2::json@ opIndex( const string&in keyName )
                {
                    meta_api::json::v2::json@ value;
                    this.Get( keyName, value );
                    return value;
                }

                meta_api::json::v2::json@ opIndex( uint index )
                {
                    if( index >= this.m_KeyNames.length() )
                    {
                        print( snprintf( cout, "ERROR: Index %1 is outside json length %2", index, this.m_KeyNames.length() ), Version::V2 );
                        return null;
                    }

                    return this.opIndex( this.m_KeyNames[ index ] );
                }

                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( const bool value ) { return this.Append( meta_api::json::v2::json().opAssign(value) ); }
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( const int value ) { return this.Append( meta_api::json::v2::json().opAssign(value) ); }
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( const float value ) { return this.Append( meta_api::json::v2::json().opAssign(value) ); }
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( const string&in value ) { return this.Append( meta_api::json::v2::json().opAssign(value) ); }
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( const meta_api::json::v2::Null&in value ) { return this.Append( meta_api::json::v2::json().opAssign(value) ); }

                /// Get the value converted to string.
                /// For objects/arrays this is a serialization with -1 indents.
                string ToString()
                {
                    switch( this.Type )
                    {
                        case meta_api::json::v2::Type::Object:
                        case meta_api::json::v2::Type::Array:
                        {
                            return Serialize(-1, this);
                        }
                        case meta_api::json::v2::Type::String:
                            return string( this.Value );
                        case meta_api::json::v2::Type::Float:
                            return string( float( this.Value ) );
                        case meta_api::json::v2::Type::Integer:
                            return string( int( this.Value ) );
                        case meta_api::json::v2::Type::Boolean:
                            return ( bool( this.Value ) ? "true" : "false" );
                        case meta_api::json::v2::Type::Handle:
                            return "@";
                        case meta_api::json::v2::Type::Null:
                        default:
                            return "null";
                    }
                }
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

                    File@ fstream = g_FileSystem.OpenFile( filename, OpenFile::READ );

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

                        if( !line.IsEmpty() && !( line.Length() >= 2 && line[0] == '/' && line[1] == '/' ) )
                            snprintf( serialized, "%1%2\n", serialized, line );
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

                return __ReadIgnored__( serialized );
            }

            bool __IsIgnoredChar__( char c )
            {
                return ( c == ' ' || c == '\n' || c == '\r' || c == '\t' );
            }

            bool __ReadIgnored__( const string&in serialized )
            {
                bool reading_commentary = false;
                bool single_commentary = false;

                while( __Position__ < __Size__ )
                {
                    char c( serialized[__Position__] );
                    __Position__++;

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

                    if( __IsIgnoredChar__( c ) )
                        continue;

                    if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '*' )
                    {
                        reading_commentary = true;
                        continue;
                    }

                    if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '/' )
                    {
                        reading_commentary = single_commentary = true;
                        continue;
                    }

                    print( snprintf( cout, "ERROR: (Pos %1): Unexpected trailing data after root json value", string( __Position__ ) ), Version::V2 );
                    return false;
                }

                if( reading_commentary )
                {
                    print( snprintf( cout, "ERROR: Unterminated commentary after root json value" ), Version::V2 );
                    return false;
                }

                return true;
            }

            bool __SetScalar__( meta_api::json::v2::json@ obj, const string&in key, const string&in value )
            {
                if( value == String::EMPTY_STRING )
                    return false;

                if( g_Utility.IsStringFloat( value ) )
                {
                    obj.Set( key, atof( value ) );
                    return true;
                }

                if( g_Utility.IsStringInt( value ) )
                {
                    obj.Set( key, atoi( value ) );
                    return true;
                }

                if( value == "false" )
                {
                    obj.Set( key, false );
                    return true;
                }

                if( value == "true" )
                {
                    obj.Set( key, true );
                    return true;
                }

                if( value == "null" )
                {
                    obj.Set( key, meta_api::json::v2::Null::Null );
                    return true;
                }

                print( snprintf( cout, "ERROR: (Pos %1): Invalid unquoted value \"%2\" for key \"%3\"", string( __Position__ ), value, key ), Version::V2 );
                return false;
            }

            bool __PushScalar__( meta_api::json::v2::json@ obj, const string&in value )
            {
                if( value == String::EMPTY_STRING )
                    return false;

                if( g_Utility.IsStringFloat( value ) )
                {
                    obj.Append( atof( value ) );
                    return true;
                }

                if( g_Utility.IsStringInt( value ) )
                {
                    obj.Append( atoi( value ) );
                    return true;
                }

                if( value == "false" )
                {
                    obj.Append( false );
                    return true;
                }

                if( value == "true" )
                {
                    obj.Append( true );
                    return true;
                }

                if( value == "null" )
                {
                    obj.Append( meta_api::json::v2::Null::Null );
                    return true;
                }

                print( snprintf( cout, "ERROR: (Pos %1): Invalid unquoted array value \"%2\"", string( __Position__ ), value ), Version::V2 );
                return false;
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
                bool value_is_complete = false;
                bool just_parsed_child = false;
                bool found_end = false;
                bool can_close = true;

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
                            print( snprintf( cout, "ERROR: (Pos %1): Expected ':' after key", string( __Position__ ) ), Version::V2 );
                            return false;
                        }
                        else if( !reading_key && ( value != String::EMPTY_STRING || value_is_string || just_parsed_child ) )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( __Position__ ), key ), Version::V2 );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == ':' )
                    {
                        if( !reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Unexpected colon ':' in value", string( __Position__ ) ), Version::V2 );
                            return false;
                        }
                        if( key == String::EMPTY_STRING )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Found ':' without a preceding valid key", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        reading_key = false;
                    }
                    else if( c == '{' )
                    {
                        if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Objects are not allowed as keys", string( __Position__ ) ), Version::V2 );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a new object", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        if( !ParseObject( serialized, @objChild ) )
                            return false;
                        obj.Set( key, objChild );
                        just_parsed_child = true;
                        can_close = true;
                    }
                    else if( c == '[' )
                    {
                        if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Arrays are not allowed as keys", string( __Position__ ) ), Version::V2 );
                            return false;
                        }
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an array", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        if( !ParseArray( serialized, @objChild ) )
                            return false;
                        obj.Set( key, objChild );
                        just_parsed_child = true;
                        can_close = true;
                    }
                    else if( c == ',' || c == '}' )
                    {
                        if( c == '}' && key == String::EMPTY_STRING && !can_close )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Trailing comma before closing object", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        if( c == ',' && reading_key && key == String::EMPTY_STRING )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Unexpected comma ','. Expected a key", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        if( key != String::EMPTY_STRING )
                        {
                            if( !reading_key && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing value for key \"%2\"", string( __Position__ ), key ), Version::V2 );
                                return false;
                            }

                            if( value_is_string )
                            {
                                obj.Set( key, value );
                            }
                            else if( value != String::EMPTY_STRING && !__SetScalar__( obj, key, value ) )
                            {
                                return false;
                            }

                            can_close = true;
                        }

                        key = String::EMPTY_STRING;
                        value = String::EMPTY_STRING;
                        reading_key = true;
                        value_is_string = false;
                        value_is_complete = false;
                        just_parsed_child = false;

                        if( c == ',' )
                            can_close = false;

                        if( c == '}' )
                        {
                            found_end = true;
                            break;
                        }
                    }
                    else if( __IsIgnoredChar__( c ) )
                    {
                        if( !reading_key && value != String::EMPTY_STRING )
                            value_is_complete = true;
                    }
                    else
                    {
                        if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '*' )
                        {
                            reading_commentary = true;
                            if( !reading_key && value != String::EMPTY_STRING )
                                value_is_complete = true;
                        }
                        else if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                            if( !reading_key && value != String::EMPTY_STRING )
                                value_is_complete = true;
                        }
                        else if( reading_key )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Keys must be enclosed in quotes. Invalid character: \"%2\"", string( __Position__ ), string( c ) ), Version::V2 );
                            return false;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child || value_is_complete )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing ',' after value for key \"%2\"", string( __Position__ ), key ), Version::V2 );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                if( in_string )
                {
                    print( snprintf( cout, "ERROR: Unterminated string in object" ), Version::V2 );
                    return false;
                }

                if( reading_commentary )
                {
                    print( snprintf( cout, "ERROR: Unterminated commentary in object" ), Version::V2 );
                    return false;
                }

                if( !found_end )
                {
                    print( snprintf( cout, "ERROR: Unterminated object. Expected '}'" ), Version::V2 );
                    return false;
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
                bool value_is_complete = false;
                bool just_parsed_child = false;
                bool found_end = false;
                bool can_close = true;

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
                            print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array before quotes", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        in_string = true;
                    }
                    else if( c == '{' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening an object in array", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        if( !ParseObject( serialized, @objChild ) )
                            return false;
                        obj.Append( objChild );
                        just_parsed_child = true;
                        can_close = true;
                    }
                    else if( c == '[' )
                    {
                        if( value != String::EMPTY_STRING || value_is_string || just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Missing ',' before opening a sub-array", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        meta_api::json::v2::json@ objChild = meta_api::json::v2::json();
                        if( !ParseArray( serialized, @objChild ) )
                            return false;
                        obj.Append( objChild );
                        just_parsed_child = true;
                        can_close = true;
                    }
                    else if( c == ',' || c == ']' )
                    {
                        if( c == ']' && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child && !can_close )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Trailing comma before closing array", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        if( c == ',' && value == String::EMPTY_STRING && !value_is_string && !just_parsed_child )
                        {
                            print( snprintf( cout, "ERROR: (Pos %1): Duplicate comma ',' or empty value in array", string( __Position__ ) ), Version::V2 );
                            return false;
                        }

                        bool has_data = ( value != String::EMPTY_STRING ) || value_is_string || just_parsed_child;

                        if( has_data )
                        {
                            if( value_is_string )
                            {
                                obj.Append( value );
                            }
                            else if( value != String::EMPTY_STRING && !__PushScalar__( obj, value ) )
                            {
                                return false;
                            }

                            can_close = true;
                        }

                        value = String::EMPTY_STRING;
                        value_is_string = false;
                        value_is_complete = false;
                        just_parsed_child = false;

                        if( c == ',' )
                            can_close = false;

                        if( c == ']' )
                        {
                            found_end = true;
                            break;
                        }
                    }
                    else if( __IsIgnoredChar__( c ) )
                    {
                        if( value != String::EMPTY_STRING )
                            value_is_complete = true;
                    }
                    else
                    {
                        if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '*' )
                        {
                            reading_commentary = true;
                            if( value != String::EMPTY_STRING )
                                value_is_complete = true;
                        }
                        else if( c == '/' && __Position__ < __Size__ && serialized[__Position__] == '/' )
                        {
                            reading_commentary = single_commentary = true;
                            if( value != String::EMPTY_STRING )
                                value_is_complete = true;
                        }
                        else
                        {
                            if( value_is_string || just_parsed_child || value_is_complete )
                            {
                                print( snprintf( cout, "ERROR: (Pos %1): Missing separating ',' in array", string( __Position__ ) ), Version::V2 );
                                return false;
                            }

                            value += c;
                        }
                    }
                }

                if( in_string )
                {
                    print( snprintf( cout, "ERROR: Unterminated string in array" ), Version::V2 );
                    return false;
                }

                if( reading_commentary )
                {
                    print( snprintf( cout, "ERROR: Unterminated commentary in array" ), Version::V2 );
                    return false;
                }

                if( !found_end )
                {
                    print( snprintf( cout, "ERROR: Unterminated array. Expected ']'" ), Version::V2 );
                    return false;
                }

                return true;
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            **/
            string Serialize( int indents, meta_api::json::v2::json@ obj )
            {
                return SerializeObject( obj, indents, 0 );
            }

            /**
            *   @brief Serializes obj.
            *   indents: -1 = single line, >= 0 = base tabs for root
            *   filename: a file name to write in "scripts/(module type)/store/(filename).json"
            *   Return whatever the content was written
            **/
            bool Serialize( meta_api::json::v2::json@ obj, string filename, int indents = -1 )
            {
                snprintf( filename, "scripts/%1/store/%2.json", ( g_Module.GetModuleName() == "MapModule" ? "maps" : "plugins" ), filename );

                File@ file = g_FileSystem.OpenFile( filename, OpenFile::WRITE );

                if( file !is null && file.IsOpen() )
                {
                    file.Write( Serialize( indents, obj ) );
                    file.Close();
                    return true;
                }

                print( snprintf( cout, "ERROR: Couldn't serialize content to \"%1\"", filename ), Version::V2 );

                return false;
            }

            /// Escape sequences from string, if add_quitation is true we also add a suffix and prefix quote
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

            string SerializeObject( meta_api::json::v2::json@ obj, int indents, int depth )
            {
                if( obj is null )
                    return "{}";

                bool is_array = ( obj.Type == meta_api::json::v2::Type::Array );
                bool is_object = ( obj.Type == meta_api::json::v2::Type::Object );

                if( !is_array && !is_object )
                    return "{}";

                array<string>@ keys = obj.Keys;

                if( keys.length() == 0 )
                {
                    if( is_array )
                        return "[]";
                    return "{}";
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
                    string key = keys[ui];

                    buffer += ( depth > 0 ? indent_inner : indent_str );

                    if( !is_array )
                        buffer += EscapeSequences( key, true ) + ( indents > -1 ? ": " : ":" );

                    meta_api::json::v2::json@ value = obj[ key ];

                    if( value is null )
                    {
                        buffer += "null";
                    }
                    else
                    {
                        switch( value.Type )
                        {
                            case meta_api::json::v2::Type::String:
                            {
                                buffer += EscapeSequences( string( value.Value ), true );
                                break;
                            }
                            case meta_api::json::v2::Type::Null:
                            {
                                buffer += "null";
                                break;
                            }
                            case meta_api::json::v2::Type::Float:
                            {
                                buffer += float( value.Value );
                                break;
                            }
                            case meta_api::json::v2::Type::Integer:
                            {
                                buffer += int( value.Value );
                                break;
                            }
                            case meta_api::json::v2::Type::Boolean:
                            {
                                buffer += ( bool( value.Value ) ? "true" : "false" );
                                break;
                            }
                            case meta_api::json::v2::Type::Object:
                            case meta_api::json::v2::Type::Array:
                            {
                                buffer += SerializeObject( value, indents, depth + 1 );
                                break;
                            }
                        }
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

            namespace fmt
            {
                /// If the json is type of Array or Object converts the values to the array type and allocate it in the json.Value set the list handle to that array and updates the type to Handle. return false otherwise
                bool ToArray( meta_api::json::v2::json@ json, array<float>@&out list, bool strict = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::v2::Type::Array:
                            case meta_api::json::v2::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    float fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::v2::Type::Handle );
                                return true;
                            }
                            case meta_api::json::v2::Type::Handle:
                            {
                                array<float>@ ar = cast<array<float>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type and allocate it in the json.Value set the list handle to that array and updates the type to Handle. return false otherwise
                bool ToArray( meta_api::json::v2::json@ json, array<int>@&out list, bool strict = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::v2::Type::Array:
                            case meta_api::json::v2::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    int fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::v2::Type::Handle );
                                return true;
                            }
                            case meta_api::json::v2::Type::Handle:
                            {
                                array<int>@ ar = cast<array<int>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type and allocate it in the json.Value set the list handle to that array and updates the type to Handle. return false otherwise
                bool ToArray( meta_api::json::v2::json@ json, array<bool>@&out list, bool strict = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::v2::Type::Array:
                            case meta_api::json::v2::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    bool fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::v2::Type::Handle );
                                return true;
                            }
                            case meta_api::json::v2::Type::Handle:
                            {
                                array<bool>@ ar = cast<array<bool>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
                /// If the json is type of Array or Object converts the values to the array type and allocate it in the json.Value set the list handle to that array and updates the type to Handle. return false otherwise
                bool ToArray( meta_api::json::v2::json@ json, array<string>@&out list )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::v2::Type::Array:
                            case meta_api::json::v2::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    string fvalue;
                                    if( value.Get( fvalue ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::v2::Type::Handle );
                                return true;
                            }
                            case meta_api::json::v2::Type::Handle:
                            {
                                array<string>@ ar = cast<array<string>@>( json.Value );
                                if( ar !is null ) {
                                    @list = ar;
                                    return true;
                                }
                                break;
                            }
                        }
                    }
                    return false;
                }
            } // fmt
        } // v2
    } // json
} // meta_api
