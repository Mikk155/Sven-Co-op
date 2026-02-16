#pragma once

#include <string>
#include <filesystem>
#include <cstdio>

class CFile
{

    public:

        enum class Mode
        {
            Read,
            Write,
            Append
        };

        CFile( const std::filesystem::path& relativePath, Mode mode, bool recursive = false );

        ~CFile();

        bool IsOpen() const;

        bool Write( const std::string& text );

        bool Read( std::string& out );

    private:

        FILE* m_File = nullptr;
};
