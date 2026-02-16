#include "mandatory.h"

#include "misc/FixModelIndexGMR.hpp"

#pragma once

namespace Hooks
{
    inline int ModelIndex( const char* model )
    {
        // Get a proper model index supporting GMR
        if( auto it = FixModelIndexGMR::GMR.find( model ); it != FixModelIndexGMR::GMR.end() ) {
            RETURN_META_VALUE( MRES_SUPERCEDE, MODEL_INDEX( it->second ) );
        }

        RETURN_META_VALUE( MRES_IGNORED, 0 );
    }
}
