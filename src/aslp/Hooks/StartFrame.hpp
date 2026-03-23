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
            if( GenerateASPredefined::g_state != nullptr && GenerateASPredefined::g_state->done )
            {
                for( const std::string& str : GenerateASPredefined::g_state->buffer )
                {
                    ALERT( at_console, str.c_str() );
                }
                GenerateASPredefined::Shutdown();
            }
#endif
            SET_META_RESULT(meta_result);
        }
    }
}
