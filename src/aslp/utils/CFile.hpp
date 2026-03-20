#pragma once

#include <string>
#include <filesystem>
#include <cstdio>

#include <optional>

// -TODO Use the engine's FileSystem for supporting the pavo's svencoop_event_* folders.
class CFile
{
    private:

        FILE* m_File = nullptr;

    public:

        enum class Mode
        {
            Read,
            Write,
            Append
        };

        CFile( const std::filesystem::path& relativePath, Mode mode, bool recursive = false )
        {
            std::filesystem::path fullPath;

            if( recursive )
            {
                auto FileExistsAt = [&]( const char* folder, std::filesystem::path& path ) -> bool
                {
                    std::filesystem::path myRecursivePath = std::filesystem::current_path() / folder / relativePath;

                    if( std::filesystem::exists( myRecursivePath ) )
                    {
                        path = myRecursivePath;
                        return true;
                    }
                    return false;
                };

                if(!FileExistsAt( "svencoop_addon", fullPath )
//                ||  !FileExistsAt( "svencoop_hd", fullPath )
                ||  !FileExistsAt( "svencoop", fullPath )
                ||  !FileExistsAt( "svencoop_downloads", fullPath ) )
                {
                    // Write to svencoop if can not find any other file.
                    if( mode != Mode::Read )
                    {
                        fullPath = std::filesystem::current_path() / "svencoop" / relativePath;
                    }
                    else
                    {
                        return; // Read? file does not exists!
                    }
                }
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

        ~CFile()
        {
            if( m_File )
            {
                fclose( m_File );
            }
        }

        bool IsOpen() const
        {
            return m_File != nullptr;
        }

        bool Write( const std::string& text )
        {
            if( !m_File )
            {
                return false;
            }

            fwrite( text.data(), 1, text.size(), m_File );

            return true;
        }

        bool Read( std::string& out )
        {
            if( !m_File )
            {
                return false;
            }

            fseek( m_File, 0, SEEK_END );
            long size = ftell( m_File );
            fseek( m_File, 0, SEEK_SET );

            out.resize( size );
            size_t read = fread( out.data(), 1, size, m_File );
            return ( read == static_cast<size_t>(size) );
        }
};
