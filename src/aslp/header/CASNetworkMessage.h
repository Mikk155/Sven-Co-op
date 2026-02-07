#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include "CASBaseObject.h"

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
        Byte,
        Char,
        Short,
        Long,
        Angle,
        Coord,
        String,
        Entity
    };

    class ByteData : public CASBaseGCObject
    {
        #define WriteType( type, var ) ByteData* Write##type( ##var value ) { m_Value = value; return this; }
        #define ReadType( type, var ) bool Read##type( ##var & value ) { \
            if( const auto* pval = std::get_if<##var>(&m_Value) ) { \
                value = *pval; return true; } return false; }

        public:
            ByteData( ByteType type ) const {
                m_Type = type;
            }

        private:
            ByteType m_Type;
        public:
            ByteType GetType() {
                return m_Type;
            }

        private:
            std::variant<int, float, CString> m_Value;

        public:

            ReadType(Byte, int)
            ReadType(Char, int)
            ReadType(Short, int)
            ReadType(Long, int)
            ReadType(Angle, float)
            ReadType(Coord, float)
            ReadType(String, CString)
            ReadType(Entity, int)

            WriteType(Byte, int)
            WriteType(Char, int)
            WriteType(Short, int)
            WriteType(Long, int)
            WriteType(Angle, float)
            WriteType(Coord, float)
            WriteType(String, const CString&)
            WriteType(Entity, int)
    };

    class CASNetworkMessage : public CASBaseGCObject
    {
        public:

            // Target clients
            Destination Target;

            // String name in the client side.
            CString Name;

            // Number of bytes sent.
            int Bytes;

            // ID in the server side.
            int Id;

            // Bytes sent (Arguments)
            CScriptArray* Arguments;

            void AddArgument( ByteData* argument );

        private:

            asIScriptEngine* m_ASEngine;

            asITypeInfo* m_ArrayInfo;
            asIScriptFunction* m_ArrayinsertLast;
    };
};
