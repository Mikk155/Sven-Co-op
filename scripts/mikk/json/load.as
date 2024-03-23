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

namespace JSON
{
    mixin class load
    {
        void load( string m_szLoad, bool include = true )
        {
            if( !m_szLoad.IsEmpty() )
            {
                if( m_szLoad.Find( '/', 0 ) >= 0 )
                {
                    if( !include )
                    {
                        this.json = String::EMPTY_STRING;
                    }

                    File@ pFile = g_FileSystem.OpenFile(
                        ( m_szLoad.StartsWith( 'scripts/' ) ? '' : 'scripts/' ) + m_szLoad +
                        ( m_szLoad.EndsWith( '.json' ) ? '' : '.json' ), OpenFile::READ
                    );

                    if( pFile !is null && pFile.IsOpen() )
                    {
                        while( !pFile.EOFReached() )
                        {
                            string line;

                            pFile.ReadLine( line );

                            if( line.Length() > 0 )
                            {
                                this.json += line;
                            }
                        }
                        pFile.Close();
                    }
                }
                else
                {
                    if( !include )
                    {
                        this.json = m_szLoad;
                    }
                    else
                    {
                        this.json += m_szLoad;
                    }
                }
                this.parse();
            }
        }
    }
}