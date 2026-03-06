namespace String
{
    Vector2D to_Vector( const string&in input, char delimiter = '\0' )
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
        return vec.Make2D();
    }

    string to_string( const Vector2D&in input, const char&in delimiter = ' ' )
    {
        string output; // -TODO method for digit count and wrap x, y in it
        snprintf( output, "%1%2%3", input.x, delimiter, input.y );
        return output;
    }
}
