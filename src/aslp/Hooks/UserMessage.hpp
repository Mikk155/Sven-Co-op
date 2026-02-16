#include "mandatory.h"

#pragma once

#include "../NetworkMessages/generate_as_networking.h"

namespace Hooks
{
    namespace UserMessage
    {
        inline int Register( const char* name, int bytes )
        {
            // Avoid re-call
            static bool registeringMessage = false;

            if( registeringMessage == true )
            {
                RETURN_META_VALUE( META_RES::MRES_IGNORED, 0 );
            }

            registeringMessage = true;
            int messageID = REG_USER_MSG( name, bytes );
            registeringMessage = false;

            g_NetworkMessageAPI.Register( name, bytes, messageID );

            RETURN_META_VALUE(META_RES::MRES_SUPERCEDE, messageID);
        }

        inline void Begin( int msg_dest, int msg_type, const float *pOrigin = NULL, edict_t *ed = NULL )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void End()
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Byte( int input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Char( int input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Short( int input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Long( int input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Angle( float input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Coord( float input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void String( const char* input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }

        inline void Entity( int input )
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }
    }
}
