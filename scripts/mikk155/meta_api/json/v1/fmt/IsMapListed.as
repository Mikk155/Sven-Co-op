namespace meta_api
{
    namespace json
    {
        namespace v1
        {
            namespace fmt
            {
                /**
                *   @brief Return whatever the given obj has an object at key containing the current map name in it.
                **/
                bool IsMapListed( dictionary@ obj, const string&in key = "map_blacklist" )
                {
                    dictionary map_blacklist;
                    if( obj.get( key, map_blacklist ) )
                    {
                        string mapname = string( g_Engine.mapname );

                        for( uint ui = 0; ui < map_blacklist.getSize(); ui++ )
                        {
                            if( mapname == string( map_blacklist[ ui ] ) )
                            {
                                return true;
                            }
                        }
                    }
                    return false;
                }
            } // fmt
        } // v2
    } // json
} // meta_api
