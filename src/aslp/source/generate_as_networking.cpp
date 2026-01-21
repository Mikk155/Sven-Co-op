#include "generate_as_networking.h"

#include "CFile.h"
#include <fmt/format.h>

void CNetworkMessageAPI :: Initialize( const asIScriptEngine* engine )
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

    for( MessageData& networkMessage : m_RegisteredNetworkMessages )
    {
        fmt::format_to( std::back_inserter( fileContent ),
            "\t\t{} = {}, // {} Bytes.\n", networkMessage.Name, networkMessage.Id, networkMessage.Bytes );

        // Already documented. these string aren't needed anymore.
        networkMessage.Info.clear();
    }

    fmt::format_to( std::back_inserter( fileContent ), "\t}}\n}}\n" );

    if( file.Write( fileContent ) )
    {
        ALERT(at_console, "File \"scripts/NetworkMessages.as\" Generated suscessfully. writted %i network message's IDs\n", m_RegisteredNetworkMessages.size() );
    }
}

CNetworkMessageAPI::MessageData* CNetworkMessageAPI :: GetMessageData( const std::string& name )
{
    auto listStart = m_RegisteredNetworkMessages.begin();
    auto listEnd = m_RegisteredNetworkMessages.end();
    auto it = std::find_if( listStart, listEnd, [&]( const auto& msg ){ return msg.Name == name; } );
    if( it != listEnd ) {
        return &(*it);
    }
    return nullptr;
}

CNetworkMessageAPI::MessageData* CNetworkMessageAPI :: GetMessageData( int id )
{
    auto listStart = m_RegisteredNetworkMessages.begin();
    auto listEnd = m_RegisteredNetworkMessages.end();
    auto it = std::find_if( listStart, listEnd, [&]( const auto& msg ){ return msg.Id == id; } );
    if( it != listEnd ) {
        return &(*it);
    }
    return nullptr;
}

void CNetworkMessageAPI :: Register( const char* name, int bytes, int id )
{
    std::string msgName = std::string( name );

    MessageData* msg = GetMessageData( id );

    if( msg != nullptr )
    {
        msg->Id = id;
        msg->Bytes = bytes;
    }
    else
    {
        MessageData data{
            .Name = std::string( name ),
            .Bytes = bytes,
            .Id = id
        };

        m_RegisteredNetworkMessages.push_back( std::move( data ) );
    }
}
