#include <extdll.h>
#include <meta_api.h>
#include "enginedef.h"

#include <csignal>
#include "discord.h"
#include <string>
#include <thread>

#include <nlohmann/json.hpp>
#include <fmt/format.h>

#include "curl.h"

using json = nlohmann::json;

static std::string g_BotToken;

bool Discord::IsActive()
{
    if( g_BotToken.empty() )
    {
        return false;
    }

    return true;
}

void Discord::SetBotToken( const std::string& token )
{
    g_BotToken = token;
}

std::vector<std::string> GameMessageQuery = {};

void Discord::ToDiscord( const std::string& message )
{
    GameMessageQuery.push_back( std::move( message ) );
}

void Discord::Think()
{
}

void Discord::Send( const std::string& channelId, const std::string& content )
{
    if( !IsActive() )
        return;

    curl::Request req;

    req.url = fmt::format(
        "https://discord.com/api/v10/channels/{}/messages",
        channelId
    );

    json body;
    body["content"] = content;

    req.post = body.dump();

    req.headers = {
        "Content-Type: application/json",
        fmt::format("Authorization: Bot {}", g_BotToken)
    };

    if (!req.Perform())
    {
        ALERT(at_error, "Discord SendMessage failed\n");
        return;
    }

    ALERT(at_console, "Discord response: %s\n", req.response.c_str());
}
