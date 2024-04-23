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

namespace fileload
{
    string m_szWholeFile;

    void ThinkForFileLoad()
    {
        File@ pFile = g_FileSystem.OpenFile( 'scripts/plugins/store/DiscordBridge.txt', OpenFile::READ );

        if( pFile !is null && pFile.IsOpen() )
        {
            while( !pFile.EOFReached() )
            {
                string line;
                pFile.ReadLine( line );

                if( line.Length() < 1 )
                    continue;

                if( line.StartsWith( TO_SERVER ) )
                {
                    m_szBuffer.insertLast( line.SubString( 1, line.Length() ) );
                }
                else if( line.StartsWith( TO_COMMAND ) )
                {
                    m_szCommandBuffer.insertLast( line.SubString( 1, line.Length() ) );
                }
                else if( line.StartsWith( TO_STATUS ) )
                {
                }
                else
                {
                    m_szWholeFile += line +'\n';
                }
            }
            pFile.Close();
        }

        File@ pWrite = g_FileSystem.OpenFile( 'scripts/plugins/store/DiscordBridge.txt', OpenFile::WRITE );

        if( pWrite !is null && pWrite.IsOpen() )
        {
            pWrite.Write( m_szWholeFile + '\n' );
            pWrite.Close();
        }
        m_szWholeFile = String::EMPTY_STRING;
    }

    void PluginInit()
    {
        g_FileSystem.RemoveFile( 'scripts/plugins/store/DiscordBridge.txt' );
    }

    void ToDiscord( string szMessage, bool isstatus )
    {
        m_szWholeFile += ( isstatus ? TO_STATUS : TO_DISCORD ) + szMessage + '\n';
    }
}
