#include <meta_api.h>
#include <extdll.h>

#pragma once

#include <optional>
#include <unordered_set>

#include <nlohmann/json.hpp>
#include <fmt/format.h>

#include "../utils/File.hpp"

namespace PrecacheReporter
{
    inline cvar_t g_PrecacheReporter = { const_cast<char*>( "sv_report_precache" ), const_cast<char*>( "0" ), FCVAR_SERVER };

    inline cvar_t* g_pPrecacheReporter;

    inline bool IsActive()
    {
        if( g_pPrecacheReporter == nullptr )
            g_pPrecacheReporter = CVAR_GET_POINTER( "sv_report_precache" );

        if( g_pPrecacheReporter == nullptr )
            return false;

        return ( (int)g_pPrecacheReporter->value == 1 );
    }

    auto g_PrecachedAssets = nlohmann::json::object();

    inline void Precache( char* model, bool isSound = false )
    {
        // Don't store anything else after it's too late.
        if( g_MapInitialized )
            return;

        if( IsActive() )
        {
            std::string file( model );

            if( isSound )
            {
                file = fmt::format( "sound/{}", file );
            }

            int uses = 0;

            if( g_PrecachedAssets.contains( file ) )
            {
                uses = g_PrecachedAssets[ file ].get<int>();
            }

            g_PrecachedAssets[ file ] = uses + 1;
        }
    }

    void Write()
    {
        if( IsActive() )
        {
            std::string listPath = fmt::format( "maps/{}_precache.json", STRING( gpGlobals->mapname ) );

            File file( listPath );

            std::string dump = g_PrecachedAssets.dump(4);

            file.Write( dump );

            g_PrecachedAssets.clear();
        }
    }
}
