#include "mandatory.h"

#pragma once

#include "utils/StringPool.hpp"

#include "../misc/FixModelIndexGMR.hpp"
#include "../misc/FixUnprecachedCrash.hpp"

namespace Hooks
{
    namespace Post
    {
        inline void ServerDeactivate()
        {
            g_StringPool.Clear();
            FixModelIndexGMR::GMR.clear();
            FixUnprecachedCrash::g_PrecachedModels.clear();
            g_MapInitialized = false;
        }
    }
}
