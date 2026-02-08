#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include <string>
#include <vector>
#include <variant>

#pragma once

namespace NetworkMessages
{
    enum Destination
    {
        ReliableToAll = MSG_ALL,
        UnreliableToAll = MSG_BROADCAST,
        ReliableToTarget = MSG_ONE,
        UnreliableToTarget = MSG_ONE_UNRELIABLE,
        InitString = MSG_INIT,
        UnreliableToPVS = MSG_PVS,
        UnreliableToPAS = MSG_PAS,
        ReliableToPVS = MSG_PVS_R,
        ReliableToPAS = MSG_PAS_R,
        Spectators = MSG_SPEC
    };

    enum ByteType
    {
        None,
        Byte,
        Char,
        Short,
        Long,
        Angle,
        Coord,
        String,
        Entity
    };

    const char* ByteTypeString( ByteType type );

    typedef std::pair<ByteType, std::variant<int, float, CString>> ByteData;

    typedef struct NetworkMessage_s
    {
        int Id;
        int Bytes;
        CString Name;
        Destination Target;
        std::vector<ByteData> Arguments = {};
    } NetworkMessage_t;
};
