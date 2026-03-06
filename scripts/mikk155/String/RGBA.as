namespace String
{
    RGBA to_RGBA( const string&in input, char delimiter = '\0' )
    {
        if( delimiter == '\0' )
        {
            if( input.Find( "," ) != String::INVALID_INDEX )
            {
                delimiter = ',';
            }
            else
            {
                delimiter = ' ';
            }
        }
        RGBA rgba;
        g_Utility.StringToRGBA( rgba, input, delimiter );
        return rgba;
    }

    string to_string( const RGBA&in input, const char&in delimiter = ' ' )
    {
        string output;
        snprintf( output, "%1%2%3%4%5%6%7", input.r, delimiter, input.g, delimiter, input.b, delimiter, input.a );
        return output;
    }
}
