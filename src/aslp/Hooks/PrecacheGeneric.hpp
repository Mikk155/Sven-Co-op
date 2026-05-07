#include "mandatory.h"

#pragma once

#include "../misc/PrecacheReporter.hpp"

namespace Hooks
{
    inline int PrecacheGeneric( char* assetName )
    {
        PrecacheReporter::Precache( assetName );

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
