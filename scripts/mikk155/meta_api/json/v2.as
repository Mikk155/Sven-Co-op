#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 2 of Json. conversion to/from class.
        /// Work in progress. expect API changes.
        namespace v2
        {
            /// Json is a complete wrapper to dictionary and array the main difference is that json is ordered.
            /// If something is missing you can either pull request or just inherit from this class and make your specific changes according to your needs.
            class json
            {
                protected
                    meta_api::json::Type m_Type = meta_api::json::Type::Undefined;

                // Current type of this object.
                const meta_api::json::Type& get_Type() const {
                    return this.m_Type;
                }

                /// Return whatever value is a bool
                bool is_boolean() const {
                    return ( this.Type == meta_api::json::Type::Boolean );
                }
                /// Return whatever value is a integer
                bool is_number_integer() const {
                    return ( this.Type ==  meta_api::json::Type::Integer );
                }
                /// Return whatever value is a float with decimals
                bool is_number_float() const {
                    return ( this.Type ==  meta_api::json::Type::Float );
                }
                /// Return whatever value is a string
                bool is_string() const {
                    return ( this.Type ==  meta_api::json::Type::String );
                }
                /// Return whatever value is a json object
                bool is_object() const {
                    return ( this.Type ==  meta_api::json::Type::Object );
                }
                /// Return whatever value is a json array
                bool is_array() const {
                    return ( this.Type ==  meta_api::json::Type::Array );
                }
                /// Return whatever value is null but existent
                bool is_null() const {
                    return ( this.Type ==  meta_api::json::Type::Null );
                }
                /// Return whatever value is a handle to an object
                bool is_handle() const {
                    return ( this.Type ==  meta_api::json::Type::Handle );
                }
                /// Return whatever value is a json object or array structure
                bool is_structured() const {
                    return ( this.is_object() || this.is_array() );
                }
                /// Return whatever value is a number either float or integer
                bool is_number() const {
                    return ( this.is_number_integer() || this.is_number_float() );
                }
                /// Return whatever value is a non-negative integer
                bool is_number_unsigned() const {
                    return ( this.is_number_integer() && int( this.m_KeyValues[ this.__Value__ ] ) >= 0 );
                }

                string m_Name;

                /// Key name of this object
                const string& get_Name() const {
                    return this.m_Name;
                }

                /// Unordered key-values
                dictionary m_KeyValues = {};

                /// Ordered key names
                array<string> m_KeyNames = {};

                /// Return all the key names of this object/array
                const array<string>@ get_Keys() const
                {
                    switch( this.Type )
                    {
                        case meta_api::json::Type::Object:
                        case meta_api::json::Type::Array:
                        {
                            return @this.m_KeyNames;
                        }
                        case meta_api::json::Type::String:
                        case meta_api::json::Type::Float:
                        case meta_api::json::Type::Integer:
                        case meta_api::json::Type::Boolean:
                        case meta_api::json::Type::Null:
                        default:
                            return @null;
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

                void SetType( const meta_api::json::Type&in type )
                {
                    switch( type )
                    {
                        case meta_api::json::Type::Object:
                        case meta_api::json::Type::Array:
                        {
                            this.Clear();
                            break;
                        }
                        case meta_api::json::Type::String:
                        case meta_api::json::Type::Handle:
                        case meta_api::json::Type::Float:
                        case meta_api::json::Type::Integer:
                        case meta_api::json::Type::Boolean:
                        case meta_api::json::Type::Null:
                        default:
                        {
                            dictionaryValue@ value = this.m_KeyValues[ this.__Value__ ];
                            this.Clear();
                            this.m_KeyValues[ this.__Value__ ] = value;
                            break;
                        }
                    }

                    this.m_Type = type;
                }

                /// Set a value of any type. "value" could be set by using Value.opAssign(T) from this object
                void SetValue( const dictionaryValue&in value, const meta_api::json::Type&in type )
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

                meta_api::json::v2::json@ opAssign( const float value ) {
                    this.SetValue( this.Value.opAssign(value), meta_api::json::Type::Float ); return this;
                }
                meta_api::json::v2::json@ opAssign( const int value ) {
                    this.SetValue( this.Value.opAssign(value), meta_api::json::Type::Integer ); return this;
                }
                meta_api::json::v2::json@ opAssign( const bool value ) {
                    this.SetValue( this.Value.opAssign(value), meta_api::json::Type::Boolean ); return this;
                }
                meta_api::json::v2::json@ opAssign( const string&in value ) {
                    this.SetValue( this.Value.opAssign(value), meta_api::json::Type::String ); return this;
                }
                meta_api::json::v2::json@ opAssign( const meta_api::json::v2::Null&in value ) {
                    this.SetValue( this.Value.opAssign(value), meta_api::json::Type::Null ); return this;
                }

                /// ======================================
                /// opConv
                /// ======================================
                float opConv() {
                    return float( this.Value );
                }
                int opConv() {
                    return int( this.Value );
                }
                bool opConv() {
                    return bool( this.Value );
                }
                string opConv() {
                    return string( this.Value );
                }

                /// ======================================
                /// Constructors
                /// ======================================
                json( meta_api::json::v2::json@ other )
                {
                    this.opAssign( other );
                }

                json()
                {
                    this.m_Type = meta_api::json::Type::Object;
                }

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
                bool Contains( const string&in keyName ) const
                {
                    return this.m_KeyValues.exists( keyName );
                }

                /// Get the length of the object.
                uint Length() const
                {
                    switch( this.Type )
                    {
                        case meta_api::json::Type::Object:
                        case meta_api::json::Type::Array:
                            return this.m_KeyNames.length();
                        case meta_api::json::Type::String:
                        case meta_api::json::Type::Handle:
                        case meta_api::json::Type::Float:
                        case meta_api::json::Type::Integer:
                        case meta_api::json::Type::Boolean:
                        case meta_api::json::Type::Null:
                        case meta_api::json::Type::Undefined:
                        default:
                            return 0;
                    }
                }

                /// Set key value pair, return the old value if it exists otherwise null
                meta_api::json::v2::json@ Set( const string&in keyName, meta_api::json::v2::json@ value )
                {
                    meta_api::json::v2::json@ old = cast<meta_api::json::v2::json@>( this.m_KeyValues[ keyName ] );

                    if( value is null )
                    {
                        print::error( snprintf( cout, "Couldn't set null json value for key \"%1\"", keyName ), Version::V2 );
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
                    value.m_Name = keyName;

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
                    if( strict && this.Type != meta_api::json::Type::Boolean )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::Type::Integer:
                            value = ( int( this.Value ) > 0 );
                            return true;
                        case meta_api::json::Type::Float:
                            value = ( int( float( this.Value ) ) > 0 );
                            return true;
                        case meta_api::json::Type::Boolean:
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
                    if( strict && this.Type != meta_api::json::Type::Integer )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::Type::Boolean:
                            value = ( bool( this.Value ) ? 1 : 0 );
                            return true;
                        case meta_api::json::Type::Float:
                            value = int( float( this.Value ) );
                            return true;
                        case meta_api::json::Type::Integer:
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
                    if( strict && this.Type != meta_api::json::Type::Float )
                        return false;

                    switch( this.Type )
                    {
                        case meta_api::json::Type::Boolean:
                            value = ( bool( this.Value ) ? 1.0f : 0.0f );
                            return true;
                        case meta_api::json::Type::Integer:
                            value = float( int( this.Value ) );
                            return true;
                        case meta_api::json::Type::Float:
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
                        case meta_api::json::Type::String:
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
                uint __unique_index__ = 0;

                /// ======================================
                /// Array methods
                /// ======================================
                /// For arrays, push value to the last index
                meta_api::json::v2::json@ Append( meta_api::json::v2::json@ value )
                {
                    if( this.Type != meta_api::json::Type::Array )
                    {
                        print::error( snprintf( cout, "Couldn't Append to a json that is not an array!" ), Version::V2 );
                        return null;
                    }

                    if( value is null )
                    {
                        print::error( snprintf( cout, "Couldn't Append a null json value!" ), Version::V2 );
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

                /// Get the value at the given key
                const meta_api::json::v2::json@ opIndex( const string&in keyName ) const {
                    return this.opIndex(keyName);
                }

                meta_api::json::v2::json@ opIndex( uint index )
                {
                    if( index >= this.m_KeyNames.length() )
                    {
                        print::error( snprintf( cout, "Index %1 is outside json length %2", index, this.m_KeyNames.length() ), Version::V2 );
                        return null;
                    }

                    return this.opIndex( this.m_KeyNames[ index ] );
                }

                const meta_api::json::v2::json@ opIndex( uint index ) const {
                    return this.opIndex(index);
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

                /// Removes the value at the given key. returns the value
                meta_api::json::v2::json@ Remove( const string&in key )
                {
                    if( !this.is_object() )
                    {
                        print::error( snprintf( cout, "Can not Remove value at key %1 from a json that is not an object! type: %2", key, Type::ToString( this.Type ) ), Version::V2 );
                    }

                    meta_api::json::v2::json@ value;
                    this.Get( key, value );

                    this.m_KeyValues.delete( key );

                    return value;
                }

                /// Removes the value at the given index. returns the value
                meta_api::json::v2::json@ Remove( uint index )
                {
                    if( !this.is_structured() )
                    {
                        print::error( snprintf( cout, "Can not Remove value at index %1 from a json that is not an object! type: %2", index, Type::ToString( this.Type ) ), Version::V2 );
                    }

                    meta_api::json::v2::json@ value;
                    if( index < this.Length() )
                    {
                        @value = this.opIndex(index);
                        this.m_KeyValues.delete( this.m_KeyNames[index] );
                    }

                    return value;
                }

                /// Get the value converted to string.
                /// For objects/arrays this is a serialization with -1 indents.
                string ToString()
                {
                    switch( this.Type )
                    {
                        case meta_api::json::Type::Object:
                        case meta_api::json::Type::Array:
                        {
                            //return Serialize(-1, this);
                        }
                        case meta_api::json::Type::String:
                            return string( this.Value );
                        case meta_api::json::Type::Float:
                            return string( float( this.Value ) );
                        case meta_api::json::Type::Integer:
                            return string( int( this.Value ) );
                        case meta_api::json::Type::Boolean:
                            return ( bool( this.Value ) ? "true" : "false" );
                        case meta_api::json::Type::Handle:
                            return "@";
                        case meta_api::json::Type::Null:
                        default:
                            return "null";
                    }
                }
            }

            class __Deserializer__ : meta_api::json::parser::Deserializer
            {
                const meta_api::json::Version GetVersion() const override {
                    return meta_api::json::Version::V2;
                }

                bool Parse( meta_api::json::v2::json@&out obj, const meta_api::json::Type&in objectType )
                {
                    if( obj is null )
                        @obj = meta_api::json::v2::json();

                    obj.SetType( objectType );

                    meta_api::json::parser::KeyValuePair@ pair;

                    while( this.Advance( objectType, pair ) )
                    {
                        switch( pair.type )
                        {
                            case meta_api::json::Type::Object:
                            case meta_api::json::Type::Array:
                            {
                                meta_api::json::v2::json@ objChild;
                                if( this.Parse( objChild, pair.type ) )
                                    obj.Set( pair.key, objChild );
                                break;
                            }
                            case meta_api::json::Type::String:
                            {
                                obj.Set( pair.key, pair.value_string );
                                break;
                            }
                            case meta_api::json::Type::Float:
                            {
                                obj.Set( pair.key, pair.value_float );
                                break;
                            }
                            case meta_api::json::Type::Integer:
                            {
                                obj.Set( pair.key, pair.value_int );
                                break;
                            }
                            case meta_api::json::Type::Boolean:
                            {
                                obj.Set( pair.key, pair.value_bool );
                                break;
                            }
                            case meta_api::json::Type::Null:
                            {
                                obj.Set( pair.key, meta_api::json::Null::Null );
                                break;
                            }
                        }

                        // Hack to Append
                        if( objectType == meta_api::json::Type::Array )
                            obj.__unique_index__++;
                    }
                    return this.Ok;
                }
            }

            string Serialize( meta_api::json::v2::json@ obj, meta_api::json::parser::Serializer@ Serializer )
            {
                const array<string>@ keys = obj.Keys;
                uint length = keys.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    string key = keys[ui];

                    meta_api::json::v2::json@ value = obj[ key ];

                    if( value is null )
                        continue;

                    switch( value.Type )
                    {
                        case meta_api::json::Type::Handle:
                        {
                            if( debug )
                                print::debug( snprintf( cout, "Handle pointer serialization is not supported. storing as \"null\"" ), Version::V2 );
                            Serializer.KeyValue( key, "null", meta_api::json::Type::Null );
                            break;
                        }
                        case meta_api::json::Type::String:
                        {
                            Serializer.KeyValue( key, string( value.Value ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Float:
                        {
                            Serializer.KeyValue( key, float( value.Value ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Integer:
                        {
                            Serializer.KeyValue( key, int( value.Value ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Boolean:
                        {
                            Serializer.KeyValue( key, bool( value.Value ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Object:
                        {
                            Serializer.KeyValue( key, meta_api::json::v2::Serialize( value, Serializer.Object( value.Type ) ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Array:
                        {
                            Serializer.KeyValue( key, meta_api::json::v2::Serialize( value, Serializer.Object( value.Type ) ), value.Type );
                            break;
                        }
                        case meta_api::json::Type::Null:
                        {
                            Serializer.KeyValue( key, "null", value.Type );
                            break;
                        }
                    }
                }

                return Serializer.Serialize();
            }

            /**
            *   @brief Serializes obj
            *   filename: if provided is a path to write to a file at scripts(module type)/store/(filename).json
            *   If the object failed to parse for any reason it will write "{}" to the file only if the file doesn't exists
            **/
            string Serialize(
                meta_api::json::v2::json@ obj,
                const string&in filename = String::EMPTY_STRING,
                const meta_api::json::parser::Indentation&in indents = meta_api::json::parser::Indentation::AllTogether,
                const meta_api::json::parser::Style&in style = meta_api::json::parser::Style::AllMan
            )
            {
                return meta_api::json::v2::Serialize(
                    obj,
                    meta_api::json::parser::Serializer(
                        1,
                        filename,
                        obj.Type,
                        style,
                        indents,
                        meta_api::json::Version::V1
                    )
                );
            }

            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return a valid handle
            **/
            bool Deserialize( const string&in str, meta_api::json::v2::json@&out obj )
            {
                meta_api::json::v2::__Deserializer__ Deserializer();
                Deserializer.SetSerialized(str);
                return Deserializer.Parse( obj, Deserializer.Initialize() );
            }
        } // v2
    } // json
} // meta_api
