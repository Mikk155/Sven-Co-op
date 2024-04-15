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

enum JsonValueType
{
    STRING = 0,
    BOOL = 1,
    BOOLEAN = 1,
    INT = 2,
    INTEGER = 2,
    FLOAT = 3,
    DICTIONARY = 4,
    DICT = 4,
    JSON = 4,
    ARRAY = 5,
    VECTOR = 6,
    VECTOR2D = 7,
    RGBA = 8
}

class JsonValue
{
    int instance;
    int index;
    string key;
    string value;
    array<string> arrayvalue;
    dictionary dictionaryvalue;

    string Instance( bool ToString ) const
    {
        if( ToString )
        {
            switch( instance )
            {
                case JsonValueType :: INT      : return 'int';
                case JsonValueType :: RGBA     : return 'RGBA';
                case JsonValueType :: BOOL     : return 'bool';
                case JsonValueType :: JSON     : return 'json';
                case JsonValueType :: ARRAY    : return 'array';
                case JsonValueType :: FLOAT    : return 'float';
                case JsonValueType :: VECTOR   : return 'Vector';
                case JsonValueType :: STRING   : return 'string';
                case JsonValueType :: VECTOR2D : return 'Vector2D';
            }
        }
        return string( instance );
    }

    /*
        @prefix JsonValue opIndex
        Return the given value on the array of this json if any, else returns empty string
    */
    string opIndex( uint index )
    {
        if( index < arrayvalue.length() )
        {
            return arrayvalue[ index ];
        }
        return String::EMPTY_STRING;
    }

    string_t opConv() const { return string_t(value); }
    string opConv() const { return value; }
    uint opConv() const { return atoui(value); }
    int opConv() const { return atoi(value); }
    float opConv() const { return atof(value); }
    bool opConv() const { return atob(value); }
    RGBA opConv() const{ return ( arrayvalue.length() == 4 ? RGBA( atoi(arrayvalue[0]), atoi(arrayvalue[1]), atoi(arrayvalue[2]), atoi(arrayvalue[3]) ) : RGBA_WHITE ); }
    Vector opConv() const{ return ( arrayvalue.length() == 3 ? Vector( atof(arrayvalue[0]), atof(arrayvalue[1]), atof(arrayvalue[2]) ) : g_vecZero ); }
    Vector2D opConv() const{ return ( arrayvalue.length() == 2 ? Vector2D( atof(arrayvalue[0]), atof(arrayvalue[1]) ) : g_vecZero.Make2D() ); }
    array<string> opConv() const { return arrayvalue; }
    json opConv() const { json pJson; pJson.data = dictionaryvalue; return pJson; }
}

class json
{
    protected array<string> OpIndex;
    protected int keysize = 0;
    protected string json = String::EMPTY_STRING;
    dictionary data;

    json()
    {
    }

    string opIndex( uint index )
    {
        if( index < this.OpIndex.length() )
        {
            return this.OpIndex[ index ];
        }
        return String::EMPTY_STRING;
    }

    /*
        @prefix json exists
        Return whatever the given key exists, if vlvalue is true it will check for both to exist
    */
    bool exists( string &in key, bool CheckValue = false )
    {
        if( CheckValue && this.data.exists( key ) )
        {
            JsonValue@ pValue = this[ key ];

            if( this.Instance( key ) == JsonValueType::ARRAY || this.Instance( key ) == JsonValueType::JSON )
            {
                return ( array<string>( this[ key ] ).length() > 0 || this[ key ].dictionaryvalue.getKeys().length() > 0 );
            }
            return ( this[ key, '' ] != String::EMPTY_STRING );
        }
        return this.data.exists( key );
    }

    /*
        @prefix json size
        Return the whole size of this json data
    */
    uint size()
    {
        return this.keysize;
    }

    /*
        @prefix json length
        Return the length of this json data
    */
    uint length()
    {
        return this.data.getKeys().length();
    }

    JsonValue get( string key )
    {
        return JsonValue( this.data[ key ] );
    }

    /*
        @prefix json opIndex
        Return the JsonValue of the given key
    */
    JsonValue opIndex( string key )
    {
        return get( key );
    }

