MPattern m_Pattern;

final class MPattern
{
    int LightStyle( string m_iszPattern )
    {
        for( uint i = 0; i < List.length(); i++ )
            if( m_iszPattern.ToLowercase() == List[i][0] )
                return atoi( List[i][1] );
        return 0;
    }

    string LightStyle( int m_iszPattern )
    {
        for( uint i = 0; i < List.length(); i++ )
            if( m_iszPattern == atoi( List[i][1] ) )
                return List[i][0];
        return 'm';
    }

    string[][] List = 
    {
        { 'a', '-12' },
        { 'b', '-11' },
        { 'c', '-10' },
        { 'd', '-9' },
        { 'e', '-8' },
        { 'f', '-7' },
        { 'g', '-6' },
        { 'h', '-5' },
        { 'i', '-4' },
        { 'j', '-3' },
        { 'k', '-2' },
        { 'l', '-1' },
        { 'm', '0' },
        { 'n', '1' },
        { 'o', '2' },
        { 'p', '3' },
        { 'q', '4' },
        { 'r', '5' },
        { 's', '6' },
        { 't', '7' },
        { 'u', '8' },
        { 'v', '9' },
        { 'w', '10' },
        { 'x', '11' },
        { 'y', '12' },
        { 'z', '13' }
    };
}