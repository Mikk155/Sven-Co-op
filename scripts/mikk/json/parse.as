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
            bool inarray = false;
            array<string> strArray;

            while( f[0] == ' ' )
                f = f.SubString( 1, f.Length() );

            f = f.SubString( f.Find( '{', 0 ) + 1, f.FindLastOf( '}', 0 ) - 1 );

            for( string c = f[0]; f.Length() > 0; c = f[0], f = f.SubString( 1, f.Length() ) )
            {
                if( f.Length() <= 1 )
                {
                    f = String::EMPTY_STRING;
                }

                if( inarray )
                {
                    if( c == '"' && !inscape )
                    {
                        inquote = !inquote;
                    }
                    else if( c == '\\' && !inscape )
                    {
                        inscape = true;
                    }
                    else if( !inquote && ( c == ' ' || c == ',' || c == ']' ) )
                    {
                    }
                    else
                    {
                        value += c;
                    }

                    if( !inquote && ( c == ',' || c == ']' ) )
                    {
                        while( value[0] == ' ' )
                            value = value.SubString( 1, value.Length() );
                        while( value[ value.Length() ] == ' ' )
                            value = value.SubString( 0, value.Length() - 1 );

                        strArray.insertLast( value );
                        value = String::EMPTY_STRING;
                    }

                    if( !inquote && c == ']' )
                    {
                        this.keysize++;
                        dict[ key ] = strArray;
                        strArray.resize(0);
                        OpIndex.insertLast( key );
                        key = String::EMPTY_STRING;
                        inarray = invalue = inscape = inquote = storekv = false;
                    }
                    continue;
                }
                else if( InBrackets > 0 )
                {
                    value += c;
                    if( c == '}' )
                    {
                        OutBrackets++;

                        if( OutBrackets == InBrackets && !key.IsEmpty() && !value.IsEmpty() )
                        {
                            this.keysize++;
                            dict[ key ] = ParseJsonFile( value );
                            OpIndex.insertLast( key );
                            value = key = String::EMPTY_STRING;
                            InBrackets = OutBrackets = 0;
                            invalue = inscape = inquote = storekv = false;
                        }
                    }
                    else if( c == '{' )
                    {
                        InBrackets++;
                    }
                }
                else if( value == 'true' || value == 'false' )
                {
                    storekv = true;
                }
                else if( c == ' ' && !inquote && InBrackets == 0 )
                {
                }
                else if( invalue && !inquote && c == '[' )
                {
                    inarray = true;
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
                else if( c == '{' && !inquote )
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
                    OpIndex.insertLast( key );
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