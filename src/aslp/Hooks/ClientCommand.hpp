#include "mandatory.h"

#pragma once

#include "../NetworkMessages/generate_as_networking.h"

#if AS_GENERATE_DOCUMENTATION
#include "misc/GenerateASPredefined.hpp"
#endif

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
                CALL_ANGELSCRIPT( pClientCommandHook, entity->pvPrivateData, &meta_result );

                const char* pcmd = CMD_ARGV(0);

                if( !strncmp( pcmd, "aslp", 4 ) )
                {
                    g_NetworkMessageAPI.Initialize( ASEXT_GetServerManager()->scriptEngine );
                    meta_result = MRES_SUPERCEDE;
                }
#if AS_GENERATE_DOCUMENTATION
                else if( !strncmp( pcmd, "generate_as_predefined", 22 ) )
                {
                    static bool ASDocGenerator = false;

                    if( !ASDocGenerator )
                    {
                        GenerateASPredefined::Start();
                        SET_META_RESULT(MRES_SUPERCEDE);
                        ASDocGenerator = true;
                    }
                }
#endif
            }

            SET_META_RESULT(meta_result);
        }
    }
}
