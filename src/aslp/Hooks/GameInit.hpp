#include "mandatory.h"

#pragma once

#include "../misc/FixUnprecachedCrash.hpp"
#include "../misc/DiscordLogs.hpp"

namespace Hooks
{
    namespace Post
    {
        inline void GameInit()
        {
            CVAR_REGISTER( &FixUnprecachedCrash::g_FixUnprecachedCrash );
            CVAR_REGISTER( &DiscordLogs::g_LogID );

            SET_META_RESULT( META_RES::MRES_IGNORED );
        }
    }
}
