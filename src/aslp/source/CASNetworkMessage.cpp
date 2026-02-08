#include "CASNetworkMessage.h"

const char* NetworkMessages::ByteTypeString( ByteType type )
{
    switch( type )
    {
        case ByteType::Byte:
                    return "Byte";
        case ByteType::Char:
                    return "Char";
        case ByteType::Short:
                    return "Short";
        case ByteType::Long:
                    return "Long";
        case ByteType::Angle:
                    return "Angle";
        case ByteType::Coord:
                    return "Coord";
        case ByteType::String:
                    return "String";
        case ByteType::Entity:
                    return "Entity";
        default: return "None";
    }
}

using namespace NetworkMessages;

unsigned int SC_SERVER_DECL CASNetworkMessage_Length( NetworkMessage_t* pthis SC_SERVER_DUMMYARG_NOCOMMA )
{
    return pthis->Arguments.size();
}

ByteType SC_SERVER_DECL CASNetworkMessage_TypeOf( NetworkMessage_t* pthis SC_SERVER_DUMMYARG_NOCOMMA, unsigned int index )
{
    auto size = pthis->Arguments.size();

    if( size == 0 || index >= size )
        return ByteType::None;

    return pthis->Arguments[index].first;
}

#define WriteType( type, variable ) \
NetworkMessage_s* SC_SERVER_DECL CASNetworkMessage_Write##type( NetworkMessage_t* pthis SC_SERVER_DUMMYARG_NOCOMMA, unsigned int index, ##variable value ) \
{ \
    if( pthis->Arguments.size() < index ) \
    { \
        ALERT( at_logged, "NetworkMessage::Write" #type ": Can NOT write index %i out of range!\n", index ); \
        return pthis; \
    } \
    ByteData& argument = pthis->Arguments[index]; \
    if( argument.first != ByteType::##type ) \
    { \
        ALERT( at_logged, "NetworkMessage::Write" #type ": can NOT write type of %s expected %s\n", ByteTypeString( ByteType::Byte ), ByteTypeString( argument.first ) ); \
        return pthis; \
    } \
    argument.second = value; \
    return pthis; \
}

WriteType(Byte, int)
WriteType(Char, int)
WriteType(Short, int)
WriteType(Long, int)
WriteType(Angle, float)
WriteType(Coord, float)
WriteType(String, const CString&)
WriteType(Entity, int)

#define ReadType( type, variable ) \
bool SC_SERVER_DECL CASNetworkMessage_Read##type( NetworkMessage_t* pthis SC_SERVER_DUMMYARG_NOCOMMA, unsigned int index, ##variable& value ) \
{ \
    if( pthis->Arguments.size() < index ) \
    { \
        ALERT( at_logged, "NetworkMessage::Read" #type ": Can NOT read index %i out of range!\n", index ); \
    } \
    else \
    { \
        ByteData& argument = pthis->Arguments[index]; \
        if( argument.first == ByteType::Byte ) \
        { \
            if( const auto pval = std::get_if<##variable>( &argument.second ) ) \
            { \
                value = *pval; \
                return true; \
            } \
        } \
    } \
    return false; \
}

ReadType(Byte, int)
ReadType(Char, int)
ReadType(Short, int)
ReadType(Long, int)
ReadType(Angle, float)
ReadType(Coord, float)
ReadType(String, CString)
ReadType(Entity, int)
