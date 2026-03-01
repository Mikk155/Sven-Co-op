cmake_minimum_required( VERSION 3.15 )

project( aslp LANGUAGES CXX )

# 32-bit enforcement (strict for sven)
if( NOT CMAKE_SIZEOF_VOID_P EQUAL 4 )
    message( FATAL_ERROR "This project MUST be compiled as 32-bit." )
endif()

# Standard we use at aslp
set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

# ============================================================
# Start cache
# ============================================================
set( CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE )

# Don't confuse the user with these
mark_as_advanced(
    CMAKE_INSTALL_PREFIX
    CMAKE_CONFIGURATION_TYPES
    CMAKE_GENERATOR_PLATFORM
    CMAKE_MSVC_RUNTIME_LIBRARY
    CMAKE_TOOLCHAIN_FILE
    CMAKE_C_FLAGS
    CMAKE_CXX_FLAGS
)

# User-configurable paths
set( SVENCOOP_ROOT "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Sven Co-op" CACHE PATH "Path to Sven Co-op/ root folder" )

if( NOT EXISTS "${SVENCOOP_ROOT}/svencoop/" )
    message( FATAL_ERROR "SVENCOOP_ROOT is not valid, couldn't find svencoop folder" )
endif()

option( GENERATE_AS_DOCUMENTATION "Generate AS documentation on start up" ON )

option( SVENCOOP_DEDICATED_SERVER "If on. the debugger will run the dedicated server. Listen server otherwise." OFF )

set( PARAM_MAP_NAME "hl_c04" CACHE STRING "Name of the map to launch on debuging" )

set( PARAM_LAUNCH_PARAMETERS "-dev -console" CACHE STRING "Additional launch parameters" )

set( DEFAULT_BUILD_CONFIG "Debug"
    CACHE STRING "Default configuration selected in generated solution"
)

set_property( CACHE DEFAULT_BUILD_CONFIG PROPERTY STRINGS
    "Debug"
    "Release"
)

if( MSVC )
    set( CMAKE_VS_DEFAULT_BUILD_TYPE "${DEFAULT_BUILD_CONFIG}" CACHE STRING "" FORCE )
    mark_as_advanced( CMAKE_VS_DEFAULT_BUILD_TYPE )
else()
    set( CMAKE_BUILD_TYPE "${DEFAULT_BUILD_CONFIG}" CACHE STRING "" FORCE )
    mark_as_advanced( CMAKE_BUILD_TYPE )
endif()
# ============================================================
# End cache
# ============================================================

# Enable LTO
include( CheckIPOSupported )

check_ipo_supported( RESULT ipo_supported OUTPUT error )

if( ipo_supported )
    message( STATUS "IPO/LTO enabled." )
    set( CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE )
else()
    message( WARNING "IPO/LTO not supported: ${error}" )
endif()

# Where to copy the binaries
set( METAMOD_DLL_DIR "${SVENCOOP_ROOT}/svencoop/addons/metamod/dlls" )

# Global Includes
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/common
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/dlls
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/pm_shared
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/engine

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext/include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/thirdparty/angelscript-sdk/angelscript/include

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/thirdparty/capstone_fork/include
)

add_compile_definitions( $<$<CONFIG:Debug>:_DEBUG> )
add_compile_definitions( $<$<CONFIG:Release>:NDEBUG> )

