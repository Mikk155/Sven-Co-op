#include "mandatory.h"

#pragma once

#include <string_view>
#include <string>
#include <thread>
#include <mutex>

#include <fmt/format.h>
#include <nlohmann/json.hpp>

#include "../utils/curl.hpp"

namespace DiscordLogs
{
    inline cvar_t g_LogID = { const_cast<char*>( "sv_discord_logs" ), const_cast<char*>( "" ), FCVAR_SERVER };
    inline cvar_t g_LogID = { const_cast<char*>( "sv_discord_logs" ), const_cast<char*>( "" ), ( FCVAR_ARCHIVE | FCVAR_PROTECTED ) };
 
    std::string g_CurrentValue;
    std::mutex mutex;

    bool IsActive()
    {
        if( auto pCvar = CVAR_GET_STRING( "sv_discord_logs" ); pCvar != nullptr && pCvar[0] != '\0' )
        {
            if( auto url = std::string_view( pCvar ); g_CurrentValue != url )
            {
                g_CurrentValue = url;

                // Make a test on g_CurrentValue to be a valid webhook, if not then clear the string.
            }

            CVAR_SET_STRING( "sv_discord_logs", "" );
        }

        return !( g_CurrentValue.empty() );
    }

    inline void AlertMessage( ALERT_TYPE type, const char* buffer )
    {
        if( !buffer || !IsActive() )
            return;

        using namespace curl;

        if( !g_Curl.Register() )
            return;

        std::string message(buffer);
        std::string webhook;
        {
            std::lock_guard lock(mutex);
            webhook = g_CurrentValue;
        }

        std::thread( [message, webhook]()
        {
            nlohmann::json j;
            j[ "content" ] = message;

            Request req;
            req.url =  webhook;
            req.post = j.dump();

            req.headers.push_back( "Content-Type: application/json" );

            auto result = req.Perform();

            if( result != Response::Ok )
            {
                //g_Curl.easy_strerror( (CURLcode)result );
            }
        } ).detach();
    }
}
