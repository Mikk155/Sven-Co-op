#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 1 of Json. conversion to/from dictionary.
        /// It is recommended to use V2 instead as has way more features for configuring. V1 is ideal for simple objects as may be faster and uses less memory.
        /// Serializing loses data: "null" values are skiped. booleans are turned into integers. the object loses ordering. Arrays are also serialized as objects.
        /// Deserializing "null" values are skiped. array items are converted into a dictionary object where the key names are the item indexing
        namespace v1
        {
            class __Deserializer__ : meta_api::json::parser::Deserializer
            {
                const meta_api::json::Version GetVersion() const override {
                    return meta_api::json::Version::V1;
                }

                bool Parse( dictionary&out obj, const meta_api::json::Type&in objectType )
                {
                    obj.deleteAll();

                    string key;
                    string value;
                    dictionary data;
                    meta_api::json::Type type;

                    while( this.Advance( objectType, type, key, value, data ) )
                    {
                        switch( type )
                        {
                            case meta_api::json::Type::Object:
                            case meta_api::json::Type::Array:
                            {
                                dictionary objChild;
                                if( !this.Parse( objChild, type ) )
                                    return false;
                                obj[ key ] = objChild;
                                break;
                            }
                            case meta_api::json::Type::String:
                            {
                                obj.set( key, value );
                                break;
                            }
                            case meta_api::json::Type::Float:
                            {
                                obj.set( key, atof( value ) );
                                break;
                            }
                            case meta_api::json::Type::Integer:
                            {
                                obj.set( key, atoi( value ) );
                                break;
                            }
                            case meta_api::json::Type::Boolean:
                            {
                                obj.set( key, ( value == "true" ? true : false ) );;
                                break;
                            }
                            case meta_api::json::Type::Null:
                            {
                                obj.set( key, "__null__" );
                                break;
                            }
                            default:
                            {
                                return false;
                            }
                        }
                    }
                    return true;
                }
            }

            meta_api::json::Type __GetDictionaryType__( dictionary&in obj )
            {
                meta_api::json::Type type = meta_api::json::Type::Array;

                /// Confirm it's an "array" type where all keys are numeric and corresponds to indexes
                array<string>@ keys = obj.getKeys();
                uint length = keys.length();
                for( uint ui = 0; ui < length; ui++ )
                {
                    if( !obj.exists( string( ui ) ) )
                    {
                        type = meta_api::json::Type::Object;
                        break;
                    }
                }
                return type;
            }

            string Serialize( dictionary&in obj, meta_api::json::parser::Serializer@ Serializer )
            {
                string strValue;
                dictionary@ objValue = null; 
                int iValue;
                float fValue;

                array<string>@ keys = obj.getKeys();
                uint length = keys.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    string key = keys[ui];

                    if( obj.get( key, strValue ) )
                    {
                        if( strValue == "__null__" )
                            Serializer.KeyValue( key, "null", meta_api::json::Type::Null );
                        else
                            Serializer.KeyValue( key, strValue, meta_api::json::Type::String );
                    }
                    else if( obj.get( key, @objValue ) )
                    {
                        auto objType = meta_api::json::v1::__GetDictionaryType__(objValue);
                        Serializer.KeyValue( key, meta_api::json::v1::Serialize( objValue, Serializer.Object( objType ) ), objType );
                    }
                    else if( obj.get( key, fValue ) )
                    {
                        Serializer.KeyValue( key, fValue, meta_api::json::Type::Float );
                    }
                    else if( obj.get( key, iValue ) )
                    {
                        Serializer.KeyValue( key, iValue, meta_api::json::Type::Integer );
                    }
                    else
                    {
                        Serializer.KeyValue( key, String::EMPTY_STRING, meta_api::json::Type::Undefined );
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
                dictionary&in obj,
                const string&in filename = String::EMPTY_STRING,
                const meta_api::json::parser::Indentation&in indents = meta_api::json::parser::Indentation::AllTogether,
                const meta_api::json::parser::Style&in style = meta_api::json::parser::Style::AllMan
            )
            {
                return meta_api::json::v1::Serialize(
                    obj,
                    meta_api::json::parser::Serializer(
                        1,
                        filename,
                        meta_api::json::v1::__GetDictionaryType__( obj ),
                        style,
                        indents,
                        meta_api::json::Version::V1
                    )
                );
            }

            /**
            *   @brief Deserializes str into obj,
            *   If str ends with ".json" we will open a file. No need to specify scripts/plugins/ or scripts/maps/ it will be automatically detected.
            *   If str is a file and is pointing to store/ and the file couldn't be opened it will be writed and return {}
            **/
            bool Deserialize( const string&in str, dictionary&out obj )
            {
/// Metamod handles this with the internal nlohmann/json library
#if METAMOD_PLUGIN_ASLP
                if( __METAMOD__ )
                {
                    string filename;
                    if( GetFilename( str, filename ) )
                        return aslp::json::Deserialize( filename, obj );
                    return aslp::json::Deserialize( str, obj );
                }
#endif
                meta_api::json::v1::__Deserializer__ Deserializer();

                meta_api::json::Type type = Deserializer.Initialize(str);

                switch( type )
                {
                    case meta_api::json::Type::Object:
                    case meta_api::json::Type::Array:
                    {
                        return Deserializer.Parse( obj, type );
                    }
                    case meta_api::json::Type::Undefined:
                    default:
                    {
                        return false;
                    }
                }
            }
        }
    }
}
