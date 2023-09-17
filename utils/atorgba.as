RGBA atorgba( const string m_iszFrom )
{
    array<string> m_iszSplitColors = { "", "", "", "" };

    m_iszSplitColors = m_iszFrom.Split( " " );

    array<uint8>m_uResult = { 255, 255, 255, 255 };

    if( m_iszSplitColors.length() > 0 ) m_uResult[0] = atoi(m_iszSplitColors[0]);
    if( m_iszSplitColors.length() > 1 ) m_uResult[1] = atoi(m_iszSplitColors[1]);
    if( m_iszSplitColors.length() > 2 ) m_uResult[2] = atoi(m_iszSplitColors[2]);
    if( m_iszSplitColors.length() > 3 ) m_uResult[3] = atoi(m_iszSplitColors[3]);

    if( m_uResult[0] > 255 ) m_uResult[0] = 255;
    if( m_uResult[1] > 255 ) m_uResult[1] = 255;
    if( m_uResult[2] > 255 ) m_uResult[2] = 255;
    if( m_uResult[3] > 255 ) m_uResult[3] = 255;

    return RGBA( m_uResult[0], m_uResult[1], m_uResult[2], m_uResult[3] );
}