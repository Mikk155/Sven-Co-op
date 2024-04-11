//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

namespace JSON
{
    mixin class operators
    {
        bool isinstance( string key, string instance )
        {
            if( instance == 'float' )
            {
                return g_Utility.IsStringFloat( this[ key ] );
            }
            else if( instance == 'integer' || instance == 'int' )
            {
                return g_Utility.IsStringInt( this[ key ] );
            }
            else if( instance == 'dict' || instance == 'dictionary' || instance == 'json' )
            {
                return ( this[ key ] == 'json@' );
            }
            else if( instance == 'array' )
            {
                return false;
            }
            else if( instance == 'Vector' )
            {
                return g_Utility.IsString3DVec( key );
            }
            else if( instance == 'Vector2D' )
            {
                array<string> szSplit = key.Split( ' ' );
                return( szSplit.length() == 2 && g_Utility.IsStringFloat( szSplit[0] ) && g_Utility.IsStringFloat( szSplit[1] ) );
            }
            else if( instance == 'string' )
            {
                return
                    ( !isinstance(key,'Vector2D')
                     && !isinstance(key,'Vector')
                      && !isinstance(key,'array')
                       && !isinstance(key,'float')
                        && !isinstance(key,'json')
                         && !isinstance(key,'int')
                    );
            }
            return false;
        }

        Vector2D opIndex( string key, Vector2D value )
        {
            if( this.data.exists( key ) )
            {
                array<string> szSplit = string( data[ key ] ).Split( ' ' );

                if( szSplit.length() == 2 && g_Utility.IsStringFloat( szSplit[0] ) && g_Utility.IsStringFloat( szSplit[1] ) )
                {
                    return atov2( string( data[ key ] ) );
                }
            }
            return Vector2D( 0, 0 );
        }

        Vector opIndex( string key, Vector value )
        {
            if( this.data.exists( key ) )
            {
                if( g_Utility.IsString3DVec( string( data[ key ] ) ) )
                {
                    return atov( string( data[ key ] ) );
                }
            }
            return g_vecZero;
        }

        string opIndex( string key, string value = String::EMPTY_STRING )
        {
            if( this.data.exists( key ) )
            {
                value = string( data[ key ] );

                if( dictionary( data[ key ] ).getSize() > 0 )
                {
                    return "json@";
                }
            }
            return value;
        }

        bool atobool2( string key, bool value )
        {
            if( key == 'true' || key == 1 )
            {
                return true;
            }
            if( key == 'false' || key == 0 )
            {
                return false;
            }
            return value;
        }

        int opIndex( string key, int value )
        {
            return atoi( this[ key, string( value ) ] );
        }

        bool opIndex( string key, bool value )
        {
            return atobool2( this[ key ], value );
        }

        json opIndex( string key, dictionary value )
        {
            json pJson;
            if( this.data.exists( key ) )
            {
                pJson.data = dictionary( this.data[ key ] );
            }
            return pJson;
        }

        void opAssign( const string &in key, string value )
        {
            if( !key.IsEmpty() )
            {
                if( value.IsEmpty() )
                {
                    this.data.delete( key );
                }
                else
                {
                    this.data[ key ] = value;
                }
            }
        }

        bool opEquals( const json& pJson ) const
        {
            return ( this.json == pJson.json );
        }

        int opCmp( const json& pJson ) const
        {
            return ( this.keysize == pJson.keysize ? 0 : ( this.keysize < pJson.keysize ? -1 : 1 ) );
        }

        array<string> getKeys()
        {
            return this.data.getKeys();
        }

        // Quitar objetos del json
        json opSub( const json& pJson ) const
        {
            return pJson;
        }

        // Sumar objetos al json
        json opAdd( const json& pJson ) const
        {
            array<string> keys = pJson.data.getKeys();

            for( uint ui = 0; ui < keys.length(); ui++ )
            {
                // reemplazar?
                if( !this.data.exists( keys[ui] ) )
                {
                }
            }
            return pJson;
        }

        int get( string key, int value ){ return this[ key, value ]; }
        bool get( string key, bool value ){ return this[ key, value ]; }
        Vector get( string key, Vector value ){ return this[ key, value ]; }
        string get( string key, string value ){ return this[ key, value ]; }
        Vector2D get( string key, Vector2D value ){ return this[ key, value ]; }
        json get( string key, dictionary value ){ return this[ key, value ]; }
    }
}