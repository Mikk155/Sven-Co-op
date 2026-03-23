// Special thanks to AnggaraNothing for https://github.com/anggaranothing/sc-py-asdocs-vscode
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

#include <fmt/core.h>

#pragma once

#define LOG_ARGS(fmt_str, ...) { \
    std::lock_guard<std::mutex> lock(state->bufferMutex); \
    state->buffer.push_back( fmt::format( "[GenerateASPredefined] " fmt_str "\n", __VA_ARGS__ ) ); }
#define LOG(fmt_str) { \
    std::lock_guard<std::mutex> lock(state->bufferMutex); \
    state->buffer.push_back( "[GenerateASPredefined] " fmt_str "\n" ); }

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
    for( int i = 0; i < 100; ++i )
    {
        if( state->cancel.load() )
            break;

        LOG_ARGS( "Procesing {}", i )
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
} // End GenerateASPredefined
#undef LOG
#undef LOG_ARGS
#endif // End AS_GENERATE_DOCUMENTATION
