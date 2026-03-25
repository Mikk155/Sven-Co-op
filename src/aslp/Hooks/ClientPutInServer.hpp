#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Post
    {
        inline void ClientPutInServer( edict_t* entity )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            SET_META_RESULT(meta_result);
        }
    }
}
