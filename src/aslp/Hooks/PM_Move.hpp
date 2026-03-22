#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Pre
    {
        inline void PM_Move( playermove_t* pmove, int server )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( pmove != nullptr )
            {
                CALL_ANGELSCRIPT( pPreMovement, &pmove, &meta_result );
            }

            SET_META_RESULT(meta_result);
        }
    }

    namespace Post
    {
        inline void PM_Move( playermove_t* pmove, int server )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( pmove != nullptr )
            {
                CALL_ANGELSCRIPT( pPostMovement, &pmove, &meta_result );
            }

            SET_META_RESULT(meta_result);
        }
    }
}
