#include "mandatory.h"

#pragma once

#include "../NetworkMessages/generate_as_networking.h"

namespace Hooks
{
    namespace Pre
    {
        inline void ClientCommand( edict_t* entity )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( entity != nullptr && entity->pvPrivateData )
            {
                // -TODO Can we pass CMD_ARGV? pretty sure an object already exists
                CALL_ANGELSCRIPT( pCientCommandHook, entity->pvPrivateData, &meta_result );

                const char* pcmd = CMD_ARGV(0);

                if( !strncmp( pcmd, "aslp", 4 ) )
                {
                    g_NetworkMessageAPI.Initialize( ASEXT_GetServerManager()->scriptEngine );
                    meta_result = MRES_SUPERCEDE;
                }
            }

            SET_META_RESULT(meta_result);
        }
    }
}
