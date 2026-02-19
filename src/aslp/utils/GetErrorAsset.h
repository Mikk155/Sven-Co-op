#include <string_view>

#pragma once

inline const char* GetErrorAsset( const char* asset )
{
    if( !asset )
        return nullptr;

    std::string_view sv( asset );

    if( sv.ends_with( ".mdl" ) )
        return "models/error.mdl";
    if( sv.ends_with( ".spr" ) )
        return "sprites/error.spr";
    return nullptr;
}
