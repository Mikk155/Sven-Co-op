namespace meta_api
{
    namespace json
    {
#if METAMOD_PLUGIN_ASLP
        // Set to false for testing vanilla behaviour. so we don't need to restart with metamod off.
        bool __METAMOD__ = true;
#endif

        enum Version
        {
            V1 = 1,
            V2
        };

        /// Latest available version
        const Version Latest = Version::V2;

        // Console output temporal buffer
        string cout;

        // Print cout to console if "developer" is greater than zero
        void print( bool fmt, const Version &in version = Latest ) {
            g_Game.AlertMessage( at_console, "[JSON v%1] %2\n", int(version), cout );
            cout = String::EMPTY_STRING;
        }

        // Print cout to console if "developer" is greater than zero
        void print( const string &in message, const Version &in version = Latest ) {
            print( snprintf( cout, message ), version );
        }

        // Internal variable
        uint __Position__;
        // Internal variable
        uint __Size__;

        /**
        *   @brief return whatever str is a valid file name and formats the output filename
        **/
        bool GetFilename( string&in str, string&out filename )
        {
            if( str.EndsWith( ".json" ) )
            {
                bool isPlugin = ( g_Module.GetModuleName() != "MapModule" );
                string moduleFolder = ( isPlugin ? "plugins/" : "maps/" );

                if( str.StartsWith( "scripts/" ) )
                {
                    str = str.SubString(8);
                }

                if( str.StartsWith( moduleFolder ) )
                {
                    str = str.SubString( moduleFolder.Length() );
                }

                snprintf( filename, "scripts/%1%2", moduleFolder, str );

                return true;
            }

            return false;
        }
    }
}
