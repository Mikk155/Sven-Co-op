#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>
#include "CASNetworkMessage.h"

#pragma once

class CNetworkMessageAPI
{
    public:

        // Registered network message information
        struct MessageData
        {
            // String name in the client side.
            std::string Name;

            // Number of bytes sent.
            int Bytes;

            // ID in the server side.
            int Id;

            // Byte types and ordering to sent.
            std::vector<CASNetworkMessageByteType> Data = {};

            // Information string (Cleared after documentation is writted)
            std::string Info;
        };

    private:

        // Every Network Message registered.
        std::vector<MessageData> m_RegisteredNetworkMessages = {
            { .Name = "SVC_BAD", .Id = 0 }
        };

    public:

        MessageData* GetMessageData( const std::string& name );
        MessageData* GetMessageData( int id );

        void Initialize( const asIScriptEngine* engine );

        void Register( const char* name, int bytes, int id );
};

inline CNetworkMessageAPI g_NetworkMessageAPI;
