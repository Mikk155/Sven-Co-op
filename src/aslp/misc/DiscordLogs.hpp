#include "mandatory.h"

#pragma once

#include <string_view>
#include <string>
#include <thread>
#include <mutex>
#include <queue>
#include <condition_variable>
#include <atomic>
#include <chrono>

#include <fmt/format.h>
#include <nlohmann/json.hpp>

#include "../utils/curl.hpp"

namespace DiscordLogs
{
    inline cvar_t g_LogID = { const_cast<char*>( "sv_discord_logs" ), const_cast<char*>( "" ), FCVAR_PROTECTED };

    std::string webhook;
    std::queue<std::string> queue;
    std::condition_variable conditional;
    std::atomic<bool> running = false;
    std::thread worker;
    std::mutex mutex;

    void Shutdown()
    {
        if( running )
        {
            running = false;
            conditional.notify_all();

            if( worker.joinable() )
            {
                worker.join();
            }
        }
    }

    void Worker()
    {
        while( running )
        {
            nlohmann::json object;

            std::unique_lock lock( mutex );

            conditional.wait( lock, []{ return !queue.empty() || !running; } );

            if( !running || !g_Curl.Register() )
                return;

            object[ "content" ] = fmt::format( "-# {}", std::move( queue.front() ) );

            queue.pop();
            size_t size = queue.size();

            lock.unlock();

            curl::Request req;
            req.url = webhook;
            req.post = object.dump();
            req.headers.push_back("Content-Type: application/json");

            req.Perform();

            auto dynamicSleepTime = [&]() -> std::chrono::milliseconds
            {
                constexpr int min_delay = 200;
                constexpr int max_delay = 3000;

                if( size == 0 )
                    return std::chrono::milliseconds( max_delay );

                if( size > 50 )
                    return std::chrono::milliseconds( min_delay );

//                return std::chrono::milliseconds( static_cast<int>( max_delay - std::min( size / 50.0, 1.0 ) * ( max_delay - min_delay ) ) );
                return std::chrono::milliseconds( static_cast<int>( max_delay - min( size / 50.0, 1.0 ) * ( max_delay - min_delay ) ) );
            };

            std::this_thread::sleep_for( dynamicSleepTime() );
        }
    }

    void Initialize()
    {
        if( !running && g_Curl.Register() )
        {
            running = true;
            worker = std::thread( Worker );
        }
    }

    inline void AlertMessage( ALERT_TYPE type, const char* buffer )
    {
        if( !running || !buffer || !g_Curl.Register() )
            return;

        switch( type )
        {
            case ALERT_TYPE::at_notice:
            {
                break;
            }
            case ALERT_TYPE::at_console:
            {
                if( auto level = (int)CVAR_GET_FLOAT( "developer" ); level < 1 )
                    return;
                break;
            }
            case ALERT_TYPE::at_aiconsole:
            {
                if( auto level = (int)CVAR_GET_FLOAT( "developer" ); level < 2 )
                    return;
                break;
            }
            case ALERT_TYPE::at_warning:
            case ALERT_TYPE::at_error:
            case ALERT_TYPE::at_logged:
            {
                break;
            }
        }

        if( auto pCvar = CVAR_GET_STRING( "sv_discord_logs" ); pCvar != nullptr && pCvar[0] != '\0' )
        {
            if( auto url = std::string_view( pCvar ); webhook != url )
            {
                webhook = url;

                // Make a test on webhook to be a valid webhook, if not then clear the string.
            }

            CVAR_SET_STRING( "sv_discord_logs", "" );
        }

        if( webhook.empty() )
            return;

        std::string message = buffer;
        {
            std::lock_guard lock( mutex );
            queue.push( std::move( message ) );
        }

        conditional.notify_one();
    }
}
