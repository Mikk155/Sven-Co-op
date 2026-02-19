#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Post
    {
        inline void GameInit()
        {
            SET_META_RESULT( META_RES::MRES_IGNORED );
        }
    }
}
