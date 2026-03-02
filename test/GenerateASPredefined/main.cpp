#include <filesystem>

#include "../../src/aslp/misc/GenerateASPredefined.hpp"

int main()
{
    // Set new working directory
    std::filesystem::current_path( "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Sven Co-op" );

    GenerateASPredefined::Generate();
    return 0;
}
