cmake_minimum_required( VERSION 3.10 )

project( aslp LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )
set( CMAKE_GENERATOR_PLATFORM Win32 )
set( CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON )

add_compile_definitions( CURL_EXTERNAL_TEST=1 )

project( LogWebHook )

add_executable( ${PROJECT_NAME} ../LogWebHook/main.cpp )

target_compile_options( ${PROJECT_NAME} PRIVATE "/utf-8" )

# JSON
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include
)

# FMT
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt/include
)

target_compile_definitions( ${PROJECT_NAME} PRIVATE FMT_HEADER_ONLY=1 )
