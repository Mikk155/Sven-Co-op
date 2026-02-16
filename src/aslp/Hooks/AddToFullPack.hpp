#include "mandatory.h"

#pragma once

typedef struct addtofullpack_s{
    entity_state_s* state;
    int entityIndex;
    edict_t* entity;
    edict_t* host;
    int hostFlags;
    int playerIndex;
    bool Result;
} addtofullpack_t;

namespace Hooks
{
    namespace Pre
    {
        inline int AddToFullPack( struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( ent->pvPrivateData && host->pvPrivateData && state )
            {
                addtofullpack_t data = { state, entindex, ent, host, hostflags, player };

                CALL_ANGELSCRIPT( pPreAddToFullPack, &data, &meta_result );

                // Skip packet
                if( data.Result )
                {
                    RETURN_META_VALUE( META_RES::MRES_SUPERCEDE, 0 );
                }
            }

            RETURN_META_VALUE(meta_result, 0);
        }
    }

    namespace Post
    {
        inline int AddToFullPack( struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet )
        {
            META_RES meta_result = META_RES::MRES_IGNORED;

            if( ent->pvPrivateData && host->pvPrivateData && state )
            {
                addtofullpack_t data = { state, entindex, ent, host, hostflags, player };

                CALL_ANGELSCRIPT( pPostAddToFullPack, &data, &meta_result );

                // Skip packet
                if( data.Result )
                {
                    RETURN_META_VALUE( META_RES::MRES_SUPERCEDE, 0 );
                }
            }

            RETURN_META_VALUE(meta_result, 0);
        }
    }
}
