namespace meta_api
{
    namespace json
    {
        /**
        *   @brief Deserializes str into obj
        **/
        bool Deserialize( const string&in str, dictionary&out obj )
        {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return g_EngineFuncs.JsonDeserialize( str, obj );
#endif
            // -TODO manual string parsing
            return false;
        }

#if FALSE
        /**
        *   @brief Serializes a obj into str with the given indents
        **/
        bool Serialize( dictionary@ obj, string&out str, int indents = -1 )
        {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return g_EngineFuncs.JsonSerialize( obj, str, indents );
#endif
            // -TODO manual dictionary parsing
            return false;
        }
#endif
    }
}
