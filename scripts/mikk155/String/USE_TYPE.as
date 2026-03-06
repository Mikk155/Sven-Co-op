namespace String
{
    string to_string( const USE_TYPE&in input, bool real_name = false )
    {
        switch( input )
        {
            case USE_ON:
                return ( real_name ? "USE_ON" : "On" );
            case USE_SET:
                return ( real_name ? "USE_SET" : "Set" );
            case USE_TOGGLE:
                return ( real_name ? "USE_TOGGLE" : "Toggle" );
            case USE_KILL:
                return ( real_name ? "USE_KILL" : "Kill" );
            case USE_OFF:
            default:
                return ( real_name ? "USE_OFF" : "Off" );
        }
    }
}
