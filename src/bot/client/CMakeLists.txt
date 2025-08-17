cmake_minimum_required( VERSION 3.16 )
project( main )

set( CMAKE_CXX_STANDARD 17 )

add_executable( ${PROJECT_NAME} main.cpp )

add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../external/json
    ${CMAKE_CURRENT_BINARY_DIR}/external/json
)

target_link_libraries( ${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json )
