#include <nlohmann/json.hpp>
#include <fmt/format.h>

#pragma once

#include "mandatory.h"

namespace json
{
    /**
     * @brief Convert the given js object into the given dict object.
     * NOTE: If the js object is or have any array type it will also be converted into an object where the keys are the index of the values.
     */
    void ToDictionary( nlohmann::json& js, CScriptDictionary* dict )
    {
        if( !js.is_structured() )
            return;

        auto ASEngine = ASEXT_GetServerManager()->GetScriptEngine();

        auto dictionaryType = ASEngine->GetTypeInfoByName( "dictionary" );
        int dictionaryId = ASEngine->GetTypeIdByDecl( "dictionary@" );

        auto stringType = ASEngine->GetTypeInfoByName( "string" );
        int stringId = ASEngine->GetTypeIdByDecl( "string");

        CString* asKey = reinterpret_cast<CString*>( ASEngine->CreateScriptObject( stringType ) );
        CString* asValue = reinterpret_cast<CString*>( ASEngine->CreateScriptObject( stringType ) );

        auto SetDictionaryValue = [&]( const std::string& key, nlohmann::json& value )
        {
            asKey->assign( key.c_str(), key.length() );

            if( value.is_string() )
            {
                auto strValue = value.get<std::string>();
                asValue->assign( strValue.c_str(), strValue.length() );
                ASEXT_CScriptDictionary_Set( dict, asKey, asValue, stringId );
            }
            else if( value.is_number_integer() )
            {
                int64_t v = value.get<int64_t>();
                ASEXT_CScriptDictionary_Set( dict, asKey, &v, asTYPEID_INT64 );
            }
            else if( value.is_number_float() )
            {
                double v = value.get<double>();
                ASEXT_CScriptDictionary_Set( dict, asKey, &v, asTYPEID_DOUBLE );
            }
            else if( value.is_boolean() )
            {
                bool v = value.get<bool>();
                ASEXT_CScriptDictionary_Set( dict, asKey, &v, asTYPEID_BOOL );
            }
            else if( value.is_structured() )
            {
                auto asDictionary = reinterpret_cast<CScriptDictionary*>( ASEngine->CreateScriptObject( dictionaryType ) );
                ToDictionary( value, asDictionary ); // Nested dictionary
                ASEXT_CScriptDictionary_Set( dict, asKey, &asDictionary, dictionaryId );
                ASEngine->ReleaseScriptObject( asDictionary, dictionaryType );
            }
            else
            {
                ALERT( at_console, fmt::format( "JSON Warning ignoring unsuported type implementation \"{}\" for key \"{}\"\n", (int)value.type(), key.c_str() ).c_str() );
            }
        };

        if( js.is_object() )
        {
            for( auto& [ key, value ] : js.items() )
            {
                SetDictionaryValue( key, value );
            }
        }
        else
        {
            int index = 0;

            for( auto& value : js )
            {
                std::string key = std::to_string( index );
                SetDictionaryValue( key, value );
                index++;
            }
        }

        ASEngine->ReleaseScriptObject( asKey, stringType );
        ASEngine->ReleaseScriptObject( asValue, stringType );
    }
}

#include "../utils/File.hpp"

bool SC_SERVER_CDECL CASJsonDeserialize( const CString& str, CScriptDictionary* obj )
{
    std::string content = str.c_str();

    // Should maybe we check this is a plugin or map script?
    if( content.ends_with( ".json" ) )
    {
        File file( content );

        if( !file.Read( content ) )
            return false;
    }

    try
    {
        if( auto js = nlohmann::json::parse( (char*)content.c_str(), nullptr, true, true, true ); js.is_structured() )
        {
            json::ToDictionary( js, obj );
            return true;
        }
        ALERT( at_console, "JSON Error Can not parse json is not an object or array type!\n" );
    }
    catch( nlohmann::json::parse_error& exception )
    {
        ALERT( at_console, fmt::format( "JSON Error deserializing data at {}\n{}\n", exception.byte, exception.what() ).c_str() );
    }

    return false;
}
