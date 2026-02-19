#include <string_view>

#pragma once

using namespace std::literals::string_view_literals;

namespace StringViewComparePointer
{
    struct Hash
    {
        using is_transparent = void;
        size_t operator()( std::string_view sv ) const noexcept
        {
            return std::hash<std::string_view>{}( sv );
        }
    };

    struct Equal
    {
        using is_transparent = void;
        bool operator()( std::string_view a, std::string_view b ) const noexcept
        {
            return a == b;
        }
    };
}
