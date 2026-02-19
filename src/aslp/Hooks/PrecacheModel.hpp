#include "mandatory.h"

#pragma once

#include "../misc/FixUnprecachedCrash.hpp"

namespace Hooks
{
    inline int PrecacheModel( char* model )
    {
        // Do not precache too late. get an error model/sprite instead.
        if( int index = FixUnprecachedCrash::PrecacheModel( model ); index != -1 )
        {
            RETURN_META_VALUE( MRES_SUPERCEDE, index );
        }

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
