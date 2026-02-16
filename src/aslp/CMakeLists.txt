cmake_minimum_required( VERSION 3.10 )

project( aslp LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    message( FATAL_ERROR "This project MUST be built for 32-bits" )
endif()

if( MSVC ) 
    set( CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON )
endif()

set( CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE )

set( SVENCOOP_DEBUG_ARGS
    "-as_outputdocs asdocs +map hl_c04"
    CACHE STRING
    "Command line arguments used when debugging Sven Co-op"
)

set( METAMOD_DLL_DIR
    "${CMAKE_INSTALL_PREFIX}/svencoop/addons/metamod/dlls"
)

file( GLOB_RECURSE PROJECT_FILES
    CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)

add_library( ${PROJECT_NAME} SHARED ${PROJECT_FILES} )

if( MSVC ) 
    target_compile_options( ${PROJECT_NAME} PRIVATE
        # fmt
        /utf-8
        # implicit cast
        /wd4302
        /wd4311
    )
endif()

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/common
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/dlls
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/pm_shared
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/engine

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext/include

    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/thirdparty/capstone_fork/include
)

target_include_directories( ${PROJECT_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/angelscript
    ${CMAKE_CURRENT_SOURCE_DIR}/header
)

target_compile_definitions( ${PROJECT_NAME} PRIVATE
    WIN32
    _WINDOWS
    _USRDLL
    PLATFORM_WINDOWS
    _CRT_SECURE_NO_WARNINGS
)

# JSON
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include
)

# FMT
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt/include
)

target_compile_definitions( ${PROJECT_NAME} PRIVATE
    FMT_HEADER_ONLY=1
)

add_dependencies( ${PROJECT_NAME} asext metamod )

set_target_properties( ${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME "${PROJECT_NAME}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)

# Taken from metamod's main CMakeLists
option(METAMOD_64BIT "Compile as 64bit" OFF)

if(METAMOD_64BIT)
    add_definitions(-DMETAMOD_64BIT)
endif()

# 设置平台名称
if(WIN32)
    if(METAMOD_64BIT)
        set(PLATFORM_TARGET "x64")
    else()
        set(PLATFORM_TARGET "x86")
    endif()
else()
    if(METAMOD_64BIT)
        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(PLATFORM_TARGET "dbg.linux_amd64")
            set(OBJDIR_LINUX "dbg.linux_amd64")
        else()
            set(PLATFORM_TARGET "opt.linux_amd64")
            set(OBJDIR_LINUX "opt.linux_amd64")
        endif()
    else()
        if(CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(PLATFORM_TARGET "dbg.linux_i386")
            set(OBJDIR_LINUX "dbg.linux_i386")
        else()
            set(PLATFORM_TARGET "opt.linux_i386")
            set(OBJDIR_LINUX "opt.linux_i386")
        endif()
    endif()
endif()

# 平台特定设置
if(WIN32)
    add_definitions(-DWIN32 -D_WINDOWS -D_USRDLL -D_CRT_SECURE_NO_WARNINGS)

    if(METAMOD_64BIT)
        add_definitions(-D_WIN64)
    endif()
    
    # Windows 下的编译选项 - 支持多配置生成器
    # 使用生成器表达式来设置运行时库
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    
    # 设置调试信息
    add_compile_definitions($<$<CONFIG:Debug>:_DEBUG>)
    add_compile_definitions($<$<CONFIG:Release>:NDEBUG>)
    
    # 注意：根据项目文件，字符集设置为 NotSet，所以不添加 UNICODE 定义
    
elseif(UNIX)
    add_definitions(-DPLATFORM_POSIX -DLINUX -D_LINUX)
    
    # Linux 下的编译选项
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32 -fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32 -fPIC")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m32")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -m32")
    
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_definitions(-D_DEBUG)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
    else()
        add_definitions(-DNDEBUG)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
    endif()
endif()

# 查找第三方库
if(WIN32)
    # Windows 下的第三方库路径
    set(CAPSTONE_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${PLATFORM_TARGET}/$<CONFIG>/include)
    set(CAPSTONE_LIBRARIES ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${PLATFORM_TARGET}/$<CONFIG>/lib/capstone.lib)
else()
    # Linux 下的第三方库路径
    set(CAPSTONE_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${OBJDIR_LINUX}/include)
    set(CAPSTONE_LIBRARIES ${CMAKE_SOURCE_DIR}/../../external/metamod/thirdparty/install/capstone/${OBJDIR_LINUX}/lib/libcapstone.a)
endif()

# Metamod
add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod
    ${CMAKE_CURRENT_BINARY_DIR}/metamod
)

if( MSVC )
    target_compile_options( metamod PRIVATE /Zc:strictStrings- )
    target_compile_definitions( metamod PRIVATE _CRT_SECURE_NO_WARNINGS )
endif()

set_target_properties( metamod PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)

# AS Extended
add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext
    ${CMAKE_CURRENT_BINARY_DIR}/asext
)

set_target_properties( asext PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${METAMOD_DLL_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${METAMOD_DLL_DIR}"
)

if( MSVC )
    if( EXISTS "${CMAKE_INSTALL_PREFIX}/svencoop.exe" )

        # Copy plugins.ini if it doesn't exists
        set( PLUGIN_DEST_DIR "${CMAKE_INSTALL_PREFIX}/svencoop/addons/metamod" )
        set( PLUGIN_DEST "${PLUGIN_DEST_DIR}/plugins.ini" )
        file( MAKE_DIRECTORY "${PLUGIN_DEST_DIR}" )

        if( NOT EXISTS "${PLUGIN_DEST}" )
            message( STATUS "Installing ${PLUGIN_DEST}" )
            file( COPY "${CMAKE_CURRENT_SOURCE_DIR}/plugins.ini" DESTINATION "${PLUGIN_DEST_DIR}" )
        endif()

        # Launch game
        set_target_properties( ${PROJECT_NAME} PROPERTIES
            VS_DEBUGGER_COMMAND "${CMAKE_INSTALL_PREFIX}/svencoop.exe"
            VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}"
            VS_DEBUGGER_COMMAND_ARGUMENTS "${SVENCOOP_DEBUG_ARGS}"
        )
    else()
        message( WARNING "CMAKE_INSTALL_PREFIX is not defined propertly, couldn't find \"${CMAKE_INSTALL_PREFIX}/svencoop.exe\"" )
    endif()
endif()
