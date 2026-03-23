#include "mandatory.h"

#pragma once

inline void CASPM_ContainerSizeSet( int* psize, int count, int newsize )
{
    if( newsize < 0 || newsize >= count )
    {
        return;
    }

    *psize = newsize;
}

template<typename T>
inline T* CASPM_ContainerGet( T* list, int count, int index )
{
    if( index < 0 || index >= count )
    {
        return nullptr;
    }

    return &list[ index ];
}

template<typename T>
inline void CASPM_ContainerSet( T* list, int count, int index, const T* value )
{
    if( index < 0 || index >= count )
    {
        return;
    }

    if( !value )
    {
        return;
    }

    list[ index ] = *value;
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
