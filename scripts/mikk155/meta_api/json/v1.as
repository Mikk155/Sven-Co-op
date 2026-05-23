#include "../json"

namespace meta_api
{
    namespace json
    {
        /// Version 1 of Json. conversion to/from dictionary.
        /// Array items are converted into a dictionary object where the key names are the item indexing.
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
                                return true;
                            }
                            case meta_api::json::Type::String:
                            {
                                obj.set( key, value );
                                return true;
                            }
                            case meta_api::json::Type::Float:
                            {
                                obj.set( key, atof( value ) );
                                return true;
                            }
                            case meta_api::json::Type::Integer:
                            {
                                obj.set( key, atoi( value ) );
                                return true;
                            }
                            case meta_api::json::Type::Boolean:
                            {
                                obj.set( key, ( value == "true" ? true : false ) );;
                                return true;
                            }
                            case meta_api::json::Type::Null:
                            {
                                obj.set( key, meta_api::json::Null::Null );
                                return true;
                            }
                            default:
                            {
                                return false;
                            }
                        }
                    }
                    return false;
                }
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
