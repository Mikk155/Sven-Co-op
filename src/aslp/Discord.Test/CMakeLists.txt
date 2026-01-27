cmake_minimum_required( VERSION 3.10 )
project( main )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

if( MSVC )
    set( CMAKE_GENERATOR_PLATFORM Win32 )
endif()

add_executable( 
    ${PROJECT_NAME}
    main.cpp
    ../source/Discord.cpp
 )

target_compile_definitions( ${PROJECT_NAME} PRIVATE DISCORD_CURL_TEST=1 )

target_include_directories( ${PROJECT_NAME} PRIVATE
    ../header
    ../source
 )

add_subdirectory( 
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../external/json
    ${CMAKE_CURRENT_BINARY_DIR}/external/json
 )

target_link_libraries( ${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json )

add_subdirectory( 
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../external/fmt
    ${CMAKE_CURRENT_BINARY_DIR}/external/fmt
 )

target_link_libraries( ${PROJECT_NAME} PRIVATE fmt )
