#include "../../scripts/mikk155/meta_api/core"

namespace test
{
    namespace json
    {
        void PluginInit()
        {
            string serialized = '
{
    "int": 1,
    "float": 2.5,
    "bool": true,
    "string": "string",
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
}';

            g_Game.AlertMessage( at_console, serialized + "\n" );

            dictionary deserialized;
            meta_api::json::Deserialize( serialized, deserialized );

            g_Game.AlertMessage( at_console, "int -> " + int( deserialized[ "int" ] ) + "\n" );
            g_Game.AlertMessage( at_console, "float -> " + float( deserialized[ "float" ] ) + "\n" );
            g_Game.AlertMessage( at_console, "bool -> " + ( bool( deserialized[ "bool" ] ) ? "true" : "false" ) + "\n" );
            g_Game.AlertMessage( at_console, "string -> " + string( deserialized[ "string" ] ) + "\n" );

            dictionary nestedObject;
            if( deserialized.get( "object", nestedObject ) )
            {
                g_Game.AlertMessage( at_console, "object::string -> " + string( nestedObject[ "string" ] ) + "\n" );
            }

            dictionary nestedArray;

            if( deserialized.get( "array", nestedArray ) )
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

            serialized = '
[
    "string",
    1
]';
            g_Game.AlertMessage( at_console, serialized + "\n" );
            meta_api::json::Deserialize( serialized, deserialized );
            g_Game.AlertMessage( at_console, "0 -> " + string( deserialized[ "0" ] ) + "\n" );
            g_Game.AlertMessage( at_console, "1 -> " + int( deserialized[ "1" ] ) + "\n" );
        }
    }
}
