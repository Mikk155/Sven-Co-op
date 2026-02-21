#include "mandatory.h"

#pragma once

inline physent_t* SC_SERVER_DECL CASPlayerMove__GetPhysEntByIndex(playermove_t* pthis SC_SERVER_DUMMYARG_NOCOMMA, int index)
{
    return &pthis->physents[index];
}

inline void SC_SERVER_DECL CASPlayerMove__SetPhysEntByIndex(playermove_t* pthis SC_SERVER_DUMMYARG_NOCOMMA, physent_t* pPhyEnt, int oldindex)
{
    pthis->physents[oldindex] = *pPhyEnt;
}

inline int SC_SERVER_DECL CASPlayerMove__PlayerIndex(playermove_t* pthis SC_SERVER_DUMMYARG_NOCOMMA )
{
    return pthis->player_index + 1; // player_index starts from zero. let's not confuse scripters.
}

inline CString SC_SERVER_DECL CASPlayerMove__GetTextureName(playermove_t* pthis SC_SERVER_DUMMYARG_NOCOMMA )
{
    CString result = CString();
    result.assign( pthis->sztexturename, strlen( pthis->sztexturename ) );
    return result;
}

inline CString SC_SERVER_DECL CASPlayerMove__GetPhysEntName(physent_t* pthis SC_SERVER_DUMMYARG_NOCOMMA )
{
    CString result = CString();
    result.assign( pthis->name, strlen( pthis->name ) );
    return result;
}

inline bool SC_SERVER_DECL CASPlayerMove__PhysEntIsPlayer(physent_t* pthis SC_SERVER_DUMMYARG_NOCOMMA )
{
    return ( pthis->player == 1 );
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
