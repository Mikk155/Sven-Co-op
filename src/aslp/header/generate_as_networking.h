#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#pragma once

namespace std { using ::_snprintf; }
#include <nlohmann/json.hpp>

using json = nlohmann::json;

class CGenerateNetworkMessageAPI
{
    private:

        // Are we sending a temporal entity?
        bool m_SendingTempEntity = false;

        json m_NetworkData = json::object();

        // Current message that is being send.
        json* m_CurrentMessage;

    public:

        CGenerateNetworkMessageAPI() {};
        ~CGenerateNetworkMessageAPI() {};

        void Initialize( const asIScriptEngine* engine );

        void Begin( int msg_dest, int msg_type, const float *origin = nullptr, edict_t *edict = nullptr );
};
