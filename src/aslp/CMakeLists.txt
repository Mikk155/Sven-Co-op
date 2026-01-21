cmake_minimum_required( VERSION 3.10 )

project( aslp LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

if( MSVC )
    set(CMAKE_GENERATOR_PLATFORM Win32)
    add_compile_options( /wd4302 )
    add_compile_options( /wd4311 )
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" )
endif()

set( SOURCES
    source/angelscript.cpp
    source/CASBaseObject.cpp
    source/CASBinaryStringBuilder.cpp
    source/CASJson.cpp
    source/CASSQLGrid.cpp
    source/CASSQLite.cpp
    source/CASSQLItem.cpp
    source/CFile.cpp
    source/dll_hook.cpp
    source/dllapi.cpp
    source/dllmain.cpp
    source/engine_api.cpp
    source/engine_hook.cpp
    source/h_export.cpp
    source/meta_api.cpp
    source/sdk_util.cpp
    source/vftable.cpp
    source/generate_as_networking.cpp
    source/generate_as_predefined.cpp
)

set( HEADERS
    angelscript/angelscriptlib.h

    header/angelscript.h
    header/CASBaseObject.h
    header/CASBinaryStringBuilder.h
    header/CASJson.h
    header/CASSQLGrid.h
    header/CASSQLite.h
    header/CASSQLItem.h
    header/CFile.h
    header/dlldef.h
    header/enginedef.h
    header/extern_hook.h
    header/generate_as_networking.h
    header/info_name.h
    header/signatures.h
    header/utility.h
    header/vftable.h
)

add_library( ${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS} )

target_include_directories( ${PROJECT_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/angelscript
    ${CMAKE_CURRENT_SOURCE_DIR}/header

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/common
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/dlls
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/pm_shared
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/engine

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext/include
)

target_compile_definitions( ${PROJECT_NAME} PRIVATE
    WIN32
    _WINDOWS
    _USRDLL
    PLATFORM_WINDOWS
    _CRT_SECURE_NO_WARNINGS
)

# JSON
add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json
    ${CMAKE_CURRENT_BINARY_DIR}/external/json
)

target_link_libraries( ${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json )

# FMT
set( FMT_INSTALL OFF CACHE BOOL "" FORCE )

add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt
    ${CMAKE_CURRENT_BINARY_DIR}/external/fmt
)

if( MSVC )
    target_compile_options( fmt PRIVATE
        /wd4244  # conversion from uint64 to size_t
        /wd4267  # size_t conversion
    )
endif()

target_link_libraries( ${PROJECT_NAME} PRIVATE fmt )

set_target_properties( ${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${PROJECT_NAME}" )

install( TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION .   # Windows (.dll)
    LIBRARY DESTINATION .   # Linux (.so)
    ARCHIVE DESTINATION .   # Static libs (.lib / .a)
)