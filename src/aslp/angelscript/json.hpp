#include <string_view>

#pragma once

#include <nlohmann/json.hpp>
#include <fmt/format.h>

#include <extdll.h>
#include <meta_api.h>
#include "aslp.h"

namespace json
{
    bool JsonToDict( const nlohmann::json& js, CScriptDictionary* dict )
    {
        if( !js.is_object() )
            return false;

        auto ASEngine = ASEXT_GetServerManager()->GetScriptEngine();
        auto dictionaryType = ASEngine->GetTypeInfoByName( "dictionary" );
        int dictionaryId = ASEngine->GetTypeIdByDecl("dictionary@");

        auto stringType = ASEngine->GetTypeInfoByName( "string" );
        int stringId = ASEngine->GetTypeIdByDecl("string");

        CString* asKey = reinterpret_cast<CString*>( ASEngine->CreateScriptObject( stringType ) );
        CString* asValue = reinterpret_cast<CString*>( ASEngine->CreateScriptObject( stringType ) );

        for( auto& [ key, value ] : js.items() )
        {
            asKey->assign( key.c_str(), key.length() );

            if( value.is_string() )
            {
                auto strValue = value.get<std::string>();
                asValue->assign(strValue.c_str(), strValue.length());
                ASEXT_CScriptDictionary_Set(dict, asKey, asValue, stringId);
            }
            else if (value.is_number_integer())
            {
                int64_t v = value.get<int64_t>();
                ASEXT_CScriptDictionary_Set(dict, asKey, &v, asTYPEID_INT64);
            }
            else if (value.is_number_float())
            {
                double v = value.get<double>();
                ASEXT_CScriptDictionary_Set(dict, asKey, &v, asTYPEID_DOUBLE);
            }
            else if (value.is_boolean())
            {
                bool v = value.get<bool>();
                ASEXT_CScriptDictionary_Set(dict, asKey, &v, asTYPEID_BOOL);
            }
            else if (value.is_object())
            {
                auto asDictionary = reinterpret_cast<CScriptDictionary*>( ASEngine->CreateScriptObject( dictionaryType ) );
                JsonToDict(value, asDictionary);
                ASEXT_CScriptDictionary_Set( dict, asKey, &asDictionary, dictionaryId );
                ASEngine->ReleaseScriptObject( asDictionary, dictionaryType );
            }
        }

        ASEngine->ReleaseScriptObject( asKey, stringType );
        ASEngine->ReleaseScriptObject( asValue, stringType );

        return true;
    }
}

bool SC_SERVER_DECL CASEngineFuncs_JsonDeserialize( void* pthis, SC_SERVER_DUMMYARG const CString& str, CScriptDictionary* obj )
{
    try
    {
        auto js = nlohmann::json::parse( (char*)str.c_str() );
        return json::JsonToDict( js, obj );
    }
    catch( nlohmann::json::parse_error& exception )
    {
        ALERT( at_console, fmt::format( "JSON Error deserializing data at {}\n{}\n", exception.byte, exception.what() ).c_str() );
    }

    return true;
}

bool SC_SERVER_DECL CASEngineFuncs_JsonSerialize(void* pthis, SC_SERVER_DUMMYARG const CScriptDictionary* obj, CString& str, int indents = -1 )
{
    // Iterate over obj which is a dictionary and turn its variables into a json then dump into str
    try
    {
        auto js = nlohmann::json();
        std::string serialized = js.dump( indents /*, (char)32, false, json::error_handler_t::ignore*/ );
        str.assign( serialized.c_str(), serialized.length() );
        return true;
    }
    catch( nlohmann::json::type_error& exception )
    {
        ALERT( at_console, fmt::format( "JSON Error serializing data\n{}\n", exception.what() ).c_str() );
        str.assign( "{}", 2 );
    }

    return false;
}
