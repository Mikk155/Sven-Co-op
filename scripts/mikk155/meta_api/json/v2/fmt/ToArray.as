namespace meta_api
{
    namespace json
    {
        namespace v2
        {
            namespace fmt
            {
                /// If the json is type of Array or Object converts the values to the array type and allocate it in the json.Value set the list handle to that array and updates the type to Handle. return false otherwise
                bool ToArray( meta_api::json::v2::json@ json, array<float>@&out list, bool strict = false )
                {
                    if( json !is null )
                    {
                        switch( json.Type )
                        {
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    float fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
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
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    int fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
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
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    bool fvalue;
                                    if( value.Get( fvalue, strict ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
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
                            case meta_api::json::Type::Array:
                            case meta_api::json::Type::Object:
                            {
                                @list = {};
                                uint length = json.Length();
                                for( uint ui = 0; ui < length; ui++ ) {
                                    meta_api::json::v2::json@ value = json.opIndex(ui);
                                    string fvalue;
                                    if( value.Get( fvalue ) )
                                        list.insertLast( fvalue );
                                }
                                json.SetValue( json.Value.opAssign(@list), meta_api::json::Type::Handle );
                                return true;
                            }
                            case meta_api::json::Type::Handle:
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
