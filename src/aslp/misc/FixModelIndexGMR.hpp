#include <meta_api.h>

#pragma once

#include <unordered_map>
#include <string>
#include <string_view>
#include <optional>
#include <fmt/format.h>

#include "../utils/StringPool.hpp"

namespace FixModelIndexGMR
{
    using namespace std::literals::string_view_literals;
    using string_view = std::string_view;

    struct TransparentHash
    {
        using is_transparent = void;
        size_t operator()( string_view sv ) const noexcept
        {
            return std::hash<string_view>{}( sv );
        }
    };

    struct TransparentEqual
    {
        using is_transparent = void;
        bool operator()( string_view a, string_view b ) const noexcept
        {
            return a == b;
        }
    };

    inline std::unordered_map<const char*, const char*, TransparentHash, TransparentEqual> GMR;

    inline std::optional<std::string_view> CFGHasReplacementList()
    {
        int filesize = 0;
        char mappath[MAX_PATH];
        sprintf_s(mappath, "maps/%s.cfg", STRING( gpGlobals->mapname ) );
        byte* membuf = g_engfuncs.pfnLoadFileForMe(mappath, &filesize);

        if( !membuf )
            return std::nullopt;

        std::string_view gmrpath;

        char* tokstarter = reinterpret_cast<char*>(membuf);
        char* next_line = strtok(tokstarter, "\n");

        while( next_line != nullptr )
        {
            if (!strncmp(next_line, "globalmodellist", 15))
            {
                next_line += 15;

                while( isspace(*next_line) || *next_line == '\"' ) {
                    next_line++;
                }

                if (*next_line == '\0') {
                    g_engfuncs.pfnFreeFile(membuf);
                    return std::nullopt;
                }

                char* end = next_line + strlen(next_line) - 1;

                while (end > next_line && (isspace(*end) || *end == '\"')) {
                    end--;
                }

                *(end + 1) = '\0';
                gmrpath = next_line;
                break;
            }
            next_line = strtok(nullptr, "\n");
        }
        g_engfuncs.pfnFreeFile(membuf);
        if (gmrpath.size() == 0)
            return std::nullopt;
        return gmrpath;
    }

    inline void LoadCFGFile( std::string_view filename )
    {
        int filesize = 0;

        byte* gmrbuf = g_engfuncs.pfnLoadFileForMe( const_cast<char*>( fmt::format( "models/{}/{}", STRING( gpGlobals->mapname ), filename ).c_str() ), &filesize );

        if( !gmrbuf )
            return;

        std::string key;
        std::string value;

        char* tokstarter = reinterpret_cast<char*>(gmrbuf);
        char* next_line = strtok(tokstarter, "\n");

        while( next_line != nullptr )
        {
            key.clear();
            value.clear();

            bool has_quote = false;
            if (*next_line == '\"') {
                next_line++;
                has_quote = true;
            }
            if (has_quote) {
                while (*next_line != '\"') {
                    key += *next_line;
                    next_line++;
                }
            }
            else {
                while (!isspace(*next_line)) {
                    key += *next_line;
                    next_line++;
                }
            }
            while (isspace(*next_line) || *next_line == '\"') {
                next_line++;
            }
            char* end = next_line + strlen(next_line) - 1;
            while (end > next_line && (isspace(*end) || *end == '\"')) {
                end--;
            }
            *(end + 1) = '\0';
            value = next_line;
            if (key.size() > 0 && value.size() > 0)
                GMR[ g_StringPool.Get( key.c_str() ) ] = g_StringPool.Get( value.c_str() );
            next_line = strtok(nullptr, "\n");
        }
        g_engfuncs.pfnFreeFile(gmrbuf);
    }
}