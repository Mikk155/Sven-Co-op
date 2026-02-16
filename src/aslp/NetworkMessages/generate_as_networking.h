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
			int Bytes = -2;

			// Byte types and ordering to sent.
			std::vector<NetworkMessages::ByteType> Data = {};

			// Information string (Cleared after documentation is writted)
			std::string Info;
		};

	private:

		// Every Network Message registered.
		std::vector<MessageData> m_RegisteredNetworkMessages = {
			{ .Name = "Bad", .Id = 0 },
			{ .Name = "Nop", .Id = 1, .Info = R"(
		/**
		*	@brief Does absolutely nothing.
		*	Note: Server pads outgoing messages with SVC_NOP if the total datagram size is lesser than 16.
		**/
)" },
			{ .Name = "Disconnect", .Id = 2, .Info = R"(
		/**
		*	@brief Disconnects a player with given reason.
		*	Structure:
		*	string	Reason
		**/
)" },
			{ .Name = "Event", .Id = 3, .Info = R"(
		/**
		*	@brief An event, defined by the game library, has recently occurred on the server.
		*	Note: This message can be dropped if the client already has too much content in its unreliable buffer.
		*	Note: Events can be precached using pfnPrecacheEvent routine.
		*	Note: Events are queued and grouped together every frame, if there's any.
		*	Note: EventArgs are always inherited from "null" event args.
		*	Note: Only a max of 31 events can be queued and subsequently sent this way.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	5 bits	NumberOfEvents
		*	10 bits	EventIndex
		*	1 bit	HasEntsInPack
		*	] 11 bits	PacketIndex
		*	] 1 bit	HasEventArgs
		*	] n bits	EventArgs (delta-compressed event_args_t)
		*	1 bit	HasFireTime
		*	] 16 bits	FireTime
		*	...	more events if needed
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "Version", .Id = 4, .Info = R"(
		/**
		*	@brief Disconnects the client and sends a message to the console if the number passed doesn't match the current server protocol version.
		*	Note: Message type sent: "CL_Parse_Version: Server is protocol %i instead of %i\n".
		*	Note: This message seems to be unused.
		*	Structure:
		*	long	ProtocolVersion
		**/
)" },
			{ .Name = "SetView", .Id = 5, .Info = R"(
		/**
		*	@brief Attaches a player's view to an entity.
		*	Note: Called from pfnSetView. The same as attach_view() native.
		*	Structure:
		*	short	EntityIndex
		**/
)" },
			{ .Name = "Sound", .Id = 6, .Info = R"(
		/**
		*	@brief Plays a sound file on the client.
		*	Note: The sound index can be short or long. If the index can fit in a single byte, the short variant is used, otherwise SND_LONG_INDEX bit (4) is included in Flags and 16 bits would be used for SoundIndex variable.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	9 bits	Flags
		*	8 bits	Volume 		*	 255 (flags&1)
		*	8 bits	Attenuation 		*	 64 (flags&2)
		*	3 bits	Channel
		*	11 bits	EntityIndex
		*	] 16 bits	SoundIndex (flags&4)
		*	] or	
		*	] 8 bits	SoundIndex !(flags&4)
		*	n bits	Origin
		*	8 bits	Pitch (flags&8)
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "Time", .Id = 7, .Info = R"(
		/**
		*	@brief Notifies clients about the current server time.
		*	Note: This message is sent every frame by the server.
		*	Structure:
		*	float	Time
		**/
)" },
			{ .Name = "Print", .Id = 8, .Info = R"(
		/**
		*	@brief Sends a message to the client's console.
		*	Note: Called from pfnClientPrintf with print_console or print_notify as type.
		*	Structure:
		*	string	Message
		**/
)" },
			{ .Name = "StuffText", .Id = 9, .Info = R"(
		/**
		*	@brief Executes command on player.
		*	Note: This message is sent by client_cmd(index,const command[],any:...)
		*	Structure:
		*	string	Command
		**/
)" },
			{ .Name = "SetAngle", .Id = 10, .Info = R"(
		/**
		*	@brief Update immediately the client's view angles.
		*	Note: When pev->fixangle is set to a value other than 0 or 2, this message is sent with the current player's pev->v_angle values.
		*	Note: This message is also sent during the client connection process, but with AngleRoll always set to 0.
		*	Note: The provided angles need to be scaled by (65536 / 360).
		*	Structure:
		*	short	AnglePitch
		*	short	AngleYaw
		*	short	AngleRoll
		**/
)" },
			{ .Name = "ServerInfo", .Id = 11, .Info = R"(
		/**
		*	@brief Contains information about the server.
		*	Note: SpawnCount is the number of times the server has changed its map.
		*	Note: MapFileName contains full map name relatively to the root directory, like maps/de_dust2.bsp.
		*	Note: Contents of "mapcyclefile" are copied into Mapcycle string, allowing up to 8 KB of data.
		*	Structure:
		*	long	Protocol
		*	long	SpawnCount
		*	long	MapCRC
		*	16 bytes	ClientDLLHash
		*	byte	MaxPlayers
		*	byte	PlayerIndex
		*	byte	IsDeathmatch
		*	string	GameDir
		*	string	Hostname
		*	string	MapFileName
		*	string	Mapcycle
		*	byte	0
		**/
)" },
			{ .Name = "LightStyle", .Id = 12, .Info = R"(
		/**
		*	@brief Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
		*	Note: Server send 64 lightstyles to client during client connect. Most of them has empty light info. All of them could be found in world.cpp
		*	// 0 normal
		*	LIGHT_STYLE(0, "m");
		*	// 1 FLICKER (first variety)
		*	LIGHT_STYLE(1, "mmnmmommommnonmmonqnmmo");	
		*	// 2 SLOW STRONG PULSE
		*	LIGHT_STYLE(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");	
		*	// 3 CANDLE (first variety)
		*	LIGHT_STYLE(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");	
		*	// 4 FAST STROBE
		*	LIGHT_STYLE(4, "mamamamamama");	
		*	// 5 GENTLE PULSE 1
		*	LIGHT_STYLE(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");	
		*	// 6 FLICKER (second variety)
		*	LIGHT_STYLE(6, "nmonqnmomnmomomno");	
		*	// 7 CANDLE (second variety)
		*	LIGHT_STYLE(7, "mmmaaaabcdefgmmmmaaaammmaamm");	
		*	// 8 CANDLE (third variety)
		*	LIGHT_STYLE(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");	
		*	// 9 SLOW STROBE (fourth variety)
		*	LIGHT_STYLE(9, "aaaaaaaazzzzzzzz");	
		*	// 10 FLUORESCENT FLICKER
		*	LIGHT_STYLE(10, "mmamammmmammamamaaamammma");
		*	// 11 SLOW PULSE NOT FADE TO BLACK
		*	LIGHT_STYLE(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");	
		*	// 12 UNDERWATER LIGHT MUTATION
		*	// this light only distorts the lightmap - no contribution
		*	// is made to the brightness of affected surfaces
		*	LIGHT_STYLE(12, "mmnnmmnnnmmnn");
		*	// styles 32-62 are assigned by the light program for switchable lights
		*	// 63 testing
		*	LIGHT_STYLE(63, "a");
		*	Structure:
		*	byte	index
		*	string	lightinfo
		**/
)" },
			{ .Name = "UpdateUserInfo", .Id = 13, .Info = R"(
		/**
		*	@brief Contains information about a particular client. See following posts for more details : https://forums.alliedmods.net/showthread.php?p=1995516#post1995516
		*	Note: This message is sent at a number of times:
		*	Note:  - at the moment of client activation (during the connection);
		*	Note:  - at the moment of disconnection with ClientUserInfo set to "";
		*	Note:  - using "fullupdate" command or having impulse #204 set in incoming move packets;
		*	Note:  - if the userinfo was changed, but only once per second for a single client.
		*	Structure:
		*	byte	ClientIndex
		*	long	ClientUserID
		*	string	ClientUserInfo
		*	16 bytes	ClientCDKeyHash
		**/
)" },
			{ .Name = "DeltaDescription", .Id = 14, .Info = R"(
		/**
		*	@brief Synchronizes client delta descriptions with server ones.
		*	Note: The descriptions are parsed from "delta.lst" once on server startup.
		*	Note: Fields are delta-compressed too using the meta delta definition, which is identical both on the client and the server.
		*	Note: This message has some of its arguments in bit-packed form.
		*	Structure:
		*	string	Name
		*	16 bits	NumFields
		*	n bits	Fields (delta-compressed)
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "ClientData", .Id = 15, .Info = R"(
		/**
		*	@brief Contains information about the client state at the time of last server frame.
		*	Weapon data is also sent if the client is predicting weapon state changes.
		*	Note: DeltaUpdateMask determines the frame which should be taken as a source for delta compression.
		*	Note: The length of WeaponIndex field is 5 on some outdated engines where MAX_WEAPON_DATA is set to 32.
		*	Note: If HasDelta is set to 0, DeltaUpdateMask should not be sent, and the client will not inherit previous data from any frame.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	1 bit	HasDelta
		*	8 bits	DeltaUpdateMask
		*	n bits	ClientData (delta-compressed clientdata_t)
		*	1 bit	HasWeaponData
		*	6 bits	WeaponIndex
		*	n bits	WeaponData (delta-compressed weapon_data_t)
		*	...	more weapon data if needed
		*	1 bit	0 (signifies the end of weapon data)
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "StopSound", .Id = 16, .Info = R"(
		/**
		*	@brief Stops an ambient sound.
		*	Structure:
		*	short	EntityIndex
		**/
)" },
			{ .Name = "Pings", .Id = 17, .Info = R"(
		/**
		*	@brief Contains ping and loss values for a number of players.
		*	Note: Current server builds send this message every once in a frame, resulting in lots of unnecessary network overhead. This happens due to a bug in SV_ShouldUpdatePing routine; it can be observed by typing cl_messages in the console after some time playing on a server.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	1 bit	1
		*	5 bits	PlayerID
		*	12 bits	Ping
		*	7 bits	Loss
		*	...	repeat for as many players as needed
		*	1 bit	0
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "Particle", .Id = 18, .Info = R"(
		/**
		*	@brief Shows a particle effect.
		*	Note: Called from pfnParticleEffect. So, the same as EngFunc_ParticleEffect.
		*	Note: The direction has to be a value between -128 to 127, after the scale operation.
		*	Note: You don't need to scaled by 16 if you use the engine call.
		*	Note: Color is an index from the palette attached at right.
		*	Standard Quake1 palette
		*	Structure:
		*	coord	OriginX
		*	coord	OriginY
		*	coord	OriginZ
		*	char	DirectionX 		*	 16
		*	char	DirectionY 		*	 16
		*	char	DirectionZ 		*	 16
		*	byte	Count
		*	byte	Color
		**/
)" },
			{ .Name = "Damage", .Id = 19, .Info = R"(
		/**
		*	@brief Note: Deprecated.
		**/
)" },
			{ .Name = "SpawnStatic", .Id = 20, .Info = R"(
		/**
		*	@brief Marks an entity as "static", so that it can be freed from server memory.
		*	Note: RenderAmt, RenderColor and RenderFX are sent only if RenderMode does not equal to 0.
		*	Note: ColorMap and Skin fields are deprecated; they can be set to 0.
		*	Structure:
		*	short	ModelIndex
		*	byte	Sequence
		*	byte	Frame
		*	short	ColorMap
		*	byte	Skin
		*	coord	OriginX
		*	angle	AngleX
		*	coord	OriginY
		*	angle	AngleY
		*	coord	OriginZ
		*	angle	AngleZ
		*	byte	RenderMode
		*	] byte	RenderAmt
		*	] byte	RenderColorR
		*	] byte	RenderColorG
		*	] byte	RenderColorB
		*	] byte	RenderFX
		**/
)" },
			{ .Name = "EventReliable", .Id = 21, .Info = R"(
		/**
		*	@brief This message is simular to SVC_EVENT, but no queuing takes place, and the message can only hold one event.
		*	Note: All events with FEV_RELIABLE flag set would be sent this way.
		*	Note: The message would be fragmented and sent separately if it overflows the client network channel.
		*	Note: EventArgs are always inherited from "null" event args.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	10 bits	EventIndex
		*	n bits	EventArgs (delta-compressed event_args_t)
		*	1 bit	HasFireTime
		*	] 16 bits	FireTime
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "SpawnBaseline", .Id = 22, .Info = R"(
		/**
		*	@brief Creates a baseline for future referencing.
		*	Note: This message can hold more than one baseline.
		*	Note: Delta-compressed fields are inherited from a "null" value.
		*	Note: Engine baselines are sent first; they are formed from all eligible entities at the moment of map startup.
		*	Note: GameDLL baselines are sent after engine ones. They are formed at the same time, but a game library can manually define them in CreateInstancedBaseline calls.
		*	Note: There is no limit how many baselines can be sent. However, only 63 game baselines can be created by a game library, and NumInstanced can only hold 6 bits.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	] 11 bits	EntityIndex
		*	] 2 bits	EntityType
		*	] n bits	EntityState (delta-compressed)
		*	] ...	repeat for every eligible entity
		*	16 bits	65535
		*	6 bits	NumInstanced
		*	] n bits	EntityState (delta-compressed)
		*	] ...	repeat for all instanced baselines
		**/
)" },
			{ .Name = "TempEntity", .Id = 23, .Info = R"(
		/**
		*	@brief Creates a temp entity.
		*	Structure:
		*	byte	MessageIndex
		*	...	...
		**/
)" },
			{ .Name = "SetPause", .Id = 24, .Info = R"(
		/**
		*	@brief Puts client to a pause.
		*	Note: If server is not paused, commands and packets from client are still sent, that means that client still can shoot/buy/etc...
		*	Note: IsPaused: 1 - for pause, 0 - for unpause.
		*	Structure:
		*	byte	IsPaused
		**/
)" },
			{ .Name = "SignOnNum", .Id = 25 , .Info = R"(
		/**
		*	@brief Called just after client_putinserver. Signals the client that the server has marked it as "active".
		*	Structure:
		*	byte	1
		**/
)" },
			{ .Name = "CenterPrint", .Id = 26, .Info = R"(
		/**
		*	@brief Sends a centered message.
		*	Note: Called from pfnClientPrintf with print_center as type.
		*	Structure:
		*	string	Message
		**/
)" },
			{ .Name = "KilledMonster", .Id = 27, .Info = R"(
		/**
		*	@brief Note: Deprecated.
		**/
)" },
			{ .Name = "FoundSecret", .Id = 28, .Info = R"(
		/**
		*	@brief Note: Deprecated.
		*	Structure:
		**/
)" },
			{ .Name = "SpawnStaticSound", .Id = 29, .Info = R"(
		/**
		*	@brief Start playback of a sound, loaded into the static portion of the channel array.
		*	This should be used for looping ambient sounds, looping sounds that should not non-creature sentences, and one-shot ambient streaming sounds.
		*	It can also play 'regular' sounds one-shot, in case designers want to trigger regular game sounds.
		*	The sound can be spawned either from a fixed position or from an entity.
		*	Note: To use it on a fixed position, provide a valid origin and set EntityIndex with 0.
		*	Note: To use it from an entity, so position is updated, provide a valid EntityIndex and set Origin with a null vector.
		*	Note: To stop a sound with SVC_STOPSOUND, a valid EntityIndex is needed.
		*	Note: Volume has to be scaled by 255 and Attenuation by 64.
		*	Note: Use SND_SENTENCE (1<<4) as flag for sentence sounds.
		*	Note: It can be sent to one player.
		*	Structure:
		*	coord	OriginX
		*	coord	OriginY
		*	coord	OriginZ
		*	short	SoundIndex
		*	byte	Volume 		*	 255
		*	byte	Attenuation 		*	 64
		*	short	EntityIndex
		*	byte	Pitch
		*	byte	Flags
		**/
)" },
			{ .Name = "Intermission", .Id = 30, .Info = R"(
		/**
		*	@brief Shows the intermission camera view
		*	Note: Intermission mode 1.
		**/
)" },
			{ .Name = "Finale", .Id = 31, .Info = R"(
		/**
		*	@brief Shows the intermission camera view, and writes-out text passed in first parameter.
		*	Note: Intermission mode 2.
		*	Note: This text will keep showing on clients in future intermissions.
		*	Structure:
		*	string	Text
		**/
)" },
			{ .Name = "CdTrack", .Id = 32, .Info = R"(
		/**
		*	@brief Plays a Half-Life music.
		*	Note: Track number goes from 1 to 30.
		*	Note: The music files are located in valve/media/.
		*	Note: The LoopTrack param is unused but required.
		*	Structure:
		*	byte	Track
		*	byte	LoopTrack
		**/
)" },
			{ .Name = "Restore", .Id = 33, .Info = R"(
		/**
		*	@brief Maintains a global transition table for the saved game.
		*	Note: Sent only if a save file is being played, and a new client connects to the server.
		*	Note: HLTV clients can't connect to a saved game, and subsequently they can't receive this message.
		*	Note: SaveName is formatted like: "SAVE/(map name).HL2".
		*	Structure:
		*	string	SaveName
		*	byte	MapCount
		*	string	MapName
		*	...	repeat for MapCount times
		**/
)" },
			{ .Name = "CutScene", .Id = 34, .Info = R"(
		/**
		*	@brief Shows the intermission camera view, and writes-out text passed in first parameter.
		*	Note: Intermission mode 3.
		*	Note: This text will keep showing on clients in future intermissions.
		*	Structure:	
		*	string	Text
		**/
)" },
			{ .Name = "WeaponAnim", .Id = 35, .Info = R"(
		/**
		*	@brief Plays a weapon sequence.
		*	Structure:
		*	byte	SequenceNumber
		*	byte	WeaponmodelBodygroup
		**/
)" },
			{ .Name = "DecalName", .Id = 36, .Info = R"(
		/**
		*	@brief Allows to set, into the client's decals array and at specific position index (0->511), a decal name.
		*	E.g: let's say you send a message to set a decal "{break" at index 200.
		*	As result, when a message TE_ will be used to show a decal at index 200, we will see "{break".
		*	Note: If there is already an existing decal at the provided index, it will be overwritten.
		*	Note: It appears we can play only with decals from decals.wad.
		*	Structure:
		*	byte	PositionIndex
		*	string	DecalName
		**/
)" },
			{ .Name = "RoomType", .Id = 37, .Info = R"(
		/**
		*	@brief Sets client room_type cvar to provided value.
		*	0 = Normal (off)
		*	1 = Generic
		*	2 = Metal Small
		*	3 = Metal Medium
		*	4 = Metal Large
		*	5 = Tunnel Small
		*	6 = Tunnel Medium
		*	7 = Tunnel Large
		*	8 = Chamber Small
		*	9 = Chamber Medium
		*	10 = Chamber Large
		*	11 = Bright Small
		*	12 = Bright Medium
		*	13 = Bright Large
		*	14 = Water 1
		*	15 = Water 2
		*	16 = Water 3
		*	17 = Concrete Small
		*	18 = Concrete Medium
		*	19 = Concrete Large
		*	20 = Big 1
		*	21 = Big 2
		*	22 = Big 3
		*	23 = Cavern Small
		*	24 = Cavern Medium
		*	25 = Cavern Large
		*	26 = Weirdo 1
		*	27 = Weirdo 2
		*	28 = Weirdo 3
		*	Structure:
		*	short	Value
		**/
)" },
			{ .Name = "AddAngle", .Id = 38, .Bytes = 2, .Info = R"(
		/**
		*	@brief Add an angle on the yaw axis of the current client's view angle.
		*	Note: When pev->fixangle is set to 2, this message is called with pev->avelocity[1] as a value.
		*	Note: The value needs to be scaled by (65536 / 360).
		*	Structure:
		*	short	AngleToAdd
		**/
)" },
			{ .Name = "NewUserMsg", .Id = 39, .Info = R"(
		/**
		*	@brief Registers a new user message on the client.
		*	Note: Sent every time a new message is registered on the server, but most games do this only once on the map change or server startup.
		*	Note: Name can be represented as an array of 4 "longs".
		*	Structure:
		*	byte	Index
		*	byte	Size
		*	16 bits	Name
		**/
)" },
			{ .Name = "PacketEntities", .Id = 40, .Info = R"(
		/**
		*	@brief Contains information about the entity states, like origin, angles and such.
		*	This message is the same as SVC_DELTAPACKETENTITIES, only with UpdateMask field omitted.
		*	Note: The delta compression still takes place, albeit from a "null" state.
		*	Note: This message has some of its arguments in bit-packed form.
		*	Structure:
		*	short	NumberOfEntities
		*	...	see SVC_DELTAPACKETENTITIES
		*	16 bits	0
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "DeltaPacketEntities", .Id = 41, .Info = R"(
		/**
		*	@brief Contains information about the entity states, like origin, angles and such.
		*	This is the basic means of sending entity updates to the client.
		*	Note: UpdateMask determines the frame which should be taken as a source for delta compression.
		*	Note: Each entity can inherit itself in a number of ways:
		*	Note:  - from a "null" state (no delta);
		*	Note:  - from a previous entity in the message;
		*	Note:  - from a "best" calculated baseline;
		*	Note:  - from an instanced baseline set by the game library.
		*	Note: NoDelta means there would be no delta information following the header.
		*	Note: Entity index can be short (6 bits) or long (11 bits). The short index is basically a difference between current and previous index.
		*	Note: If difference is 1, no index would be sent.
		*	Note: Compression is done using one of three encoders: entity_state_t, entity_state_player_t and custom_entity_state_t.
		*	Note: "Best" baseline is a baseline with the least amount of fields that were changed, and as such, the lesser network traffic.
		*	Note: This message has some of its arguments in bit-packed form.
		*	Structure:
		*	short	NumberOfEntities
		*	byte	UpdateMask
		*	1 bit	NoDelta
		*	1 bit	HasIndexDiff
		*	] 6 bits	EntIndexDiff
		*	] or	
		*	] 11 bits	EntIndex
		*	1 bit	CustomDelta
		*	1 bit	HasInstancedBaseline
		*	] 6 bits	InstancedIndex
		*	1 bit	HasBestBaseline
		*	] 6 bits	BestIndex
		*	n bits	EntityState (delta-compressed)
		*	...	repeat for any entities need to be updated
		*	16 bits	0
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "Choke", .Id = 42, .Info = R"(
		/**
		*	@brief Notify the client that some outgoing datagrams were not transmitted due to exceeding bandwidth rate limits.
		**/
)" },
			{ .Name = "ResourceList", .Id = 43, .Info = R"(
		/**
		*	@brief This message contains all the resources provided by the server for clients to download. Consistency info can also be included.
		*	Note: MD5Hash is sent only if Flags has the RES_CUSTOM (4) bit set.
		*	Note: Outgoing Flags field can only include RES_FATALIFMISSING and RES_WASMISSING.
		*	Note: If ExtraInfo is empty, it is not sent, and HasExtraInfo must be equal to 0.
		*	Note: Otherwise, ExtraInfo can include a FORCE_TYPE variable and allowed min/max size for models.
		*	Note: Consistency info is not sent in any of these cases:
		*	Note:  - mp_consistency is set to 0;
		*	Note:  - the current game mode is singleplayer, or it is a listen server;
		*	Note:  - there were no calls to ForceUnmodified before sending the resource list;
		*	Note:  - the receiving client is a HLTV proxy.
		*	Note: Every resource with RES_CHECKFILE would be included in consistency list.
		*	Note: The consistency index can be short or long. Short index is a difference between current and last index.
		*	Note: This message has its arguments in bit-packed form.
		*	Structure:
		*	12 bits	NumResources
		*	4 bits	Type
		*	n bits	Name
		*	12 bits	Index
		*	24 bits	DownloadSize
		*	3 bits	Flags
		*	128 bits	MD5Hash
		*	1 bit	HasExtraInfo
		*	] 256 bits	ExtraInfo
		*	...	repeat for NumResources
		*	1 bit	HasConsistency
		*	] 1 bit	1
		*	] 1 bit	IsShortIndex
		*	] 5 bits	Index
		*	] or	
		*	] 10 bits	Index
		*	] ...	repeat for all resources with RES_CHECKFILE flag set
		*	] 1 bit	0
		*	n bits	alignment to byte boundary
		**/
)" },
			{ .Name = "NewMoveVars", .Id = 44, .Info = R"(
		/**
		*	@brief Updates client's movevars.
		*	Note: This message is sent on client's connect and when any change is detected between the current server movevars and server cvars values.
		*	Note: If there is a change, the value of server cvars are copied into the server movevars, then the message is sent to all players using the server movevars.
		*	Structure:
		*	float	Gravity
		*	float	StopSpeed
		*	float	MaxSpeed
		*	float	SpectatorMaxSpeed
		*	float	Accelerate
		*	float	AirAccelerate
		*	float	WaterAccelerate
		*	float	Friction
		*	float	EdgeFriction
		*	float	WaterFriction
		*	float	EntGravity
		*	float	Bounce
		*	float	StepSize
		*	float	MaxVelocity
		*	float	ZMax
		*	float	WaveHeigth
		*	byte	Footsteps
		*	float	RollAngle
		*	float	RollSpeed
		*	float	SkyColorRed
		*	float	SkyColorGreen
		*	float	SkyColorBlue
		*	float	SkyVecX
		*	float	SkyVecY
		*	float	SkyVecZ
		*	string	SkyName
		**/
)" },
			{ .Name = "ResourceRequest", .Id = 45, .Info = R"(
		/**
		*	@brief Allows the client to send its own resource list (CLC_RESOURCELIST).
		*	Structure:
		*	long	SpawnCount
		*	long	0
		**/
)" },
			{ .Name = "Customization", .Id = 46, .Info = R"(
		/**
		*	@brief Notifies the client that a new customization is avaliable for download.
		*	Note: Sent for all active clients every time a new player finishes uploading its custom resources.
		*	Note: Also sent for this very client a number of times with information about the customizations of all other clients currently on the server.
		*	Note: MD5Hash is sent only if Flags has the RES_CUSTOM (4) bit set.
		*	Structure:
		*	byte	PlayerIndex
		*	byte	Type
		*	string	Name
		*	short	Index
		*	long	DownloadSize
		*	byte	Flags
		*	16 bytes	MD5Hash
		**/
)" },
			{ .Name = "CrosshairAngle", .Id = 47, .Info = R"(
		/**
		*	@brief Adjusts the weapon's crosshair angle.
		*	Basically, the weapon position on the player's view can have a different origin.
		*	Note: Called by pfnCrosshairAngle. So, the same as EngFunc_CrosshairAngle.
		*	Note: If you use the engine call, no need to scale by 5.
		*	Note: Use 0 for both to get the default position.
		*	Structure:
		*	char	PitchAngle 		*	 5
		*	char	YawAngle 		*	 5
		**/
)" },
			{ .Name = "SoundFade", .Id = 48, .Info = R"(
		/**
		*	@brief Updates client side sound fade.
		*	It's used to modulate sound volume on the client.
		*	Such functionality is part of a main function where the purpose would be to update sound subsystem and cd audio.
		*	Note: EngFunc_FadeClientVolume sends that message to client.
		*	Structure:
		*	byte	InitialPercent
		*	byte	HoldTime
		*	byte	FadeOutTime
		*	byte	FadeInTime
		**/
)" },
			{ .Name = "FileTxferFailed", .Id = 49, .Info = R"(
		/**
		*	@brief Sends a message to the client's console telling what file has failed to be transfered.
		*	Note: The message type is : "Error: server failed to transmit file 'FileName'""
		*	Structure:
		*	string	FileName
		**/
)" },
			{ .Name = "Hltv", .Id = 50, .Info = R"(
		/**
		*	@brief Tells client about current spectator mode.
		*	As found in hltv.h:
		*	#define HLTV_ACTIVE	0	// tells client that he's an spectator and will get director commands
		*	#define HLTV_STATUS	1	// send status infos about proxy 
		*	#define HLTV_LISTEN	2	// tell client to listen to a multicast stream
		*	Structure:
		*	byte	Mode
		**/
)" },
			{ .Name = "Director", .Id = 51 },
			{ .Name = "VoiceInit", .Id = 52, .Info = R"(
		/**
		*	@brief Sends sv_voicecodec and sv_voicequality cvars to client.
		*	Note: Codec name either voice_miles or voice_speex.
		*	Note: Quality 1 to 5.
		*	Structure:
		*	string	CodecName
		*	byte	Quality
		**/
)" },
			{ .Name = "VoiceData", .Id = 53, .Info = R"(
		/**
		*	@brief Contains compressed voice data.
		*	Note: Size can be no higher than 4096.
		*	Structure:
		*	byte	PlayerIndex
		*	short	Size
		*	"Size" bytes	Data
		**/
)" },
			{ .Name = "SendExtraInfo", .Id = 54, .Info = R"(
		/**
		*	@brief Sends some extra information regarding the server.
		*	Note: This message is sent at player's connection right after SVC_SERVERINFO.
		*	Note: The sv_cheats cvar will be set on the client with the value provided.
		*	Note: It appears FallbackDir is always null.
		*	Structure:
		*	string	FallbackDir
		*	byte	CanCheat
		**/
)" },
			{ .Name = "TimeScale", .Id = 55, .Info = R"(
		/**
		*	Structure:
		*	float	TimeScale
		**/
)" },
			{ .Name = "ResourceLocation", .Id = 56, .Info = R"(
		/**
		*	@brief This message sends sv_downloadurl to client.
		*	Structure:
		*	string	sv_downloadurl
		**/
)" },
			{ .Name = "SendCvarValue", .Id = 57, .Info = R"(
		/**
		*	@brief Request a cvar value from a connected client.
		*	Note: This message is considered obsolete, since it provides no option to differentiate between various cvar queries.
		*	Note: After the client has successfully responded, the server calls pfnCvarValue function in the game library.
		*	Structure:
		*	string	Name
		**/
)" },
			{ .Name = "SendCvarValue2", .Id = 58, .Info = R"(
		/**
		*	@brief Request a cvar value from a connected client.
		*	Note: RequestID is provided to be able to distinguish cvar queries between each other.
		*	Note: After the client has successfully responded, the server calls pfnCvarValue2 function in the game library.
		*	Structure:
		*	long	RequestID
		*	string	Name
		**/
)" },
		// Information for these above has been taken from https://wiki.alliedmods.net/Half-Life_1_Engine_Messages

			{ .Name = "CurWeapon", .Bytes = 3 },
			{ .Name = "Geiger", .Bytes = 1 },
			{ .Name = "Flashlight", .Bytes = 2 },
			{ .Name = "FlashBat", .Bytes = 1 },
			{ .Name = "Health", .Bytes = 1 },
			{ .Name = "Damage", .Bytes = 12 },
			{ .Name = "Battery", .Bytes = 2 },
			{ .Name = "Train", .Bytes = 1 },
			{ .Name = "HudText", .Bytes = -1 },
			{ .Name = "SayText", .Bytes = -1 },
			{ .Name = "TextMsg", .Bytes = -1 },
			{ .Name = "WeaponList", .Bytes = -1 },
			{ .Name = "ResetHUD", .Bytes = 1, .Info = R"(
		/**
		*	@brief called every respawn
		**/
)" },
			{ .Name = "InitHUD", .Bytes = 0, .Info = R"(
		/**
		*	@brief called every time a new player joins the server
		**/
)" },
			{ .Name = "GameTitle", .Bytes = 1 },
			{ .Name = "DeathMsg", .Bytes = -1 },
			{ .Name = "ScoreInfo", .Bytes = 9 },
			{ .Name = "TeamInfo", .Bytes = -1, .Info = R"(
		/**
		*	@brief sets the name of a player's team
		**/
)" },
			{ .Name = "TeamScore", .Bytes = -1, .Info = R"(
		/**
		*	@brief sets the score of a team on the scoreboard
		**/
)" },
			{ .Name = "GameMode", .Bytes = 1 },
			{ .Name = "MOTD", .Bytes = -1 },
			{ .Name = "ServerName", .Bytes = -1 },
			{ .Name = "AmmoPickup", .Bytes = 2 },
			{ .Name = "WeapPickup", .Bytes = 1 },
			{ .Name = "ItemPickup", .Bytes = -1 },
			{ .Name = "HideWeapon", .Bytes = 1 },
			{ .Name = "SetFOV", .Bytes = 1 },
			{ .Name = "ShowMenu", .Bytes = -1 },
			{ .Name = "AmmoX", .Bytes = 2 },
			{ .Name = "TeamNames", .Bytes = -1 },
			{ .Name = "StatusText", .Bytes = -1 },
			{ .Name = "StatusValue", .Bytes = 3 }
		};

	public:

		MessageData* GetMessageData( const std::string& name );
		MessageData* GetMessageData( int id );

		void Initialize( const asIScriptEngine* engine );

		void Register( const char* name, int bytes, int id );
};

inline CNetworkMessageAPI g_NetworkMessageAPI;
