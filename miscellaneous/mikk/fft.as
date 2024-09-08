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

namespace fft
{
    /*@
        @prefix fft::to_string to_string RGBA format
        @body fft::
        Format the given RGBA to string.
        If AddColons is true add colons.
        If AddSpace is false then do not add white spaces.
    */
    string to_string( RGBA From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<int> _a_ = { From.r, From.g, From.b, From.a };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 3 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*@
        @prefix fft::to_string to_string bool format
        @body fft::
        Format the given bool to string, if MakeDigit is true then false = 0, true = 1
    */
    string to_string( bool From, bool MakeDigit = false )
    {
        return ( !MakeDigit ? ( From ? 'true' : 'false' ) : ( From ? '1' : '0' ) );
    }

    /*@
        @prefix fft::to_string to_string Vector format
        @body fft::
        Format the given Vector to string.
        If AddColons is true add colons.
        If AddSpace is false then do not add white spaces.
    */
    string to_string( Vector From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y, From.z };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 2 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*@
        @prefix fft::to_string to_string Vector2D format
        @body fft::
        Format the given Vector2D to string.
        If AddColons is true add colons.
        If AddSpace is false then do not add white spaces.
    */
    string to_string( Vector2D From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 1 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    /*@
        @prefix fft::HueToRGBA fft::Hue fft::RGBA Hue format
        @body fft::
        Format the given hue float value to RGBA (.a will most likely be empty)
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

    /*@
        @prefix fft::ToHue fft::Hue fft::RGBAToHue RGBAToHue Hue format
        @body fft::
        Format the given RGBA to hue value in a float form
    */
    float RGBAToHue( RGBA rgb ){ return ToHue( Vector( rgb.r, rgb.g, rgb.b ) ); }
    /*@
        @prefix fft::ToHue fft::Hue Hue format
        @body fft::
        Format the given Vector to hue value in a float form
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

/*@
    @prefix atorgba
    Return the given string as a 4D RGBA
*/
RGBA atorgba( const string From )
{
    array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

/*@
    @prefix atov StringToVector
    Return the given string as a 3D Vector
*/
Vector atov( const string From )
{
    array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

    while( aSplit.length() < 3 )
        aSplit.insertLast( '0' );

    return Vector( atof( aSplit[0] ), atof( aSplit[1] ), atof( aSplit[2] ) );
}

/*@
    @prefix atobool stringtobool
    Return the given string as a boolean, 0/1 or false/true
*/
bool atob( const string From )
{
    return ( From == 'true' || atoi( From ) == 1 );
}
