namespace String
{
    bool to_bool( const string&in input )
    {
        return ( atoi( input ) != 0 || input.ToLowercase() == "true" );
    }

    string to_string( bool input, bool make_digit = false )
    {
        if( make_digit )
        {
            return ( input ? "1" : "0" );
        }
        return ( input ? "True" : "False" );
    }
}
