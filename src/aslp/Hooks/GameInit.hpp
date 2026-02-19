#include "mandatory.h"

#pragma once

#include "../misc/FixUnprecachedCrash.hpp"

namespace Hooks
{
    namespace Post
    {
        inline void GameInit()
        {
            CVAR_REGISTER( &FixUnprecachedCrash::g_FixUnprecachedCrash );

            SET_META_RESULT( META_RES::MRES_IGNORED );
        }
    }
}
