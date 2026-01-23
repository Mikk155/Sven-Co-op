#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include "CASBaseObject.h"

#include <string>
#include <vector>

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
        Byte,
        Char,
        Short,
        Long,
        Angle,
        Coord,
        String,
        Entity
    };

    class ByteData
    {
        private:

            ByteType m_Type;

        public:

            ByteData( ByteType type ) {
                m_Type = type;
            }

            ByteType GetType() {
                return m_Type;
            }
    };

    class CASNetworkMessage : CASBaseGCObject
    {
        public:

            // Target clients
            Destination Target;

            // String name in the client side.
            std::string Name;

            // Number of bytes sent.
            int Bytes;

            // ID in the server side.
            int Id;

            // Byte types and ordering to sent.
            std::vector<ByteData> Data = {};
    };
};
