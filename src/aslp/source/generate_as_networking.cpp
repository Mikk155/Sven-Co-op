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

#include "CFile.h"
#include <fmt/format.h>

void CGenerateNetworkMessageAPI :: Initialize( const asIScriptEngine* engine )
{
    CFile file( "scripts/NetworkMessages.as", CFile::Mode::Write );

    if( !file.IsOpen() )
    {
        ALERT( at_console, "[Error] Couldn't create file \"scripts/NetworkMessages.as\"\n" );
        return;
    }

    std::string fileContent;
    fileContent.reserve(1024);

    fmt::format_to( std::back_inserter( fileContent ), "namespace NetworkMessages\n{{\n\t// Network messages IDs\n\tenum Message\n\t{{\n" );

    for( const auto& networkMessage : m_NetworkMessages )
    {
        fmt::format_to( std::back_inserter( fileContent ),
            "\t\t{} = {}, // {} Bytes.\n", networkMessage.Name, networkMessage.Id, networkMessage.Bytes );
    }

    fmt::format_to( std::back_inserter( fileContent ), "\t}}\n}}\n" );

    if( file.Write( fileContent ) )
    {
        ALERT(at_console, "File \"scripts/NetworkMessages.as\" Generated suscessfully. writted %i network message's IDs\n", m_NetworkMessages.size() );
    }
}

NetworkMessage* CGenerateNetworkMessageAPI :: GetMessageData( const std::string& name )
{
    auto listStart = m_NetworkMessages.begin();
    auto listEnd = m_NetworkMessages.end();

    auto it = std::find_if( listStart, listEnd, [&]( const auto& msg ){ return msg.Name == name; } );

    if( it != listEnd )
    {
        return &(*it);
    }

    return nullptr;
}

void CGenerateNetworkMessageAPI :: Register( const char* name, int bytes, int id )
{
    std::string msgName = std::string( name );

    NetworkMessage* msg = GetMessageData( msgName );

    if( msg != nullptr )
    {
        msg->Id = id;
        msg->Bytes = bytes;
    }
    else
    {
        m_NetworkMessages.push_back( { std::string( name ), bytes, id } );
    }
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
