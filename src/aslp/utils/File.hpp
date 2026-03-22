#pragma once

#include <string>
#include <string_view>
#include <filesystem>
#include <cstdio>

#include <extdll.h>
#include <meta_api.h>

using namespace std::literals::string_view_literals;

class File
{
public:
    enum class Mode
    {
        Read = 0,
        Write,
        Append
    };

private:
    std::string m_Path;
    FILE* m_File = nullptr;

public:
    Mode m_Mode;

    File( std::string_view path ) : m_Path( std::string( path ) ) {}
    File( const char* path ) : m_Path( std::string( path ) ) {}
    File( const std::string& path ) : m_Path( path ) {}

    void Close()
    {
        if( m_File )
        {
            fclose( m_File );
            m_File = nullptr;
        }
    }

    ~File()
    {
        Close();
    }

public:

    /**
     * @brief Get the Full Path to the file if exists in one of; svencoop_addon, svencoop or svencoop_downloads in that ordering. if the file doesn't exists it will be at "svencoop"
     */
    std::string GetFullPath()
    {
        auto currentPath = std::filesystem::current_path();
        std::filesystem::path fullPath;

        fullPath = currentPath / "svencoop_addon"sv / m_Path;
        if( std::filesystem::exists( fullPath ) )
            return fullPath.string();

        std::filesystem::path svenMainPath = currentPath / "svencoop"sv / m_Path;
        if( std::filesystem::exists( svenMainPath ) )
            return svenMainPath.string();

        fullPath = currentPath / "svencoop_downloads"sv / m_Path;
        if( std::filesystem::exists( fullPath ) )
            return fullPath.string();

        return svenMainPath.string();
    }

    /**
     * @brief Open the file.
     * 
     * @param mode mode, if the file doesn't exists and the mode is either write or append, a file will be generated in svencoop/path
     * @return true file exists
     * @return false file doesn't exists
     */
    bool Open( Mode mode )
    {
        if( m_File )
        {
            if( m_Mode == mode )
                return true;
            Close();
        }

        m_Mode = mode;

        const char* openMode = nullptr;

        switch( m_Mode )
        {
            case Mode::Read:
                openMode = "r";
            break;
            case Mode::Write:
                openMode = "w";
            break;
            case Mode::Append:
                openMode = "a";
            break;
        }

        std::string path = GetFullPath();
        m_File = fopen( path.c_str(), openMode );

        return m_File != nullptr;
    }

    bool Write( const std::string& text )
    {
        if( !Open( Mode::Write ) )
            return false;

        return ( fwrite( text.data(), 1, text.size(), m_File ) == text.size() );
    }

    bool Append( const std::string& text )
    {
        if( !Open( Mode::Append ) )
            return false;

        return ( fwrite( text.data(), 1, text.size(), m_File ) == text.size() );
    }

    /**
     * @brief Return whatever the file exists in the given asset folder
     */
    bool ExistsAt( std::string_view folder )
    {
        return ( std::filesystem::exists( std::filesystem::current_path() / folder / m_Path ) );
    }

    /**
     * @brief Return whatever the file exists in one of; svencoop_addon, svencoop or svencoop_downloads in that ordering.
     */
    bool Exists()
    {
        return ( ExistsAt( "svencoop_addon"sv ) || ExistsAt( "svencoop"sv ) || ExistsAt( "svencoop_downloads"sv ) );
    }

    /**
     * @brief Read the file content using the engine's FileSystem
     * 
     * @param out file content
     * @return Whatever the file was opened and readed
     */
    bool Read( std::string& out )
    {
        m_Mode = Mode::Read;

        int len = 0;
        byte* data = g_engfuncs.pfnLoadFileForMe( const_cast<char*>( m_Path.c_str() ), &len );

        if( !data )
            return false;

        out.assign( reinterpret_cast<char*>( data ), len );

        g_engfuncs.pfnFreeFile( data );

        return true;
    }
};
