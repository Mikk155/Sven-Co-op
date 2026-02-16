#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Pre
    {
        inline int ShouldCollide( edict_t* pentTouched, edict_t* pentOther )
        {
            bool Collide = true;
            META_RES meta_result = META_RES::MRES_IGNORED;

            CALL_ANGELSCRIPT( pShouldCollide,
                ( pentTouched != nullptr ? pentTouched->pvPrivateData : nullptr ),
                ( pentOther != nullptr ? pentOther->pvPrivateData : nullptr ),
                &meta_result, &Collide
            );

            RETURN_META_VALUE(meta_result, Collide ? 1 : 0 );
        }
    }
}
