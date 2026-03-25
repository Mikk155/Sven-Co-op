#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Post
    {
        inline void StartFrame()
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            SET_META_RESULT(meta_result);
        }
    }
}
