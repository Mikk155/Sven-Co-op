#include "../../scripts/mikk155/meta_api/json/v1"
#include "../../scripts/mikk155/meta_api/json/v2"
#include "../../scripts/mikk155/meta_api/json/v2/fmt/core"

namespace test
{
namespace json
{
uint g_Passed;
uint g_Failed;

meta_api::json::Version g_Version;

const string g_DeserializeSample = """
// Single line comment outside of object
{ // Single line after token in object
    "null": null,
    "bool": true,
    "int": 1,
    "float": 1.5, // Single line after token in pair
    "string": "text",
    "object":
    {
        "value": 2
    },
    "array":
    [
        "x",
        true,
        2,
        3.5,
        {
            "key": "value"
        } // Single line after token in array
    ] // Single line after token in last pair
} // Single line after token outside of object
""";

void Expect( const string&in name, bool condition )
{
    if( condition )
    {
        g_Passed++;
        meta_api::json::print( snprintf( meta_api::json::cout, "PASS: %1", name ), g_Version );
        return;
    }

    g_Failed++;
    meta_api::json::print( snprintf( meta_api::json::cout, "FAIL: %1", name ), g_Version );
}

namespace v2
{
    meta_api::json::v2::json@ ExpectDeserialize( const string&in name, bool expected, const string&in source )
    {
        meta_api::json::v2::json@ obj;
        bool result = meta_api::json::v2::Deserialize( source, obj );

        Expect( name, result == expected );

        if( result )
            return obj;

        return null;
    }
}

namespace v1
{
    dictionary@ ExpectDeserialize( const string&in name, bool expected, const string&in source )
    {
        dictionary obj;
        bool result = meta_api::json::v1::Deserialize( source, obj );

        Expect( name, result == expected );

        if( result )
            return @obj;

        return null;
    }
}

void RunTests( const meta_api::json::Version&in version, bool metamod )
{
    g_Version = version;
    g_Passed = g_Failed = 0;

    meta_api::json::print( snprintf( meta_api::json::cout, "===== Running json tests for %1 =====", ( metamod ? "METAMOD" : "VANILLA" ) ), g_Version );

#if METAMOD_PLUGIN_ASLP
    meta_api::json::__METAMOD__ = !metamod;
#endif

    switch( version )
    {
        case meta_api::json::Version::V1:
        {
            dictionary@ obj = v1::ExpectDeserialize( "valid object with comments and nested values", true, g_DeserializeSample );
            break;
        }
        case meta_api::json::Version::V2:
        {
            meta_api::json::v2::json@ obj = v2::ExpectDeserialize( "valid object with comments and nested values", true, g_DeserializeSample );
            break;
        }
    }

// Restore after test to not mess up the module
#if METAMOD_PLUGIN_ASLP
    meta_api::json::__METAMOD__ = true;
#endif

    if( g_Failed == 0 )
    {
        meta_api::json::print( snprintf( meta_api::json::cout, "===== All %1 tests passed =====", g_Passed ), g_Version );
    }
    else if( g_Passed == 0 )
    {
        meta_api::json::print( snprintf( meta_api::json::cout, "===== All %1 tests failed =====", g_Passed ), g_Version );
    }
    else
    {
        meta_api::json::print( snprintf( meta_api::json::cout, "===== Passed: %1 =====", g_Passed ), g_Version );
        meta_api::json::print( snprintf( meta_api::json::cout, "===== Failed: %1 =====", g_Failed ), g_Version );
    }

    meta_api::json::print( "=====All done!=====", g_Version );
}

void PluginInit()
{
    array<meta_api::json::Version> versionRuns = {
        meta_api::json::Version::V1,
        meta_api::json::Version::V2
    };

    for( uint ui = 0; ui < versionRuns.length(); ui++ )
    {
#if METAMOD_PLUGIN_ASLP
        RunTests( versionRuns[ui], true );
#endif
        RunTests( versionRuns[ui], false );
    }

    if( true )
        return;
string serialized = """{
 "null": null,
 // Single line commentary
 "int": 1,
 "float": 2.5,
 /*
 Multi line commentary
 */
 "bool": true,
 "string": "string", // Commentary after a line
 "object":
 {
  "string": "string in object"
 },
 "array":
 [
  "index 0",
  true,
  2,
  3.5,
  {
   "key": "string in object in array"
  }
 ]
}""";

string serialized_array = """[
 "string",
 1
]""";
g_Game.AlertMessage( at_console, "String serialized:\n%1\n", serialized );
g_Game.AlertMessage( at_console, "String serialized_array:\n%1\n", serialized_array );

{ // v1
g_Game.AlertMessage( at_console,  "========================== json V1 ==========================\n" );

dictionary json;
if( meta_api::json::v1::Deserialize( serialized, json ) )
{
    //-TODO maybe fix null at V1? no real reason to use this rather than V2...
//    g_Game.AlertMessage( at_console, "null -> " + ( json.exists( "null" ) ? "exists" : "not exists" ) + "\n" );
    g_Game.AlertMessage( at_console, "int -> " + int( json[ "int" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "float -> " + float( json[ "float" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "bool -> " + ( bool( json[ "bool" ] ) ? "true" : "false" ) + "\n" );
    g_Game.AlertMessage( at_console, "string -> " + string( json[ "string" ] ) + "\n" );

    dictionary nestedObject;
    if( json.get( "object", nestedObject ) )
    {
        g_Game.AlertMessage( at_console, "object::string -> " + string( nestedObject[ "string" ] ) + "\n" );
    }

    dictionary nestedArray;

    if( json.get( "array", nestedArray ) )
    {
        g_Game.AlertMessage( at_console, "array::0 -> " + string( nestedArray[ "0" ] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::1 -> " + ( bool( nestedArray[ "1" ] ) ? "true" : "false" ) + "\n" );
        g_Game.AlertMessage( at_console, "array::2 -> " + int( nestedArray[ "2" ] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::3 -> " + float( nestedArray[ "3" ] ) + "\n" );
    
        dictionary nestedObjectInArray;
        if( nestedArray.get( "4", nestedObjectInArray ) )
        {
            g_Game.AlertMessage( at_console, "array::4::key -> " + string( nestedObjectInArray[ "key" ] ) + "\n" );
        }
    }
    g_Game.AlertMessage( at_console, "meta_api::json::v1::Serialized( serialized )\n%1\n", meta_api::json::v1::Serialize(1, json ) );
}

if( meta_api::json::v1::Deserialize( serialized_array, json ) )
{
    g_Game.AlertMessage( at_console, "0 -> " + string( json[ "0" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "1 -> " + int( json[ "1" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "meta_api::json::v1::Serialized( serialized_array )\n%1\n", meta_api::json::v1::Serialize(1, json ) );
}
} // v1

{ // v2
g_Game.AlertMessage( at_console,  "========================== json V2 ==========================\n" );

meta_api::json::v2::json@ json = meta_api::json::v2::json();;
if( json.Load( serialized ) )
{
    g_Game.AlertMessage( at_console, "length -> " + json.Length() + "\n" );

    g_Game.AlertMessage( at_console, "null -> " + ( json.Contains( "null" ) ? "exists" : "not exists" ) + "\n" );
    g_Game.AlertMessage( at_console, "default_integer_of_5 -> " + json.ValueOrDefault( "default_integer_of_5", 5, true ) + "\n" );
    g_Game.AlertMessage( at_console, "default_integer_of_5 now stored -> " + int( json[ "default_integer_of_5" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "default_bool_of_true -> " + ( json.ValueOrDefault( "default_bool_of_true", true ) ? "true" : "false" ) + "\n" );
    g_Game.AlertMessage( at_console, "default_float_of_1_5 -> " + json.ValueOrDefault( "default_float_of_1_5", 1.5f ) + "\n" );
    g_Game.AlertMessage( at_console, "default_string_str -> " + json.ValueOrDefault( "default_string_str", "str" ) + "\n" );

    g_Game.AlertMessage( at_console, "float -> " + float( json[ "float" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "bool -> " + ( bool( json[ "bool" ] ) ? "true" : "false" ) + "\n" );
    g_Game.AlertMessage( at_console, "string -> " + string( json[ "string" ] ) + "\n" );
    g_Game.AlertMessage( at_console, "Key name of object \"object\" -> " + json[ "object" ].Name + "\n" );
    g_Game.AlertMessage( at_console, "object::string -> " + string( json[ "object" ][ "string" ] ) + "\n" );

    try {
        json.Append( "something" );
    }
    catch {
        g_Game.AlertMessage( at_console, "Exception at json.Append\n" );
    }

    meta_api::json::v2::json@ nestedArray = json[ "array" ];

    if( nestedArray !is null )
    {
        g_Game.AlertMessage( at_console, "push \"%1\" to \"array\" at index %2\n", string( nestedArray.Append( "something" ) ), nestedArray.Length() );
        g_Game.AlertMessage( at_console, "array::0 -> " + string( nestedArray[0] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::1 -> " + ( bool( nestedArray[1] ) ? "true" : "false" ) + "\n" );
        g_Game.AlertMessage( at_console, "array::2 -> " + int( nestedArray[2] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::3 -> " + float( nestedArray[3] ) + "\n" );

        meta_api::json::v2::json@ nestedObjectInArray = nestedArray[4];

        if( nestedObjectInArray !is null )
        {
            g_Game.AlertMessage( at_console, "Key name of object \"array::4\" -> " + nestedObjectInArray.Name + "\n" );
            g_Game.AlertMessage( at_console, "array::4::key -> " + string( nestedObjectInArray[ "key" ] ) + "\n" );
        }

        array<float>@ fmt_float;

        if( meta_api::json::v2::fmt::ToArray( nestedArray, fmt_float, false ) )
        {
            g_Game.AlertMessage( at_console, "Converted \"array\" into array<float>@\n" );
            for( uint ui = 0; ui < fmt_float.length(); ui++ )
            {
                g_Game.AlertMessage( at_console, "[%1] -> %2\n", ui, fmt_float[ui] );
            }

            // Test Handle casted reference
            fmt_float.removeAt(0);
            if( meta_api::json::v2::fmt::ToArray( nestedArray, fmt_float, false ) )
            {
                g_Game.AlertMessage( at_console, "Handle \"array\" reference array<float>@ with item [0] removed\n" );
                for( uint ui = 0; ui < fmt_float.length(); ui++ )
                {
                    g_Game.AlertMessage( at_console, "[%1] -> %2\n", ui, fmt_float[ui] );
                }
            }
        }
    }
    g_Game.AlertMessage( at_console, "meta_api::json::v1::Serialized( serialized )\n%1\n", meta_api::json::v2::Serialize(1, json ) );
}

if( meta_api::json::v2::Deserialize( serialized_array, json ) )
{
    g_Game.AlertMessage( at_console, "0 -> " + string( json[0] ) + "\n" );
    g_Game.AlertMessage( at_console, "1 -> " + int( json[1] ) + "\n" );
    g_Game.AlertMessage( at_console, "meta_api::json::v1::Serialized( serialized_array )\n%1\n", meta_api::json::v2::Serialize(1, json ) );
}
} // v2
} // PluginInit
} // json
} // Test
