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
	fileContent.reserve(16000); // -TODO Approximate a lesser number

	fmt::format_to( std::back_inserter( fileContent ), "namespace NetworkMessages\n{{\n\t// Network messages IDs\n\tenum Message\n\t{{\n" );

	for( MessageData& networkMessage : m_RegisteredNetworkMessages )
	{
		auto GetBytesDescription = [&]() -> const std::string
		{
			switch( networkMessage.Bytes )
			{
				case -2:
					return "Unknown number of bytes.";
				case -1:
					return "Dynamic number of bytes.";
				break;
				case 0:
					return"No bytes expected.";
				break;
				case 1:
					return "Expected 1 Byte.";
				break;
				default:
					return fmt::format( "Expected {} Bytes.", networkMessage.Bytes );
				break;
			}
		};

		fmt::format_to( std::back_inserter( fileContent ),
			"{}\t\t{} = {}, // {}\n", networkMessage.Info, networkMessage.Name, networkMessage.Id, GetBytesDescription() );

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

	// Double check because breaking API is the sven's sloggan
	auto GetMessageByNameOrID = [&]( MessageData* message ) -> bool
	{
		if( message != nullptr )
		{
			message->Name = msgName;
			message->Id = id;
			message->Bytes = bytes;
			return true;
		}
		return false;
	};

	// Name first because changing ID may be more common than names? Idk what sane person would update the registry ordering but whatever.
	if( GetMessageByNameOrID( GetMessageData( msgName ) ) )
		return;

	if( GetMessageByNameOrID( GetMessageData( id ) ) )
		return;

	MessageData data{
		.Name = std::move( msgName ),
		.Id = id,
		.Bytes = bytes
	};

	m_RegisteredNetworkMessages.push_back( std::move( data ) );
}
