#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#pragma once

namespace std { using ::_snprintf; }
#include <nlohmann/json.hpp>

using json = nlohmann::json;

struct NetworkMessage
{
    std::string Name;
    int Bytes;
    int Id;
};

class CGenerateNetworkMessageAPI
{
    private:

        // Are we sending a temporal entity?
        bool m_SendingTempEntity = false;

        json m_NetworkData = json::object();

        // Current message that is being send.
        json* m_CurrentMessage = nullptr;

        std::vector<NetworkMessage> m_NetworkMessages = {};

    public:

        CGenerateNetworkMessageAPI() {};
        ~CGenerateNetworkMessageAPI();

        NetworkMessage* GetMessageData( const std::string& name );

        void Initialize( const asIScriptEngine* engine );

        void Register( const char* name, int bytes, int id );
        void Begin( int msg_dest, int msg_type, const float *origin = nullptr, edict_t *edict = nullptr );

        enum class Type
        {
            Byte,
            Char,
            Short,
            Long,
            Angle,
            Coord,
            String,
            Entity
        };

        void Write( Type type );
};
