#include "mandatory.h"

#pragma once

namespace Hooks
{
    inline int PrecacheSound( char* soundName )
    {
        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
