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
                bool ToArray( dictionary@ obj, array<string>@&out List )
                {
                    if( obj is null )
                        return false;

                    if( List is null )
                        @List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    bool hasAny;

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        int iValue;
                        float fValue;
                        string strValue;
                        string key = string(ui);
                        if( obj.get( key, strValue ) )
                            List[ui] = strValue;
                        else if( obj.get( key, fValue ) )
                            List[ui] = string(fValue);
                        else if( obj.get( key, iValue ) )
                            List[ui] = string(iValue);
                        else
                            continue;
                        hasAny = true;
                    }

                    return hasAny;
                }

                /**
                *   @brief converts the given obj to a list of string.
                *   NOTE: Any type that is not a string will be skipped.
                **/
                bool ToArray( dictionaryValue&in obj, array<string>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }

                /**
                *   @brief converts the given obj to a list of dictionaryValue
                **/
                bool ToArray( dictionary&in obj, array<dictionaryValue>@&out List )
                {
                    if( obj is null )
                        return false;

                    if( List is null )
                        @List = {};

                    uint size = obj.getSize();

                    List.resize( size );

                    for( uint ui = 0; ui < size; ui++ )
                    {
                        dictionaryValue value;
                        if( obj.get( string( ui ), value ) )
                            List[ ui ] = value;
                    }

                    return true;
                }

                bool ToArray( dictionaryValue&in obj, array<dictionaryValue>@&out List )
                {
                    return ToArray( cast<dictionary@>( obj ), List );
                }
            } // fmt
        } // v2
    } // json
} // meta_api
