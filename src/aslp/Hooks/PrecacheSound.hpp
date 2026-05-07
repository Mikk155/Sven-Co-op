#include "mandatory.h"

#pragma once

#include "../misc/PrecacheReporter.hpp"

namespace Hooks
{
    inline int PrecacheSound( char* soundName )
    {
        PrecacheReporter::Precache( soundName, true );

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
