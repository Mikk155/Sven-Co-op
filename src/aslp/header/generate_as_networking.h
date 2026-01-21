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

			// ID in the server side.
			int Id;

			// Number of bytes sent.
			int Bytes;

			// Byte types and ordering to sent.
			std::vector<CASNetworkMessageByteType> Data = {};

			// Information string (Cleared after documentation is writted)
			std::string Info;
		};

	private:

		// Every Network Message registered.
		std::vector<MessageData> m_RegisteredNetworkMessages = {
			{ .Name = "Bad", .Id = 0 },
			{ .Name = "Nop", .Id = 1 },
			{ .Name = "Disconnect", .Id = 2 },
			{ .Name = "Event", .Id = 3 },
			{ .Name = "Version", .Id = 4 },
			{ .Name = "SetView", .Id = 5 },
			{ .Name = "Sound", .Id = 6 },
			{ .Name = "Time", .Id = 7 },
			{ .Name = "Print", .Id = 8 },
			{ .Name = "StuffText", .Id = 9 },
			{ .Name = "SetAngle", .Id = 10 },
			{ .Name = "ServerInfo", .Id = 11 },
			{ .Name = "LightStyle", .Id = 12 },
			{ .Name = "UpdateUserInfo", .Id = 13 },
			{ .Name = "DeltaDescription", .Id = 14 },
			{ .Name = "ClientData", .Id = 15 },
			{ .Name = "StopSound", .Id = 16 },
			{ .Name = "Pings", .Id = 17 },
			{ .Name = "Particle", .Id = 18 },
			{ .Name = "Damage", .Id = 19 },
			{ .Name = "SpawnStatic", .Id = 20 },
			{ .Name = "EventReliable", .Id = 21 },
			{ .Name = "SpawnBaseline", .Id = 22 },
			{ .Name = "TempEntity", .Id = 23 },
			{ .Name = "SetPause", .Id = 24 },
			{ .Name = "SignOnNum", .Id = 25 },
			{ .Name = "CenterPrint", .Id = 26 },
			{ .Name = "KilledMonster", .Id = 27 },
			{ .Name = "FoundSecret", .Id = 28 },
			{ .Name = "SpawnStaticSound", .Id = 29 },
			{ .Name = "Intermission", .Id = 30 },
			{ .Name = "Finale", .Id = 31 },
			{ .Name = "CdTrack", .Id = 32 },
			{ .Name = "Restore", .Id = 33 },
			{ .Name = "CutScene", .Id = 34 },
			{ .Name = "WeaponAnim", .Id = 35 },
			{ .Name = "DecalName", .Id = 36 },
			{ .Name = "RoomType", .Id = 37 },
			{ .Name = "AddAngle", .Id = 38, .Bytes = 2, .Info = R"(
		/**
		*	Add an angle on the yaw axis of the current client's view angle.
		*	Note: When pev->fixangle is set to 2, this message is called with pev->avelocity[1] as a value.
		*	Note: The value needs to be scaled by (65536 / 360).
        *   Expected {} Bytes.
		*	Structure:
		*	short	AngleToAdd
		**/
)" },
			{ .Name = "NewUserMsg", .Id = 39 },
			{ .Name = "PacketEntities", .Id = 40 },
			{ .Name = "DeltaPacketEntities", .Id = 41 },
			{ .Name = "Choke", .Id = 42 },
			{ .Name = "ResourceList", .Id = 43 },
			{ .Name = "NewMoveVars", .Id = 44 },
			{ .Name = "ResourceRequest", .Id = 45 },
			{ .Name = "Customization", .Id = 46 },
			{ .Name = "CrosshairAngle", .Id = 47 },
			{ .Name = "SoundFade", .Id = 48 },
			{ .Name = "FileTxferFailed", .Id = 49 },
			{ .Name = "Hltv", .Id = 50 },
			{ .Name = "Director", .Id = 51 },
			{ .Name = "VoiceInit", .Id = 52 },
			{ .Name = "VoiceData", .Id = 53 },
			{ .Name = "SendExtraInfo", .Id = 54 },
			{ .Name = "TimeScale", .Id = 55 },
			{ .Name = "ResourceLocation", .Id = 56 },
			{ .Name = "SendCvarValue", .Id = 57 },
			{ .Name = "SendCvarValue2", .Id = 58 }
		};
		// Information for these has been taken from https://wiki.alliedmods.net/Half-Life_1_Engine_Messages

	public:

		MessageData* GetMessageData( const std::string& name );
		MessageData* GetMessageData( int id );

		void Initialize( const asIScriptEngine* engine );

		void Register( const char* name, int bytes, int id );
};

inline CNetworkMessageAPI g_NetworkMessageAPI;
