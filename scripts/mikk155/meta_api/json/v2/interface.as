/// Implements interfaces for syntax suggar
// Just a prototype till VSC extension gets some more updates

#include "../v2"

interface JToken
{
    // Current type of this object.
    const meta_api::json::v2::Type& get_Type() const;
    /// Return whatever value is a bool
    bool is_boolean() const;
    /// Return whatever value is a integer
    bool is_number_integer() const;
    /// Return whatever value is a float with decimals
    bool is_number_float() const;
    /// Return whatever value is a string
    bool is_string() const;
    /// Return whatever value is a json object
    bool is_object() const;
    /// Return whatever value is a json array
    bool is_array() const;
    /// Return whatever value is null but existent
    bool is_null() const;
    /// Return whatever value is a handle to an object
    bool is_handle() const;
    /// Return whatever value is a json object or array structure
    bool is_structured() const;
    /// Return whatever value is a number either float or integer
    bool is_number() const;
    /// Return whatever value is a non-negative integer
    bool is_number_unsigned() const;
    /// Key name of this object
    const string& get_Name() const;
    /// Internal value
    dictionaryValue@ get_Value();
    meta_api::json::v2::json@ opAssign( meta_api::json::v2::json@ value );
    meta_api::json::v2::json@ opAssign( const float value );
    meta_api::json::v2::json@ opAssign( const int value );
    meta_api::json::v2::json@ opAssign( const bool value );
    meta_api::json::v2::json@ opAssign( const string&in value );
    meta_api::json::v2::json@ opAssign( const meta_api::json::v2::Null&in value );
    /**
    *   @brief Deserializes str
    *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
    *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return a valid handle
    **/
    bool Load( const string&in str );
    /// Set key value pair, return the old value if it exists otherwise null
    meta_api::json::v2::json@ Set( const string&in keyName, meta_api::json::v2::json@ value );
    meta_api::json::v2::json@ Set( const string&in keyName, const bool value );
    meta_api::json::v2::json@ Set( const string&in keyName, const int value );
    meta_api::json::v2::json@ Set( const string&in keyName, const float value );
    meta_api::json::v2::json@ Set( const string&in keyName, const string&in value );
    meta_api::json::v2::json@ Set( const string&in keyName, const meta_api::json::v2::Null&in value );
    string ToString();
}

// Json value
interface JValue : JToken
{
    float opConv();
    int opConv();
    bool opConv();
    string opConv();
    /// Get the value&out and return whatever the value exists or not.
    /// If strict is true only values with the same return type will be accounted
    bool Get( const string&in keyName, string&out value );
    bool Get( bool&out value, bool strict = true );
    bool Get( int&out value, bool strict = true );
    bool Get( float&out value, bool strict = true );
    bool Get( string&out value );
}

interface JContainer
{
    /// Return all the key names of this object/array
    const array<string>@ get_Keys() const;
    /// Clear all data. only the type remains and whatever this is an ordered object.
    void Clear();
    /// Get the length of the object.
    int Length() const;
    /// Append value to the end of the list
    meta_api::json::v2::json@ Append( meta_api::json::v2::json@ value );
    meta_api::json::v2::json@ Append( const bool value );
    meta_api::json::v2::json@ Append( const int value );
    meta_api::json::v2::json@ Append( const float value );
    meta_api::json::v2::json@ Append( const string&in value );
    meta_api::json::v2::json@ Append( const meta_api::json::v2::Null&in value );
    /// Get the value at the given index
    meta_api::json::v2::json@ opIndex( uint index );
}

// Json object
interface JObject : JToken, JContainer
{
    /// Set a value of any type. "value" could be set by using Value.opAssign(T) from this object
    void SetValue( const dictionaryValue&in value, const meta_api::json::v2::Type&in type );
    /// Return whatever this objects contains the given key
    bool Contains( const string&in keyName ) const;
    /// Get the value&out and return whatever the value exists or not.
    /// If strict is true only values with the same return type will be accounted
    bool Get( const string&in keyName, meta_api::json::v2::json@&out value );
    bool Get( const string&in keyName, bool&out value, bool strict = true );
    bool Get( const string&in keyName, int&out value, bool strict = true );
    bool Get( const string&in keyName, float&out value, bool strict = true );
    /// Get the stored value at the given key name or a default value if not exists.
    /// If store is true the default value is stored in data if not exists
    /// In this json case if the default value is null we will initialize a instance and return that
    meta_api::json::v2::json@ ValueOrDefault( const string&in keyName, meta_api::json::v2::json@ value = null, bool store = false );
    /// Get the stored value at the given key name or a default value if not exists.
    /// If store is true the default value is stored in data if not exists
    /// If strict is true only values with the same return type will be accounted
    bool ValueOrDefault( const string&in keyName, bool value, bool store = false, bool strict = true );
    int ValueOrDefault( const string&in keyName, int value, bool store = false, bool strict = true );
    float ValueOrDefault( const string&in keyName, float value, bool store = false, bool strict = true );
    string ValueOrDefault( const string&in keyName, string&in value, bool store = false );
    /// Get the value at the given key
    meta_api::json::v2::json@ opIndex( const string&in keyName );
}

// Json array
interface JArray : JToken, JContainer
{
}

/// Json object
class json : meta_api::json::v2::json, JValue, JObject, JArray
{
}

void test()
{
    json@ js = json();
    js.Load( "bts_rc/config.json" );

    JObject@ o = js;
}
