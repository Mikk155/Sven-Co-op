#include "mandatory.h"

#pragma once

#include "../misc/FixModelIndexGMR.hpp"
#include "../misc/FixUnprecachedCrash.hpp"

namespace Hooks
{
    inline int ModelIndex( const char* model )
    {
        // Get the error model if this string is not been precached.
        if( !FixUnprecachedCrash::IsPrecached( model ) )
        {
            RETURN_META_VALUE( MRES_SUPERCEDE, MODEL_INDEX( GetErrorAsset( model ) ) );
        }

        // Get a proper model index supporting GMR
        if( auto it = FixModelIndexGMR::GMR.find( model ); it != FixModelIndexGMR::GMR.end() )
        {
            RETURN_META_VALUE( MRES_SUPERCEDE, MODEL_INDEX( it->second ) );
        }

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
