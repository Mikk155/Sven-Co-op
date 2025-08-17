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

#include <string>
#include <iostream>
#include <thread>
#include <functional>
#include <optional>
#include <atomic>
#include <algorithm>
#include <mutex>

#pragma once

#define _WINSOCK_DEPRECATED_NO_WARNINGS
#include <winsock2.h>
#pragma comment( lib, "ws2_32.lib" )

inline std::atomic<bool> _SOCKET_ONLINE{false};
std::mutex _SOCKET_MUTEX;

class SocketClient
{
    public:

        using SocketCallback = std::function<void( const std::string& )>;

    protected:

        std::string Address;
        int Port;
        int RecBufferSize;
        std::optional<SocketCallback> RecCallback;

        std::thread m_Thread;

        SOCKET m_Socket = INVALID_SOCKET;

    public:

        ~SocketClient()
        {
            Shutdown();
        }

        /**
         * @brief Setup socket client
         * 
         * @param _Address 
         * @param _Port 
         * @param _RecBufferSize Buffer max size clamp for incoming sockets
         * @param _RecCallback Callback for incoming sockets
         */
        virtual void Setup( std::string _Address, int _Port, int _RecBufferSize, std::optional<SocketCallback> _RecCallback = std::nullopt )
        {
            Address = _Address;
            Port = _Port;
            RecBufferSize = std::clamp( _RecBufferSize, 1, SO_MAX_MSG_SIZE );
            RecCallback = _RecCallback;

            char buffer[128];
            sprintf( buffer, "Setup at %s:%i with incoming buffer of %i", Address.c_str(), Port, RecBufferSize );
            print( buffer );

            if( !RecCallback.has_value() )
            {
                print( "No external callback method set. this client won't receive messages." );
            }

            TryConnect();
        }

        virtual void StartWSA()
        {
            if( _SOCKET_ONLINE )
                return;

            WSADATA wsa;

            if( WSAStartup( MAKEWORD( 2, 2 ), &wsa ) != 0 )
            {
                print( "WSAStartup failed." );
                return;
            }
            _SOCKET_ONLINE = true;
        }
        virtual void CloseThread()
        {
            if( RecCallback.has_value() && m_Thread.joinable() && std::this_thread::get_id() != m_Thread.get_id() )
            {
                try {
                    m_Thread.join();
                } catch (...) {}
            }
        }

        virtual void Disconnect()
        {
            std::lock_guard<std::mutex> lock(_SOCKET_MUTEX);

            CloseThread();

            if( IsActive() )
            {
                shutdown(m_Socket, SD_BOTH);
                closesocket(m_Socket);
                m_Socket = INVALID_SOCKET;
            }
        }

        virtual void Shutdown()
        {
            Disconnect();

            if( _SOCKET_ONLINE )
            {
                WSACleanup();
                _SOCKET_ONLINE = false;
            }
        }

        /**
         * @brief Return whatever the client socket is currently active and has connection to the server
         */
        virtual bool IsActive() const
        {
            return ( m_Socket != INVALID_SOCKET );
        }

        /**
         * @brief Send a message to the server socket. if we're not connected it will attempt to connect first.
         */
        virtual void Send( const char* message )
        {
            if( message == nullptr || message[0] == '\0' )
            {
                return;
            }

            if( !_SOCKET_ONLINE )
            {
                StartWSA();

                if( !_SOCKET_ONLINE )
                {
                    return;
                }
            }

            if( !IsActive() )
            {
                TryConnect();
            }

            if( !IsActive() )
                return;

            int result = send( m_Socket, message, static_cast<int>( strlen( message ) ), 0 );

            if( result == SOCKET_ERROR )
            {
                int error = WSAGetLastError();

                char buffer[48];
                sprintf( buffer, "Error sending string: %i for message:", error );
                print( buffer );
                print( message );

                Disconnect();
            }
        }

        /**
         * @brief Send a message to the server socket. if we're not connected it will attempt to connect first.
         */
        virtual void Send( const std::string& message )
        {
            if( !message.empty() )
            {
                Send( message.c_str() );
            }
        }

        /**
         * @brief Shutdown connection if any and attempt to connect
         */
        virtual void TryConnect()
        {
            Disconnect();

            m_Socket = socket( AF_INET, SOCK_STREAM, 0 );

            if( !IsActive() )
            {
                print( "Socket creation failed." );
                Disconnect();
                return;
            }

            sockaddr_in server;
            server.sin_family = AF_INET;
            server.sin_port = htons( Port );
            server.sin_addr.s_addr = inet_addr( Address.c_str() );

            if( int result = connect( m_Socket, (sockaddr*)&server, sizeof( server ) ); result < 0 )
            {
                char buffer[48];
                sprintf( buffer, "Failed to connect to a server: %i", result );
                print( buffer );
                Disconnect();
                return;
            }
            print( "Connected to a server" );

            if( RecCallback.has_value() )
            {
                CloseThread();
                m_Thread = std::thread( &SocketClient::SocketThread, this );
            }
        }

    protected:

        virtual void SocketThread()
        {
            char buffer[SO_MAX_MSG_SIZE];

            while( IsActive() )
            {
                if( !RecCallback.has_value() )
                    break;

                int bytes = recv( m_Socket, buffer, RecBufferSize, 0 );

                if( bytes > 0 )
                {
                    std::string msg( buffer, bytes );

                    RecCallback.value()(msg);
                }
                else if( WSAGetLastError() == WSAECONNRESET )
                {
                    Disconnect();
                    break;
                }
                else
                {
                    print( "recv() failed" );
                    Disconnect();
                    break;
                }
            }
        }

        /**
         * @brief Print a message to console, overide method to print to the game message system
         */
        virtual void print( const char* message )
        {
            std::cout << "[SocketClient] " << message << std::endl;
        }
};
