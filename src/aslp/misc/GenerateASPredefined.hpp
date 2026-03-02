// Remove dis shit later since VSC bitches about it. -TODO
#define AS_GENERATE_DOCUMENTATION 1

// Special thanks to AnggaraNothing for https://github.com/anggaranothing/sc-py-asdocs-vscode
#if AS_GENERATE_DOCUMENTATION
#include <string>
#include <string_view>
#include <cstdio>
#include <filesystem>
#include <ctime>
#include <chrono>

#include <fmt/core.h>

#pragma once

// Google AI Slop for now.
#include <windows.h>
// Convert from a specific source encoding (e.g., system's active code page CP_ACP) to UTF-8
std::string& convertToUtf8(std::string& sourceStr) {
    // 1. Convert source encoding (e.g., CP_ACP) to UTF-16 (std::wstring)
    int sizeNeededForWstr = MultiByteToWideChar(CP_ACP, 0, sourceStr.c_str(), -1, nullptr, 0);
    std::wstring wstr(sizeNeededForWstr, 0);
    MultiByteToWideChar(CP_ACP, 0, sourceStr.c_str(), -1, &wstr[0], sizeNeededForWstr);

    // 2. Convert UTF-16 to UTF-8 (std::string)
    int sizeNeededForUtf8 = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, nullptr, 0, nullptr, nullptr);
    std::string utf8Str(sizeNeededForUtf8, 0);
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, &utf8Str[0], sizeNeededForUtf8, nullptr, nullptr);

    // Remove the null terminators that MultiByteToWideChar/WideCharToMultiByte add
    // when using -1 for the input length
    utf8Str.resize(sizeNeededForUtf8 - 1);
    sourceStr = std::move( utf8Str );
    return sourceStr;
}

#ifdef GENERATE_AS_EXTERNAL_TEST
#define LOG_ARGS(fmt_str, ...) fmt::print( "[GenerateASPredefined] " fmt_str "\n", __VA_ARGS__ )
#define LOG(fmt_str) fmt::print( "[GenerateASPredefined] " fmt_str "\n" )
#else
#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#define LOG_ARGS(fmt_str, ...) ALERT( at_console, fmt::format( "[GenerateASPredefined] " fmt_str "\n", __VA_ARGS__).c_str() )
#define LOG(fmt_str, ...) ALERT( at_console, "[GenerateASPredefined] " fmt_str "\n" )
#endif

using string = std::string;
using string_v = std::string_view;

namespace GenerateASPredefined
{
void Generate()
{
    auto ParseFile = []( const char* path, string& content ) -> bool
    {
        FILE* pFile = nullptr;

        pFile = fopen( path, "rb" );

        if( !pFile )
        {
            LOG_ARGS( "Couldn't open file \"{}\"\n", path );
            return false;
        }

        fseek( pFile, 0, SEEK_END );
        long size = ftell( pFile );
        fseek( pFile, 0, SEEK_SET );

        content.resize( size );
        fread( content.data(), 1, size, pFile );

        fclose( pFile );

        return true;
    };

    string asdocs;
    if( auto filename = std::filesystem::current_path() / "svencoop" / "asdocs.txt"; !ParseFile( filename.string().c_str(), asdocs ) )
        return;

    /*
    // -TODO Delay these untill all generated and maybe make all these formating in a thread?
    as_dumphooks
    as_fs_dumpfilesystem
    as_scriptbaseclasses
    condebug;wait;[as_scriptbaseclasses];wait;as_scriptbaseclasses;wait;condebug 
    as_scriptbaseclasses is a client command? Didn't output anything on dedicated server. may automate it from ClientPutInServer -TODO
    */

    // Get the last console log file for AS Base classes
    string asbaseclasses;
    {
        auto now = std::chrono::system_clock::now();
        std::time_t now_c = std::chrono::system_clock::to_time_t( now );
        std::tm* now_tm = std::localtime( &now_c );

        char time_buffer[11];
        std::strftime( time_buffer, 11, "%Y-%m-%d", now_tm );
        auto filename = std::filesystem::current_path() / fmt::format( "console-{}.log", time_buffer );

        ParseFile( filename.string().c_str(), asbaseclasses );
    }

    if( !asbaseclasses.empty() )
    {
        convertToUtf8( asbaseclasses );

        LOG_ARGS( "asbaseclasses: {}", asbaseclasses );
    }
} // End Generate
} // End GenerateASPredefined
#undef LOG
#undef LOG_ARGS
#endif // End AS_GENERATE_DOCUMENTATION