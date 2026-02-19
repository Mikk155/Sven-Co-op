#include "mandatory.h"

#pragma once

#include "utils/StringPool.hpp"

#include "misc/FixModelIndexGMR.hpp"

namespace Hooks
{
    namespace Post
    {
        inline void ServerDeactivate()
        {
            g_StringPool.Clear();
            FixModelIndexGMR::GMR.clear();
            g_MapInitialized = false;
        }
    }
}
