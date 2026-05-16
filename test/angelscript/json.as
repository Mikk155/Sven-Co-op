#include "../../scripts/mikk155/meta_api/json/v1"
#include "../../scripts/mikk155/meta_api/json/v2"

namespace test
{
namespace json
{
void PluginInit()
{
string serialized = """{
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

meta_api::json::v2::json json;
if( meta_api::json::v2::Deserialize( serialized, json ) )
{
    g_Game.AlertMessage( at_console, "length -> " + json.Length() + "\n" );

    g_Game.AlertMessage( at_console, "default_integer_of_5 -> " + json.FirstOrDefault( "default_integer_of_5", 5, true ) + "\n" );
    g_Game.AlertMessage( at_console, "default_integer_of_5 now stored -> " + int( json.First( "default_integer_of_5" ) ) + "\n" );
    g_Game.AlertMessage( at_console, "default_bool_of_true -> " + ( json.FirstOrDefault( "default_bool_of_true", true ) ? "true" : "false" ) + "\n" );
    g_Game.AlertMessage( at_console, "default_float_of_1_5 -> " + json.FirstOrDefault( "default_float_of_1_5", 1.5f ) + "\n" );
    g_Game.AlertMessage( at_console, "default_string_str -> " + json.FirstOrDefault( "default_string_str", "str" ) + "\n" );

    g_Game.AlertMessage( at_console, "float -> " + float( json.First( "float" ) ) + "\n" );
    g_Game.AlertMessage( at_console, "bool -> " + ( bool( json.First( "bool" ) ) ? "true" : "false" ) + "\n" );
    g_Game.AlertMessage( at_console, "string -> " + string( json.First( "string" ) ) + "\n" );
    g_Game.AlertMessage( at_console, "object::string -> " + string( json.First( "object" ).First( "string" ) ) + "\n" );

    try {
        json.push_back( "something" );
    }
    catch {
        g_Game.AlertMessage( at_console, "Exception at json.push_back\n" );
    }

    meta_api::json::v2::json@ nestedArray = json.First( "array" );

    if( nestedArray !is null )
    {
        g_Game.AlertMessage( at_console, "push \"%1\" to \"array\" at index %2\n", string( nestedArray.push_back( "something" ) ), nestedArray.Length() );
        g_Game.AlertMessage( at_console, "array::0 -> " + string( nestedArray[0] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::1 -> " + ( bool( nestedArray[1] ) ? "true" : "false" ) + "\n" );
        g_Game.AlertMessage( at_console, "array::2 -> " + int( nestedArray[2] ) + "\n" );
        g_Game.AlertMessage( at_console, "array::3 -> " + float( nestedArray[3] ) + "\n" );

        meta_api::json::v2::json@ nestedObjectInArray = nestedArray[4];

        if( nestedObjectInArray !is null )
        {
            g_Game.AlertMessage( at_console, "array::4::key -> " + string( nestedObjectInArray.First( "key" ) ) + "\n" );
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
