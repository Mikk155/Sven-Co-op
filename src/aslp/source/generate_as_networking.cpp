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

    fmt::format_to( std::back_inserter( fileContent ), "namespace NetworkMessages\n{{\n" );

    for( const auto& networkMessage : m_NetworkMessages )
    {
        fmt::format_to( std::back_inserter( fileContent ),
            "\t// {} Bytes.\n\tconst int gmsg{} = {};\n", networkMessage.Bytes, networkMessage.Name, networkMessage.Id );
    }

    fmt::format_to( std::back_inserter( fileContent ), "}}\n" );

    if( file.Write( fileContent ) )
    {
        ALERT(at_console, "File \"scripts/NetworkMessages.as\" Generated suscessfully. writted %i network message's IDs\n", m_NetworkMessages.size() );
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
