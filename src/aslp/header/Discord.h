#include <string>

#pragma once

namespace Discord
{
    /**
     * @brief Set the Bot Token object
     */
    void SetBotToken( const std::string& token );

    /**
     * @brief Send a message to the given discord channel
     * 
     * @param channelId channel ID
     * @param content message content
     */
    void Send( const std::string& content );
}
