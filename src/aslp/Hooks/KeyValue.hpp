#include "mandatory.h"

#pragma once

#include "misc/FixModelIndexGMR.hpp"

namespace Hooks
{
    namespace Pre
    {
        void KeyValue( edict_t* ent, KeyValueData* pkvd )
        {
            if( ent != nullptr && ENTINDEX(ent) == 0 && std::strcmp( pkvd->szKeyName, "globalmodellist" ) == 0 ) {
                FixModelIndexGMR::LoadCFGFile( pkvd->szValue );
            }

            SET_META_RESULT( MRES_IGNORED );
        }
    }
}
