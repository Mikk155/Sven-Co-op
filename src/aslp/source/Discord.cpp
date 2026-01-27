#include <vector>

#include "Discord.h"
#include "curl.hpp"

#include <fmt/core.h>

namespace std { using ::_snprintf; }
#include <nlohmann/json.hpp>
using json = nlohmann::json;

namespace Discord
{
    static std::string BotToken;
    static std::vector<std::string> ToDiscord = {};
}

void Discord::SetBotToken( const std::string& token )
{
    BotToken = token;
}

void Discord::Send( const std::string& content )
{
    if( BotToken.empty() || !g_Curl.Register())
        return;

    std::thread SendMessageToDiscord( [&]()
    {
        curl::Request req;

        req.url = fmt::format(
            "https://discord.com/api/v10/channels/{}/messages",
            1465504428357320816
        );

        json body;
        body["content"] = content;

        req.post = body.dump();

        req.headers = {
            "Content-Type: application/json",
            "User-Agent: MyGameServerBot (https://example.com, 1.0)",
            fmt::format("Authorization: Bot {}", BotToken)
        };

        req.Perform();
    } );

    SendMessageToDiscord.join();
}
