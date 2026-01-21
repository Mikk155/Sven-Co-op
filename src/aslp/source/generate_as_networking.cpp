#include "generate_as_networking.h"

#include "CFile.h"
#include <fmt/format.h>

void CNetworkMessageAPI :: Initialize( const asIScriptEngine* engine )
{
	CFile file( "scripts/mikk/NetworkMessages.as", CFile::Mode::Write );

	if( !file.IsOpen() )
	{
		ALERT( at_console, "[Error] Couldn't create file \"scripts/NetworkMessages.as\"\n" );
		return;
	}

	std::string fileContent;
	fileContent.reserve(2048);

	fmt::format_to( std::back_inserter( fileContent ), "namespace NetworkMessages\n{{\n\t// Network messages IDs\n\tenum Message\n\t{{\n" );

	for( MessageData& networkMessage : m_RegisteredNetworkMessages )
	{
		if( !networkMessage.Info.empty() )
		{
			fmt::format_to( std::back_inserter( fileContent ), fmt::runtime( networkMessage.Info ), networkMessage.Bytes );
 
			// Already documented. these string aren't needed anymore.
			networkMessage.Info.clear();
		}
        else
        {
            switch( networkMessage.Bytes )
            {
                case -1:
    			    fmt::format_to( std::back_inserter( fileContent ), "\n\t\t/**\n\t\t*\tDynamic number of bytes.\n\t\t**/\n" );
                break;
                case 0:
    			    fmt::format_to( std::back_inserter( fileContent ), "\n\t\t/**\n\t\t*\tNo bytes expected.\n\t\t**/\n" );
                break;
                case 1:
    			    fmt::format_to( std::back_inserter( fileContent ), "\n\t\t/**\n\t\t*\tExpected 1 Byte.\n\t\t**/\n" );
                break;
                default:
    			    fmt::format_to( std::back_inserter( fileContent ), "\n\t\t/**\n\t\t*\tExpected {} Bytes.\n\t\t**/\n", networkMessage.Bytes );
                break;
            }
        }

		fmt::format_to( std::back_inserter( fileContent ),
			"\t\t{} = {}\n", networkMessage.Name, networkMessage.Id  );
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
			.Id = id,
			.Bytes = bytes
		};

		m_RegisteredNetworkMessages.push_back( std::move( data ) );
	}
}
