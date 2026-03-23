// Remove dis shit later since VSC bitches about it. -TODO
#define AS_GENERATE_DOCUMENTATION 1

// Special thanks to AnggaraNothing for the idea: https://github.com/anggaranothing/sc-py-asdocs-vscode
#if AS_GENERATE_DOCUMENTATION
#include <string>
#include <string_view>
#include <cstdio>
#include <filesystem>
#include <ctime>
#include <chrono>
#include <atomic>
#include <thread>
#include <vector>
#include <mutex>

#include "../utils/File.hpp"

#include <fmt/core.h>

#ifndef EXTERNAL_PROGRAM_TEST
#include "mandatory.h"
#endif

#ifdef WINDOWS
#include <windows.h>
#else
// convertToUTF8
#endif

#pragma once

#define LOG(fmt_str) { \
    std::lock_guard<std::mutex> lock(state->bufferMutex); \
    state->buffer.push_back( "[GenerateASPredefined] " fmt_str "\n" ); }

#define LOG_ARGS(fmt_str, ...) { \
    std::lock_guard<std::mutex> lock(state->bufferMutex); \
    state->buffer.push_back( fmt::format( "[GenerateASPredefined] " fmt_str "\n", __VA_ARGS__ ) ); }

namespace GenerateASPredefined
{
using string = std::string;
using string_v = std::string_view;

struct ThreadState
{
    std::atomic<bool> cancel{false};
    std::atomic<bool> done{false};

    std::mutex bufferMutex;
    std::vector<string> buffer;
};

inline void Generate( ThreadState* state )
{
    // Convert from a specific source encoding (e.g., system's active code page CP_ACP) to UTF-8
    auto convertToUTF8 = []( string& sourceStr ) -> string&
    {
#ifdef WINDOWS
        int sizeNeededForWstr = MultiByteToWideChar( CP_ACP, 0, sourceStr.c_str(), -1, nullptr, 0 );
        std::wstring wstr( sizeNeededForWstr, 0 );
        MultiByteToWideChar( CP_ACP, 0, sourceStr.c_str(), -1, &wstr[0], sizeNeededForWstr );

        int sizeNeededForUtf8 = WideCharToMultiByte( CP_UTF8, 0, wstr.c_str(), -1, nullptr, 0, nullptr, nullptr );
        string utf8Str( sizeNeededForUtf8, 0 );
        WideCharToMultiByte( CP_UTF8, 0, wstr.c_str(), -1, &utf8Str[0], sizeNeededForUtf8, nullptr, nullptr );

        // Remove the null terminators that MultiByteToWideChar/WideCharToMultiByte add
        // when using -1 for the input length
        utf8Str.resize(sizeNeededForUtf8 - 1);
        sourceStr = std::move( utf8Str );
#else
        // -TODO Maybe linux?
#endif
        return sourceStr;
    };

    File as_predefined( "svencoop_addon/as.predefined.txt" ); // txt for no to not replace mine
    as_predefined.Base = true;
    as_predefined.Write( "// Header \n" );

    // -Read asdocs.txt here- and Append to as_predefined

    // -Read hooks.txt here- and Append to as_predefined

    // Get the last console log file for AS Base classes
    string asbaseclasses;
    {
        auto now = std::chrono::system_clock::now();
        std::time_t now_c = std::chrono::system_clock::to_time_t( now );
        std::tm* now_tm = std::localtime( &now_c );

        char time_buffer[11];
        std::strftime( time_buffer, 11, "%Y-%m-%d", now_tm );
        string fileName = fmt::format( "console-{}.log", time_buffer );
        File asbaseclass_file( fileName );
        asbaseclass_file.Base = true;

        if( asbaseclass_file.Read( asbaseclasses ) && !asbaseclasses.empty() )
        {
            convertToUTF8( asbaseclasses );
            if( size_t startClass = asbaseclasses.find( "abstract class" ); startClass != std::string::npos )
                asbaseclasses = asbaseclasses.substr( startClass );
            asbaseclasses = asbaseclasses.substr( 0, asbaseclasses.rfind( "}", asbaseclasses.find( "end_scriptbaseclasses" ) ) + 1 );
            as_predefined.Append( asbaseclasses );
        }
        else
        {
            asbaseclasses.clear();
            LOG_ARGS( "Error: Could not parse the abstract base class file {} Skipping...", fileName )
        }
    }

    state->done = true;
}

inline std::thread g_thread;
inline ThreadState* g_state = nullptr;

inline void Start()
{
    g_state = new ThreadState();
    g_thread = std::thread( Generate, g_state );
}

inline void Shutdown()
{
    if( g_state != nullptr )
    {
        g_state->cancel = true;
        g_state->buffer.clear();
        delete g_state;
        g_state = nullptr;
    }

    if( g_thread.joinable() )
        g_thread.join();
}

#ifndef EXTERNAL_PROGRAM_TEST
inline void GameDumpData()
{
    static bool ASDocGenerator = false;

    if( !ASDocGenerator )
    {
        // Dump hooks
        SERVER_COMMAND( const_cast<char*>( "as_dumphooks hooks\n" ) );

        // The server may have condebug enabled so do two runs to make sure it's logged
        for( int log = 0; log < 2; log++ )
        {
            // Toggle condebug
            SERVER_COMMAND( const_cast<char*>( "condebug\n" ) );

            // Prefix on log
            SERVER_COMMAND( const_cast<char*>( "echo start_scriptbaseclasses\n" ) );

            // Output abstract classes
            SERVER_COMMAND( const_cast<char*>( "as_scriptbaseclasses\n" ) );

            char* wait = const_cast<char*>( "wait\n" );

            // Wait 120 frames
            for( int i = 0; i < 120; i++ ) {
                SERVER_COMMAND( wait );
            }

            // Suffix on log
            SERVER_COMMAND( const_cast<char*>( "echo end_scriptbaseclasses\n" ) );
        }

        // Call Start() from ClientCommand hook.
        SERVER_COMMAND( const_cast<char*>( "generate_as_predefined\n" ) );

        SERVER_EXECUTE();

        ASDocGenerator = true;
    }
}

inline void StartFrame()
{
    if( g_state != nullptr && g_state->done )
    {
        for( const std::string& str : g_state->buffer )
        {
            ALERT( at_console, str.c_str() );
        }
        Shutdown();
        return;
    }
}
#endif
} // End GenerateASPredefined
#undef LOG
#undef LOG_ARGS
#endif // End AS_GENERATE_DOCUMENTATION
