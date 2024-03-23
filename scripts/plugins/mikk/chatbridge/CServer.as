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

class CServer
{
    array<string> m_szBuffer;
    float flThink = float( pJson[ 'interval angelscript read', 20 ] );
    float flNextThink = g_Engine.time;

    void Think()
    {
        if( m_szBuffer.length() < uint( pJson[ 'angelscript print messages', 2 ] ))
        {
            while( !pFile().EOFReached() )
            {
                string line;
                pFile().ReadLine( line, '\n' );

                if( line.Length() < 1 )
                    continue;

                m_szBuffer.insertLast( line );
            }
            pFile().Close();
            g_FileSystem.RemoveFile( 'scripts/plugins/store/chatbridge_to_angelscript.txt' );
        }
    }

    float flThinkWrite = float( pJson[ 'interval angelscript print', 2 ] );
    float flNextThinkWrite = g_Engine.time;

    void print()
    {
        for( int i = 0; i < pJson[ 'angelscript print messages', 2 ]; i++ )
        {
            if( m_szBuffer.length() < 1 )
                break;

            g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, m_szBuffer[0] + '\n' );

            if( JsonLog[ "print discord messages", false ] )
            {
                g_Chatbridge.Discord.print( m_szBuffer[0] );
            }

            m_szBuffer.removeAt(0);
        }
    }

    File@ file;
    File@ pFile()
    {
        if( file is null || !file.IsOpen() )
        {
            @file = g_FileSystem.OpenFile( 'scripts/plugins/store/chatbridge_to_angelscript.txt', OpenFile::READ );
        }

        return file;
    }
}