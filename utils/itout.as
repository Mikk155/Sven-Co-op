USE_TYPE itout( const int m_iFrom, USE_TYPE &in UseTypex = USE_TOGGLE )
{
    if( m_iFrom == 0 )
    {
        return USE_OFF;
    }
    else if( m_iFrom == 1 )
    {
        return USE_ON;
    }
    else if( m_iFrom == 2 )
    {
        return USE_SET;
    }
    else if( m_iFrom == 3 )
    {
        return USE_TOGGLE;
    }
    else if( m_iFrom == 4 )
    {
        return USE_KILL;
    }
    // If UseTypex is given, return the same USE_TYPE
    else if( m_iFrom == 5 )
    {
        return UseTypex;
    }
    // If UseTypex is given and is USE_OFF / USE_ON, return the oposite USE_TYPE, else return toggle
    else if( m_iFrom == 6 )
    {
        return ( UseTypex == USE_OFF ? USE_ON : UseTypex == USE_ON ? USE_OFF : USE_TOGGLE );
    }
    return USE_TOGGLE;
}