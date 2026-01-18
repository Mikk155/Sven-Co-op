#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>

#include "CFile.h"

CFile::CFile( const std::filesystem::path& relativePath, Mode mode )
{
    char gameDir[256]{};

    GET_GAME_DIR( gameDir );

    std::filesystem::path fullPath = std::filesystem::path( gameDir ) / relativePath;

    std::filesystem::create_directories( fullPath.parent_path() );

    const char* openMode = nullptr;

    switch( mode )
    {
        case Mode::Read:
            openMode = "rb";
        break;
        case Mode::Write:
            openMode = "wb";
        break;
        case Mode::Append:
            openMode = "ab";
        break;
    }

    m_File = fopen( fullPath.string().c_str(), openMode );
}

CFile::~CFile()
{
    if( m_File )
    {
        fclose( m_File );
    }
}

bool CFile::IsOpen() const
{
    return m_File != nullptr;
}

bool CFile::Write( const std::string& text )
{
    if( !m_File )
    {
        return false;
    }

    fwrite( text.data(), 1, text.size(), m_File );

    return true;
}

bool CFile::Read( std::string& out )
{
    if( !m_File )
    {
        return false;
    }

    fseek( m_File, 0, SEEK_END );
    long size = ftell( m_File );
    fseek( m_File, 0, SEEK_SET );

    out.resize( size );
    fread( out.data(), 1, size, m_File );

    return true;
}
