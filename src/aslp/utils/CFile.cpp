#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>

#include "CFile.h"

#include <optional>

CFile::CFile( const std::filesystem::path& relativePath, Mode mode, bool recursive )
{
    std::filesystem::path fullPath;

    if( recursive )
    {
	    auto FileExistsAt = [&]( const char* folder ) -> std::optional<std::filesystem::path>
        {
            std::filesystem::path myRecursivePath = std::filesystem::current_path() / folder / relativePath;
            if( std::filesystem::exists( myRecursivePath ) )
                return myRecursivePath;
            return std::nullopt;
        };

        if( auto folder = FileExistsAt( "svencoop_addon" ); folder.has_value() ) { fullPath = folder.value(); } else
        if( auto folder = FileExistsAt( "svencoop_hd" ); folder.has_value() ) { fullPath = folder.value(); } else
        if( auto folder = FileExistsAt( "svencoop" ); folder.has_value() ) { fullPath = folder.value(); } else
        if( auto folder = FileExistsAt( "svencoop_downloads" ); folder.has_value() ) { fullPath = folder.value(); } else
        if( mode == Mode::Write ) { fullPath = std::filesystem::current_path() / "svencoop" / relativePath; }
    }
    else
    {
        fullPath = std::filesystem::current_path() / "svencoop" / relativePath;
    }

    const char* openMode = nullptr;

    switch( mode )
    {
        case Mode::Write:
            openMode = "wb";
        break;
        case Mode::Append:
            openMode = "ab";
        break;
        case Mode::Read:
        default:
            openMode = "rb";
        break;
    }

    std::filesystem::create_directories( fullPath.parent_path() );

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