    /*
        @prefix json Instance
        Return the instance name on enum JsonValueType, if ToString is true return as a string
    */
    string Instance( string key, bool ToString = false ){ return get( key ).Instance( ToString ); }

    string get( string key, string value ){ return this[ key, value ]; }
    string opIndex( string key, string value )
    {
        if( this.data.exists( key ) )
        {
            value = string( get( key ).value );
        }
        return ( value.IsEmpty() ? String::EMPTY_STRING : value );
    }

    int get( string key, int value ){ return this[ key, value ]; }
    int opIndex( string key, int value )
    {
        return ( this[ key, '' ].IsEmpty() ? value : atoi( this[ key, string( value ) ] ) );
    }

    bool get( string key, bool value ){ return this[ key, value ]; }
    bool opIndex( string key, bool value )
    {
        return ( this[ key, '' ].IsEmpty() ? value : atob( this[ key, '' ] ) );
    }
/*
    Vector get( string key, Vector value ){ return this[ key, value ]; }
    Vector opIndex( string key, Vector value )
    {
        return ( this[ key, '' ].IsEmpty() &&  && g_Utility.IsString3DVec( this[ key, '' ]) ? value : atov( this[ key, '' ] ) );
    }

    Vector2D get( string key, Vector2D value ){ return this[ key, value ]; }
    Vector2D opIndex( string key, Vector2D value )
    {
        if( this.exists( key, true ) )
        {
            array<string> szSplit = string( data[ key ] ).Split( ' ' );

            if( szSplit.length() == 2 && g_Utility.IsStringFloat( szSplit[0] ) && g_Utility.IsStringFloat( szSplit[1] ) )
            {
                return atov( string( data[ key ] ) ).Make2D();
            }
        }
        return value;
    }

        RGBA get( string key, RGBA value ){ return this[ key, value ]; }
        RGBA opIndex( string key, RGBA value )
        {
            if( this.exists( key, true ) )
            {
                array<string> szSplit = this[ key ].Split( ' ' );

                for( uint ui = 0; ui < szSplit.length() && g_Utility.IsStringInt( szSplit[ui] ); ui++ )
                {
                    if( ui == 3 )
                    {
                        return atorgba( string( data[ key ] ) );
                    }
                }
            }
            return value;
        }*/
    json get( string key, json value ){ return this[ key, value ]; }
    json opIndex( string key, json value ){ return this[ key, value.data ]; }
    json get( string key, dictionary value ){ return this[ key, value ]; }
    json opIndex( string key, dictionary value )
    {
        json pJson;

        if( this.data.exists( key ) )
        {
            if( this.Instance( key ) == JsonValueType::ARRAY )
            {
                array<string> str = this[ key ].arrayvalue;

                for( uint ui = 0; ui < str.length(); ui++ )
                {
                    pJson.data[ string(ui) ] = str[ui];
                }
            }
            else
            {
                pJson.data = this[ key ].dictionaryvalue;
            }
        }
        return pJson;
    }

    array<string> getKeys()
    {
        return this.data.getKeys();
    }

    /*
    json opAssign( dictionary pkvd )
    {
        array<string> str = pkvd.getKeys();

        for( uint ui = 0; ui < str.length(); ui++ )
        {
            if( string( pkvd[ str[ui] ] ).IsEmpty() )
            {
                this.data.delete( str[ui] );
            }
            else
            {
                this.data[ str[ui] ] = string( pkvd[ str[ui] ] );
            }
        }
        return this;
    }
    */

    private void parse()
    {
        string file = this.json;
        this.data = ParseJsonFile( file );
    }

    private dictionary ParseJsonFile( string f )
    {
        dictionary dict;
        string key = '';
        string value = '';
        string brutevalue = '';
        int InBrackets = 0;
        int OutBrackets = 0;
        bool inquote = false;
        bool inscape = false;
        bool invalue = false;
        bool storekv = false;
        bool inarray = false;
        array<string> strArray;
        JsonValue pValue;

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
                    brutevalue += value;

                    if( c == ',' )
                    {
                        brutevalue += ',';
                    }

                    value = String::EMPTY_STRING;
                }

