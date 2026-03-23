#include <string>
#include <filesystem>

#include "../../src/aslp/misc/GenerateASPredefined.hpp"

int main()
{
    // Set new working directory
    std::filesystem::current_path( "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Sven Co-op" );

    GenerateASPredefined::Start();

    while( !GenerateASPredefined::g_state->done )
    {

    }

    for( const std::string& str : GenerateASPredefined::g_state->buffer )
    {
        fmt::print( fmt::runtime( str ) );
    }

    GenerateASPredefined::Shutdown();

    return 0;
}
