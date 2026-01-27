#include <string>
#include <vector>

#pragma once

namespace Discord
{
    // Send a message to discord
    void ToDiscord( const std::string& message );
    void Think();
    bool IsActive();
    void SetBotToken( const std::string& token );
    void Send( const std::string& channelId, const std::string& content );
}
