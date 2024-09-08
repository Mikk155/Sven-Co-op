RGBA atorgba( const string m_iszFrom )
{
    array<string> aSplit = m_iszFrom.Split( " " );

    while( aSplit.length() < 4 )
        aSplit.insertLast( '0' );

    return RGBA( atoui( aSplit[0] ), atoui( aSplit[1] ), atoui( aSplit[2] ), atoui( aSplit[3] ) );
}

Vector atov( const string m_iszFrom )
{
    Vector m_vTo;
    g_Utility.StringToVector( m_vTo, m_iszFrom );
    return m_vTo;
}

int uttoi( USE_TYPE m_UseType )
{
    return int( m_UseType );
}

USE_TYPE itout( const int m_iFrom, USE_TYPE &in UseTypex = USE_TOGGLE )
{
    switch( m_iFrom )
    {
        case 0: return USE_OFF;
        case 1: return USE_ON;
        case 2: return USE_SET;
        case 3: return USE_TOGGLE;
        case 4: return USE_KILL;
        case 5: return UseTypex;
    }
    return ( UseTypex == USE_OFF ? USE_ON : UseTypex == USE_ON ? USE_OFF : USE_TOGGLE );
}