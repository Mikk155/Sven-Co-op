#include <meta_api.h>
#include <extdll.h>

#pragma once

#include <optional>
#include <unordered_set>

#include <fmt/format.h>

#include "../utils/StringPool.hpp"
#include "../utils/StringViewComparePointer.h"
#include "../utils/GetErrorAsset.h"

namespace FixUnprecachedCrash
{
    inline std::unordered_set<const char*, StringViewComparePointer::Hash, StringViewComparePointer::Equal> g_PrecachedModels;

    inline bool IsPrecached( const char* asset )
    {
        return ( g_PrecachedModels.find( asset ) != FixUnprecachedCrash::g_PrecachedModels.end() );
    }

    inline std::optional<int> PrecacheModel( char* model )
    {
        // We don't care about brush models.
        if( model[0] == '*' )
            return std::nullopt;

        // We're fine to precache right now.
        if( !g_MapInitialized )
        {
            // Push this model if is not registered.
            if( auto pModel = g_StringPool.Get( model ); !IsPrecached( pModel ) )
                g_PrecachedModels.emplace( pModel );

            return std::nullopt;
        }

        // This model is been precached before. is safe to let the engine handle it.
        if( IsPrecached( model ) )
            return std::nullopt;

        const char* errorAsset = GetErrorAsset( model );

        ALERT( at_console, fmt::format( "Too late to precache model \"{}\" swaping for error\n", model ).c_str() );

        return MODEL_INDEX( errorAsset );
    }

    inline bool g_SettingUpModel = false;

    inline bool SetModel( edict_t* entity, const char* model )
    {
        // We don't care about brush models.
        if( model[0] == '*' )
            return false;

        if( g_SettingUpModel )
            return true;

        if( IsPrecached( model ) )
            return false;

        // Get the error model if this string is not been precached.
        if( entity != nullptr )
        {
            auto errorAsset = GetErrorAsset( model );
            g_SettingUpModel = true;
            entity->v.model = MAKE_STRING( errorAsset );
            SET_MODEL( entity, (char*)errorAsset );
            g_SettingUpModel = false;
        }

        return true;
    }
}
