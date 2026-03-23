#include "mandatory.h"

#pragma once

#if AS_GENERATE_DOCUMENTATION
#include "misc/GenerateASPredefined.hpp"
#endif

namespace Hooks
{
    namespace Post
    {
        inline void StartFrame()
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

#if AS_GENERATE_DOCUMENTATION
            GenerateASPredefined::StartFrame();
#endif

            SET_META_RESULT(meta_result);
        }
    }
}
