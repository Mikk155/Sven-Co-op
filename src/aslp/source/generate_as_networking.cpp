#include "generate_as_networking.h"

CGenerateNetworkMessageAPI::~CGenerateNetworkMessageAPI()
{
    for( json& networkMessage : m_NetworkData )
    {
        networkMessage.clear();
    }

    m_NetworkData.clear();

    if( m_CurrentMessage != nullptr )
    {
        m_CurrentMessage->clear();
    }

    m_NetworkMessages.clear();
}

void CGenerateNetworkMessageAPI :: Initialize( const asIScriptEngine* engine )
{
    for( const auto& networkMessage : m_NetworkMessages )
    {
        ALERT( at_console, "Registered %s with %i bytes at ID %i.\n", networkMessage.Name.c_str(), networkMessage.Bytes, networkMessage.Id );
    }
}

void CGenerateNetworkMessageAPI :: Register( const char* name, int bytes, int id )
{
    m_NetworkMessages.push_back( { std::string( name ), bytes, id } );
}

void CGenerateNetworkMessageAPI :: Write( Type type )
{
    std::string typeName;

    switch( type )
    {
        case Type::Byte:
        {
            typeName = "byte";
            break;
        }
        case Type::Char:
        case Type::Short:
        case Type::Long:
        case Type::Entity:
        {
            // Int
        }
        case Type::Angle:
        case Type::Coord:
        {
            // float
        }
        case Type::String:
        {
            // const char*
        }
    }
}

void CGenerateNetworkMessageAPI :: Begin( int msg_dest, int msg_type, const float *origin, edict_t *edict )
{
}

CGenerateNetworkMessageAPI* g_NetworkMessageAPI = nullptr;