# Platform configuration
if( WIN32 )
    # Platform target
    set( PLATFORM_TARGET "x86" )

    # debug symbols
    set( CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Zi" )
    set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi" )
    set( CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG" )

    # Capstone lib & include
    set( CAPSTONE_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${PLATFORM_TARGET}/$<CONFIG>/include )
    set( CAPSTONE_LIBRARIES ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${PLATFORM_TARGET}/$<CONFIG>/lib/capstone.lib )
else()
    # Platform target
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(PLATFORM_TARGET "dbg.linux_i386")
        set(OBJDIR_LINUX "dbg.linux_i386")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
    else()
        set(PLATFORM_TARGET "opt.linux_i386")
        set(OBJDIR_LINUX "opt.linux_i386")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    endif()

    # debug symbols
    set( CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g" )
    set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g" )

    # Capstone lib & include
    set( CAPSTONE_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${OBJDIR_LINUX}/include )
    set( CAPSTONE_LIBRARIES ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${OBJDIR_LINUX}/lib/libcapstone.a )
endif()

# ============================================================
# Start Metamod
# ============================================================
set( PROJECT_METAMOD metamod )

# Metamod
add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod
    ${CMAKE_CURRENT_BINARY_DIR}/metamod
)

if( MSVC )
    # Implicit conversions from const char to char
    target_compile_options( ${PROJECT_METAMOD} PRIVATE /Zc:strictStrings- )
    target_compile_definitions( ${PROJECT_METAMOD} PRIVATE _CRT_SECURE_NO_WARNINGS )
endif()

# Binary destination
set_target_properties( ${PROJECT_METAMOD} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)
# ============================================================
# End Metamod
# ============================================================

# ============================================================
# Start Angelscript Extended
# ============================================================
set( PROJECT_ASEXT asext )

add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext
    ${CMAKE_CURRENT_BINARY_DIR}/asext
)

# Binary destination
set_target_properties( ${PROJECT_ASEXT} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)
# ============================================================
# End Angelscript Extended
# ============================================================

# ============================================================
# Start ASLP
# ============================================================
file( GLOB_RECURSE PROJECT_FILES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)

# Windows-specific source
if( WIN32 )
    list( APPEND PROJECT_FILES metamod/windows.cpp )
endif()

add_library(${PROJECT_NAME} SHARED ${PROJECT_FILES})

# Includes
target_include_directories( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/angelscript
    ${CMAKE_CURRENT_SOURCE_DIR}/metamod

    # JSON
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include

    # FMT
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt/include

    # AngelScript SDK
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/thirdparty/angelscript-sdk/angelscript/include

    # AS Extended
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext/include
)

# FMT options
target_compile_definitions(${PROJECT_NAME} PRIVATE
    FMT_HEADER_ONLY=1
    # Disable Exceptions
    FMT_USE_EXCEPTIONS=0
    # Disables some Unicode features, named arguments, locale support and applies some optimizations
    FMT_OPTIMIZE_SIZE=2
)

if( MSVC )
    target_compile_options(${PROJECT_NAME} PRIVATE
        # FMT
        /utf-8
        # Truncated cast data loss
        /wd4302
        /wd4311
        /EHsc
    )
endif()

# Link dependencies
target_link_libraries( ${PROJECT_NAME} PRIVATE metamod asext )

# Binary destination
set_target_properties(${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${PROJECT_NAME}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)
# ============================================================
# End ASLP
# ============================================================

if( EXISTS "${SVENCOOP_ROOT}/svencoop/" )

    # ============================================================
    # Copy plugins.ini if not exists
    # ============================================================
    set( PLUGIN_DEST_DIR "${SVENCOOP_ROOT}/svencoop/addons/metamod" )
    set( PLUGIN_DEST "${PLUGIN_DEST_DIR}/plugins.ini" )
    file( MAKE_DIRECTORY "${PLUGIN_DEST_DIR}" )
    if( NOT EXISTS "${PLUGIN_DEST}" )
        message( STATUS "Installing default plugins.ini" )
        file( COPY "${CMAKE_CURRENT_SOURCE_DIR}/plugins.ini" DESTINATION "${PLUGIN_DEST_DIR}" )
    endif()

    # ============================================================
    # Should we create as.predefined with our new exposed API?
    # ============================================================
    if( GENERATE_AS_DOCUMENTATION )
        set( PARAM_GENERATE_AS_DOCUMENTATION "-as_outputdocs asdocs" CACHE STRING "" FORCE )
    else()
        set( PARAM_GENERATE_AS_DOCUMENTATION "" CACHE STRING "" FORCE )
    endif()

    mark_as_advanced( PARAM_GENERATE_AS_DOCUMENTATION )

    # Visual Studio Debugger
    if( MSVC )
        if( SVENCOOP_DEDICATED_SERVER )
            set( GAME_EXECUTABLE "${SVENCOOP_ROOT}/svends.exe" )
        else()
            set( GAME_EXECUTABLE "${SVENCOOP_ROOT}/svencoop.exe" )
        endif()

        set_target_properties(${PROJECT_NAME} PROPERTIES
            VS_DEBUGGER_COMMAND "${GAME_EXECUTABLE}"
            VS_DEBUGGER_WORKING_DIRECTORY "${SVENCOOP_ROOT}"
            VS_DEBUGGER_COMMAND_ARGUMENTS "-dll addons/metamod/dlls/metamod.dll +map ${PARAM_MAP_NAME} ${PARAM_GENERATE_AS_DOCUMENTATION} ${PARAM_LAUNCH_PARAMETERS}"
        )
    endif()
endif()
