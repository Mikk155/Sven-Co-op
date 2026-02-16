#include "mandatory.h"

#pragma once

#include "utils/StringPool.hpp"

#include "misc/FixModelIndexGMR.hpp"

namespace Hooks
{
    namespace Post
    {
        void ServerDeactivate()
        {
            g_StringPool.Clear();
            FixModelIndexGMR::GMR.clear();
        }
    }
}
