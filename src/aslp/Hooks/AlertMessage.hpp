#include "mandatory.h"

#pragma once

#include "../misc/DiscordLogs.hpp"

namespace Hooks
{
    inline void AlertMessage( ALERT_TYPE atype, const char *szFmt, ... )
    {
        char buffer[2048];

        va_list ap;
        va_start(ap, szFmt);
        vsnprintf(buffer, sizeof(buffer), szFmt, ap);
        va_end(ap);

        DiscordLogs::AlertMessage( atype, buffer );

        RETURN_META(MRES_IGNORED);
    }
}
