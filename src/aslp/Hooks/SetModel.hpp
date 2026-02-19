#include "mandatory.h"

#pragma once

namespace Hooks
{
    inline void SetModel( edict_t* entity, const char* model )
    {
        SET_META_RESULT( MRES_IGNORED );
    }
}
