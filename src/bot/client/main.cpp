/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

#include "SocketClient.h"

#include <csignal>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// Simulate a game server running syncronously
std::atomic<bool> g_GameServerRunning;
std::mutex _STOP_GAME;

class SvenSocketClient : public SocketClient
{
    public:

        void Setup( std::string _Address, int _Port, int _RecBufferSize, std::optional<SocketClient::SocketCallback> _RecCallback = std::nullopt ) override
        {
            SocketClient::Setup( _Address, _Port, _RecBufferSize, _RecCallback );
            Send( "login xp1" );
        }
};

inline SvenSocketClient g_Sockets;

void MyMessageHandler( const std::string& message )
{
    if( message[0] == '{' )
    {
        try
        {
            json input = json::parse( message );

            if( input.contains( "error" ) )
            {
                std::cerr << "Socket server error: " << input[ "error" ].get<std::string>() << std::endl;
            }
        }
        catch( const json::parse_error& e )
        {
            std::cerr << "Parse error: " << e.what() << std::endl;
        }
    }
    else
    {
        std::cout << message << std::endl;
    }
}

struct CBasePlayer
{
    int dead;
    std::string steam;
    float frags;
    std::string name;

    CBasePlayer( int _dead, std::string _steam, float _frags, std::string _name )
    {
        dead = _dead;
        steam = _steam;
        frags = _frags;
        name = _name;
    }
};

int main()
{
    g_Sockets.Setup( "127.0.0.1", 5000, 128, MyMessageHandler );

    // Have a thread for testing a simulation of game messages
    std::thread WaitForUserInputToExit( []()
    {
        std::cout << "Type 'quit' and press Enter to exit the program at any moment.\n";

        std::string line;

        while( std::getline( std::cin, line ) )
        {
            if( line == "quit" )
            {
                std::lock_guard<std::mutex> lock(_STOP_GAME);
                g_GameServerRunning = false;
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
                    CBasePlayer( 0, "STEAMID_1", 1.5, "Mikk" ),
                    CBasePlayer( 1, "STEAMID_2", 0.0, "Gafther" ),
                    CBasePlayer( 2, "STEAMID_3", 10.0, "Zode" )
            /*
                    error C7555: el uso de los inicializadores designados requiere al menos "/std:c++20" :ExtremeRage:
                    CBasePlayer{ .dead = 0, .steam = "STEAMID_1", .frags = 1.5, .name = "Mikk" },
                    CBasePlayer{ .dead = 1, .steam = "STEAMID_2", .frags = 0.0, .name = "Gafther" },
                    CBasePlayer{ .dead = 2, .steam = "STEAMID_3", .frags = 10.0, .name = "Zode" }
            */
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

                std::string jobject = "```json\n" + status.dump(4) + "\n```";

                g_Sockets.Send( jobject );
                g_Sockets.Send( status.dump() );
            }
            else
            {
                g_Sockets.Send( line.c_str() );
            }
        }
    } );

    auto ExitProgram = []( int signal )
    {
        g_GameServerRunning = false;
    };

    std::signal( SIGINT, ExitProgram );
    std::signal( SIGTERM, ExitProgram );

    SetConsoleCtrlHandler( []( DWORD type )
    {
        g_GameServerRunning = false;
        return TRUE;
    }, TRUE );

    while( g_GameServerRunning )
    {
        std::this_thread::sleep_for( std::chrono::seconds(1) );
    }

    WaitForUserInputToExit.join();

    g_Sockets.Shutdown();

    return 0;
}
