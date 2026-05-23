namespace meta_api
{
    namespace json
    {
        namespace v1
        {
            namespace fmt
            {
                /**
                *   @brief converts the given obj to a list of string.
                *   NOTE: Any type that is not a string will be skipped.
                **/
                uint ToArray( dictionary@ obj, array<string>@&out List )
                {
                    if( List is null )
                        List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        string value;
                        if( obj.get( string( ui ), value ) )
                            List[ ui ] = value;
                    }

                    return size;
                }

                /**
                *   @brief converts the given obj to a list of string.
                *   NOTE: Any type that is not a string will be skipped.
                **/
                uint ToArray( dictionaryValue& obj, array<string>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }

                /**
                *   @brief converts the given obj to a list of dictionaryValue
                **/
                uint ToArray( dictionary@ obj, array<dictionaryValue>@&out List )
                {
                    if( List is null )
                        List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        dictionaryValue value;
                        if( obj.get( string( ui ), value ) )
                            List[ ui ] = value;
                    }

                    return size;
                }

                uint ToArray( dictionaryValue& obj, array<dictionaryValue>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }
            } // fmt
        } // v2
    } // json
} // meta_api
