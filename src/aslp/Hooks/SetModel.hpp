#include "mandatory.h"

#pragma once

#include "../misc/FixUnprecachedCrash.hpp"

namespace Hooks
{
    inline void SetModel( edict_t* entity, const char* model )
    {
        // Do not set unprecached models/sprite, set an error model/sprite instead.
        if( FixUnprecachedCrash::SetModel( entity, model ) )
            RETURN_META( MRES_SUPERCEDE );

        SET_META_RESULT( MRES_IGNORED );
    }
}
