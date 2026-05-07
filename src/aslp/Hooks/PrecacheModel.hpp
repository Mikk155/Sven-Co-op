#include "mandatory.h"

#pragma once

#include "../misc/FixUnprecachedCrash.hpp"
#include "../misc/PrecacheReporter.hpp"

namespace Hooks
{
    inline int PrecacheModel( char* modelName )
    {
        PrecacheReporter::Precache( modelName );

        // Do not precache too late. get an error model/sprite instead.
        if( int index = FixUnprecachedCrash::PrecacheModel( modelName ); index != -1 )
        {
            RETURN_META_VALUE( MRES_SUPERCEDE, index );
        }

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
