#include "mandatory.h"

#pragma once

namespace Hooks
{
    namespace Pre
    {
        inline void ClientUserInfoChanged( edict_t* pEntity, char* infobuffer )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            CALL_ANGELSCRIPT( pPlayerUserInfoChanged, ( pEntity != nullptr ? pEntity->pvPrivateData : nullptr ), infobuffer, &meta_result );

            SET_META_RESULT(meta_result);
        }
    }
}
