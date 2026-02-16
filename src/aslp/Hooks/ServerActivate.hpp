#include "mandatory.h"

#pragma once

#include "misc/FixModelIndexGMR.hpp"

extern void VTableHook();

namespace Hooks
{
    namespace Pre
    {
        inline void ServerActivate( edict_t* edictList, int edictCount, int clientMax )
        {
            if( auto gmrFile = FixModelIndexGMR::CFGHasReplacementList(); gmrFile.has_value() )
                FixModelIndexGMR::LoadCFGFile( gmrFile.value() );
        }
    }

    namespace Post
    {
        inline void ServerActivate( edict_t* edictList, int edictCount, int clientMax )
        {
            VTableHook();

            SET_META_RESULT( MRES_IGNORED );
        }
    }
}