                if( !inquote && c == ']' )
                {
//                    dict[ key ] = strArray;
                    pValue.value = brutevalue + ']';
                    pValue.instance = GetValueType( pValue.value );
                    pValue.index = this.keysize++;
                    pValue.key = key;
                    pValue.arrayvalue = strArray;
                    OpIndex.insertLast( key );
                    dict[ key ] = pValue;

                    strArray.resize(0);
                    OpIndex.insertLast( key );
                    key = value = brutevalue = String::EMPTY_STRING;
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
                        pValue.index = this.keysize++;
                        pValue.key = key;
                        pValue.value = '{}';
                        pValue.instance = GetValueType( pValue.value );
                        pValue.dictionaryvalue = ParseJsonFile( value );;
                        OpIndex.insertLast( key );
//                        dict[ key ] = ParseJsonFile( value );
                        dict[ key ] = pValue;
                        value = key = brutevalue = String::EMPTY_STRING;
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
                brutevalue = '[';
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
                pValue.instance = GetValueType( value );
                pValue.index = this.keysize++;
                pValue.key = key;
                pValue.value = value;
                OpIndex.insertLast( key );
                dict[ key ] = pValue;
                value = brutevalue = key = String::EMPTY_STRING;
                invalue = storekv = false;
            }
            inscape = false;
        }
        return dict;
    }

    protected int GetValueType( string value )
    {
        if( value == 'true' || value == 'false' )
        {
            return JsonValueType::BOOLEAN;
        }

        if( g_Utility.IsStringInt( value ) )
        {
            return JsonValueType::INTEGER;
        }

        if( g_Utility.IsStringFloat( value ) )
        {
            return JsonValueType::FLOAT;
        }

        if( value.StartsWith( '[' ) && value.EndsWith( ']' ) )
        {
            array<string> str = value.SubString( 1, value.Length() - 2 ).Split( ',' );

            for( uint ui = 0; ui < str.length() && ( g_Utility.IsStringInt( str[ui] ) || g_Utility.IsStringFloat( str[ui] ) ); ui++ )
            {
                if( ui == str.length() - 1 )
                {
                    if( ui == 1 )
                    {
                        return JsonValueType::VECTOR2D;
                    }
                    else if( ui == 2 )
                    {
                        return JsonValueType::VECTOR;
                    }
                    else if( ui == 3 )
                    {
                        return JsonValueType::RGBA;
                    }
                }
            }
            return JsonValueType::ARRAY;
        }

        if( value.StartsWith( '{' ) && value.EndsWith( '}' ) )
        {
            return JsonValueType::JSON;
        }
        return JsonValueType::STRING;
    }

    /*
        @prefix load json parse
        Loads a json file within a json class. if no format '.json' is provided it asumes you sent a string with json format
        if include is true the json is not cleared and new data will be written above,
        When specifying format, folder maps/plugins is necesary to include in the path.
        Return codes:
        0 = everything fine
        1 = empty string sent
        2 = file not found
    */
    uint load( string m_szLoad, bool include = false )
    {
        if( m_szLoad.IsEmpty() )
            return 1;

        if( !include )
        {
            this.keysize = 0;
            this.data.deleteAll();
            this.OpIndex.resize(0);
            this.json = String::EMPTY_STRING;
        }
        else
        {
            this.json += ',';
        }

        if( m_szLoad.EndsWith( '.json' ) )
        {
            File@ pFile = g_FileSystem.OpenFile( ( m_szLoad.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szLoad, OpenFile::READ );

            if( pFile is null || !pFile.IsOpen() )
                return 2;

            while( !pFile.EOFReached() )
            {
                string line;

                pFile.ReadLine( line );

                if( line.Length() > 0 )
                {
                    while( line.StartsWith( '  ' ) )
                        line = line.SubString( 1, line.Length() );

                    if( line.StartsWith( '//' ) )
                        continue;

                    this.json += line;
                }
            }
            pFile.Close();
        }
        else
        {
            this.json += m_szLoad;
        }                           // HACK HACK, until i find out what happens in there
        this.json += this.json.SubString( 0, json.FindLastOf( '}', 0 ) - 1 ) + ',}';
        this.parse();
        return 0;
    }
}