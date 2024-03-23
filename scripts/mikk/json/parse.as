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
    mixin class parse
    {
        void parse()
        {
            string file = this.json;
            this.data = ParseJsonFile( file );
        }

        dictionary ParseJsonFile( string f )
        {
            dictionary dict;
            string key = '';
            string value = '';
            int InBrackets = 0;
            int OutBrackets = 0;
            bool inquote = false;
            bool inscape = false;
            bool invalue = false;
            bool storekv = false;

            f = f.SubString( ( f.Find( '{', 0 ) < 2 ? f.Find( '{', 0 ) + 1 : 0 ), ( f.FindLastOf( '}', 0 ) > f.Length() - 2 ? f.FindLastOf( '}', 0 ) : f.Length() ) );

            for( string c = f[0]; f.Length() > 0; c = f[0], f = f.SubString( 1, f.Length() ) )
            {
                if( f.Length() <= 1 )
                {
                    f = String::EMPTY_STRING;
                }

                if( InBrackets > 0 )
                {
                    value += c;
                    if( c == '}' )
                    {
                        OutBrackets++;

                        if( OutBrackets == InBrackets && !key.IsEmpty() && !value.IsEmpty() )
                        {
                            dict[ key ] = ParseJsonFile( value + c );
                            value = key = String::EMPTY_STRING;
                            InBrackets = OutBrackets = 0;
                            invalue = inscape = inquote = storekv = false;
                        }
                    }
                }
                else if( value == 'true' || value == 'false' )
                {
                    storekv = true;
                }
                else if( c == ' ' && !inquote && InBrackets == 0 )
                {
                }
                else if( c == '"' && !inscape )
                {
                    inquote = !inquote;

                    if( invalue )
                    {
                        if( !inquote )
                        {
                            storekv = true;
                        }
                    }
                }
                else if( c == '\\' && !inscape )
                {
                    inscape = true;
                }
                else if( c == '{' )
                {
                    InBrackets++;
                    value += c;
                }
                else if( c == ':' && !inquote )
                {
                    invalue = true;
                }
                else if( invalue )
                {
                    if( c == ',' )
                    {
                        if( !inquote )
                        {
                            storekv = true;
                        }
                    }
                    if( c != ',' )
                    {
                        value += c;
                    }
                }
                else if( inquote && !invalue )
                {
                    key += c;
                }

                if( storekv )
                {
                    dict[ key ] = value;
                    this.keysize++;
                    value = key = String::EMPTY_STRING;
                    invalue = storekv = false;
                }
                inscape = false;
            }
            return dict;
        }
    }
}