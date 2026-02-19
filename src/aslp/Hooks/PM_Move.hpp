#include "mandatory.h"

#pragma once

inline physent_t* SC_SERVER_DECL CASPlayerMove__GetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG int index)
{
    return &pthis->physents[index];
}

inline void SC_SERVER_DECL CASPlayerMove__SetPhysEntByIndex(playermove_t* pthis, SC_SERVER_DUMMYARG physent_t* pPhyEnt, int oldindex)
{
    pthis->physents[oldindex] = *pPhyEnt;
}

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
