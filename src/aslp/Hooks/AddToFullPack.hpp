#include "mandatory.h"

#pragma once

typedef struct addtofullpack_s{
    entity_state_s* state;
    int index;
    edict_t* entity;
    edict_t* host;
    int hostFlags;
    int playerIndex;
} addtofullpack_t;

namespace Hooks
{
    #define AddToFullPackDefinition( hook ) \
    namespace hook { \
        inline int AddToFullPack( struct entity_state_s* state, int entindex, edict_t* ent, edict_t* host, int hostflags, int player, unsigned char* pSet ) \
        { \
            META_RES meta_result = META_RES::MRES_IGNORED; \
            if( ent->pvPrivateData && host->pvPrivateData && state ) \
            { \
                addtofullpack_t data = { state, entindex, ent, host, hostflags, player }; \
                CALL_ANGELSCRIPT( p##hook##AddToFullPack, &data, &meta_result ); \
            } \
            RETURN_META_VALUE( meta_result, 0 ); \
        } \
    }

    AddToFullPackDefinition(Pre)
    AddToFullPackDefinition(Post)
}
