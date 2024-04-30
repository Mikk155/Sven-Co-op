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

/*
    @prefix #include fft
    @body #include "${1:../../}mikk/fft"
    @description Utilidades relacionadas conversiones
*/
namespace fft
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [fft::'+s+'] '+d+'\n' );}

    /*
        @prefix fft fft::to_string to_string RGBA
        @body fft::to_string( RGBA From, bool AddColons = false, bool AddSpace = true )
        @description Retorna una variable RGBA como string.
        @description AddColons va a añadir comas y AddSpace espacios.
    */
    string to_string( RGBA From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<int> _a_ = { From.r, From.g, From.b, From.a };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 3 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*
        @prefix fft fft::to_string to_string bool
        @body fft::to_string( bool From, bool MakeDigit = false )
        @description Retorna una variable bool como string.
        @description MakeDigit especifica como queremos obtenerla. 0/1 o false/true
    */
    string to_string( bool From, bool MakeDigit = false )
    {
        return ( !MakeDigit ? ( From ? 'true' : 'false' ) : ( From ? '1' : '0' ) );
    }

    /*
        @prefix fft fft::to_string to_string Vector
        @body fft::to_string( Vector From, bool AddColons = false, bool AddSpace = true )
        @description Retorna una variable Vector como string.
        @description AddColons va a añadir comas y AddSpace espacios.
    */
    string to_string( Vector From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y, From.z };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 2 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*
        @prefix fft fft::to_string to_string Vector2D
        @body fft::to_string( Vector2D From, bool AddColons = false, bool AddSpace = true )
        @description Retorna una variable Vector2D como string.
        @description AddColons va a añadir comas y AddSpace espacios.
    */
    string to_string( Vector2D From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 1 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*
        @prefix fft fft::HueToRGBA HueToRGBA Hue RGBA
        @body fft::HueToRGBA( float H )
        @description Retorna el color Hue a RGBA.
    */
    RGBA HueToRGBA( float H )
    {
        float R, G, B;
        float S = 1.0f;
        float V = 1.0f;

        int H_i = int(H * 6.0f);
        float f = H * 6.0f - H_i;
        float p = V * (1.0f - S);
        float q = V * (1.0f - f * S);
        float t = V * (1.0f - (1.0f - f) * S);

        switch(H_i % 6)
        {
            case 0: R = V; G = t; B = p; break;
            case 1: R = q; G = V; B = p; break;
            case 2: R = p; G = V; B = t; break;
            case 3: R = p; G = q; B = V; break;
            case 4: R = t; G = p; B = V; break;
            case 5: R = V; G = p; B = q; break;
        }

        return RGBA( Math.clamp( 0, 255, int( R * 255.f ) ), Math.clamp( 0, 255.0f, int( G * 255.0f ) ), Math.clamp( 0, 255, int( B * 255.0f ) ), 255 );
    }

    /*
        @prefix fft fft::RGBAToHue RGBAToHue Hue RGBA
        @body fft::RGBAToHue( RGBA rgb )
        @description Retorna el color RGBA a Hue.
    */
    float RGBAToHue( RGBA rgb ){ return ToHue( Vector( rgb.r, rgb.g, rgb.b ) ); }

    /*
        @prefix fft fft::RGBAToHue RGBAToHue Hue RGBA ToHue fft::ToHue
        @body fft::ToHue( Vector rgb )
        @description Retorna el color RGBA a Hue.
    */
    float ToHue( Vector rgb )
    {
        float R = rgb.x;
        float G = rgb.y;
        float B = rgb.z;

        float maxColor = Math.max( Math.max( R, G ), B );
        float minColor = Math.min( Math.min( R, G ), B );

        float H;

        if( maxColor == minColor )
        {
            H = 0.0f;
        }
        else if (maxColor == R)
        {
            H = ( G - B ) / (maxColor - minColor);

            if( G < B )
            {
                H += 6.0f;
            }
        }
        else if (maxColor == G)
        {
            H = 2.0f + ( B - R ) / ( maxColor - minColor );
        }
        else
        {
            H = 4.0f + ( R - G ) / ( maxColor - minColor );
        }

        H /= 6.0f;

        if( H < 0.0f )
            H += 1.0f;

        return H;
    }
}

/*
    @prefix fft fft::atorgba atorgba
    @body atorgba( const string From )
    @description Retorna el string a RGBA
*/
RGBA atorgba( const string From )
{
    array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

/*
    @prefix fft fft::atov atov
    @body atov( const string From )
    @description Retorna el string a Vector
*/
Vector atov( const string From )
{
    array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

    while( aSplit.length() < 3 )
        aSplit.insertLast( '0' );

    return Vector( atof( aSplit[0] ), atof( aSplit[1] ), atof( aSplit[2] ) );
}

/*
    @prefix fft fft::atob atob
    @body atob( const string From )
    @description Retorna el string a bool, 0/1 o tambien false/true
*/
bool atob( const string From )
{
    return ( tolower( From ) == 'true' || atoi( From ) == 1 );
}
