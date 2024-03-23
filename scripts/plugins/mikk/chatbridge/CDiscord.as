//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

class CDiscord
{
    private string m_szBuffer = String::EMPTY_STRING;
    float flThink = float( pJson[ 'interval angelscript to python', 20 ] );
    float flNextThink = g_Engine.time;

    void Think()
    {
        if( m_szBuffer != String::EMPTY_STRING )
        {
            pFile().Write( m_szBuffer );
            pFile().Close();
            m_szBuffer = String::EMPTY_STRING;
        }
    }

    void print( string message, dictionary CReplacement = null )
    {
        if( message.IsEmpty() or message == '' or message.Length() <= 1 )
            return;

        array<string> str = CReplacement.getKeys();
        for( uint ui = 0; ui < str.length(); ui++ )
            message.Replace( '$' + str[ui] + '$', string( CReplacement[ str[ ui ] ] ) );

        message.Replace( '@everyone', '~~everyone~~' );
        message.Replace( '@here', '~~here~~' );

        m_szBuffer += message + '\n';
    }

    File@ file;
    File@ pFile()
    {
        if( file is null || !file.IsOpen() )
        {
            @file = g_FileSystem.OpenFile( 'scripts/plugins/store/chatbridge_to_python.txt', OpenFile::APPEND );
        }

        return file;
    }
}