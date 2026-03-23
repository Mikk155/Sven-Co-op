#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Post
    {
        inline void ClientPutInServer( edict_t* entity )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( entity != nullptr && entity->pvPrivateData )
            {
#if AS_GENERATE_DOCUMENTATION
                static bool bDocsGenerated = false;
                if( !bDocsGenerated )
                {
                    bDocsGenerated = true;
                    MESSAGE_BEGIN( MSG_ONE, 9, nullptr, entity );
                        WRITE_STRING( "as_dumphooks hooks;wait;condebug;wait;[as_scriptbaseclasses];wait;as_scriptbaseclasses;wait;condebug;wait;generate_as_documentation" );
                    MESSAGE_END();
                }
#endif
            }

            SET_META_RESULT(meta_result);
        }
    }
}
