#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include "CASBaseObject.h"

#include <string>
#include <vector>

#pragma once

enum class CASNetworkMessageByteType
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

class CASNetworkMessage : CASBaseGCObject
{
    public:
        // String name in the client side.
        std::string Name;

        // Number of bytes sent.
        int Bytes;

        // ID in the server side.
        int Id;

        // Byte types and ordering to sent.
        std::vector<CASNetworkMessageByteType> Data = {};
};
