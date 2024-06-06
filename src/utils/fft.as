namespace fft
{
    void print(string s,string d){g_Game.AlertMessage( at_console, g_Module.GetModuleName() + ' [fft::'+s+'] '+d+'\n' );}

    string to_string( RGBA From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<int> _a_ = { From.r, From.g, From.b, From.a };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 3 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    enum TimeStamp
    {
        ALL = -1,
        SECONDS = 0,
        MINUTES = 1,
        HOURS = 2,
        DAYS = 3
    }

    string to_string( int From, TimeStamp digits = ALL )
    {
        string _t_;
        int h = From / 3600, m = ( From % 3600 ) / 60, s = From % 60;
        if( digits >= TimeStamp::HOURS || (digits==ALL && h>0)){ _t_+=string(h<=9?'0'+h:h)+':';}
        if( digits >= TimeStamp::MINUTES || (digits==ALL && m>0)){ _t_+=string(m<=9?'0'+m:m)+':';}
        if( digits >= TimeStamp::SECONDS || (digits==ALL && s>0)){ _t_+=string(s<=9?'0'+s:s)+':';}
        if( _t_.EndsWith( ':' )){ _t_ = _t_.SubString( 0, _t_.Length() - 1 );}
        return _t_;
    }

    string to_string( bool From, bool MakeDigit = false )
    {
        return ( !MakeDigit ? ( From ? 'true' : 'false' ) : ( From ? '1' : '0' ) );
    }

    string to_string( Vector From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y, From.z };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 2 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

    string to_string( Vector2D From, bool AddColons = false, bool AddSpace = true )
    {
        string _s_;
        array<float> _a_ = { From.x, From.y };
        for( uint u = 0; u < _a_.length(); u++ )
            _s_ += string( _a_[u] ) + ( AddColons && u < 1 ? ',' : '' ) + ( AddSpace ? ' ' : '' );
        return _s_;
    }

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

    float RGBAToHue( RGBA rgb ){ return ToHue( Vector( rgb.r, rgb.g, rgb.b ) ); }

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

RGBA atorgba( const string From )
{
    array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

class CSplitter
{
    string s1, s2, s3, s4;

    CSplitter( string From )
    {
        array<string> aSplit = From.Split( ( From.Find( ',', 0 ) != String::INVALID_INDEX ? ',' : ' ' ) );

        while( aSplit.length() < 4 )
            aSplit.insertLast( '0' );

        s1 = aSplit[0];
        s2 = aSplit[1];
        s3 = aSplit[2];
        s4 = aSplit[3];
    }

}

Vector atov( const string From )
{
    CSplitter@ gpS = CSplitter( From );
    return Vector( atof(gpS.s1), atof(gpS.s2), atof(gpS.s3) );
}

bool atob( string From )
{
    return ( From.ToLowercase() == 'true' || atoi( From ) == 1 );
}
