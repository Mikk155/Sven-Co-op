#include <csignal>
#include <iostream>

#include "Discord.h"
#include "curl.hpp"

#include <fmt/core.h>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

#ifndef DISCORD_CURL_TEST
#define DISCORD_CURL_TEST
#endif

struct CBasePlayer
{
    int dead;
    std::string steam;
    double frags;
    std::string name;
};

int main()
{
    Discord::SetBotToken( ".." );

    fmt::print( "Type 'quit' and press Enter to exit the program at any moment.\n" );

    std::string line;

    while( std::getline( std::cin, line ) )
    {
        if( line == "quit" )
        {
            break;
        }
        if( line == "status" )
        {
            json status = json::object();
            status[ "hostname" ] = "Dedicated Server";
            status[ "channel" ] = 1401679321776787516;
            status[ "mapname" ] = "hl_c04";
            status[ "nextmap" ] = "hl_c05_a1";

            json players_data = json::array();

            std::vector<CBasePlayer> players =
            {
                CBasePlayer{ .dead = 0, .steam = "STEAMID_1", .frags = 1.5, .name = "Mikk" },
                CBasePlayer{ .dead = 1, .steam = "STEAMID_2", .frags = 0.0, .name = "Gafther" },
                CBasePlayer{ .dead = 2, .steam = "STEAMID_3", .frags = 10.0, .name = "Zode" }
            };

            for( const CBasePlayer& p : players )
            {
                json player_data = json::object();

                player_data[ "name" ] = p.name;
                player_data[ "dead" ] = p.dead;
                player_data[ "steam" ] = p.steam;
                player_data[ "frags" ] = (int)p.frags;

                players_data.emplace_back( player_data );
            }

            status[ "players" ] = players_data;

            std::string jobject = "```json\n" + status.dump(4) + "\n```\n";

            Discord::Send( jobject );
        }
        else
        {
            Discord::Send( line );
        }
    }

    dynlib::Close( g_Curl.curl_library );

    return 0;
}
