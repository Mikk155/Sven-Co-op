cmake_minimum_required( VERSION 3.15 )

project( main LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )

add_executable( ${PROJECT_NAME} main.cpp )

target_include_directories( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}

    # JSON
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include

    # FMT
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt/include
)

# FMT options
target_compile_definitions(${PROJECT_NAME} PRIVATE
    FMT_HEADER_ONLY=1
    # Disable Exceptions
    FMT_USE_EXCEPTIONS=0
    # Disables some Unicode features, named arguments, locale support and applies some optimizations
    FMT_OPTIMIZE_SIZE=2
    # C++ 20 for json
    JSON_HAS_CPP_20=1
    # GenerateASPredefined
    AS_GENERATE_DOCUMENTATION=1
    GENERATE_AS_EXTERNAL_TEST=1
)

target_compile_options( ${PROJECT_NAME} PRIVATE
    # FMT
    /utf-8
    /EHsc
)
