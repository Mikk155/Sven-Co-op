namespace String
{
    Vector to_Vector( const string&in input, char delimiter = '\0' )
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
        Vector vec;
        g_Utility.StringToVector( vec, input, delimiter );
        return vec;
    }

    string to_string( const Vector&in input, const char&in delimiter = ' ' )
    {
        string output; // -TODO method for digit count and wrap x, y, z in it
        snprintf( output, "%1%2%3%4%5", input.x, delimiter, input.y, delimiter, input.z );
        return output;
    }
}
