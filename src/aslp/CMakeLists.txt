cmake_minimum_required( VERSION 3.10 )

project( aslp LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
set( CMAKE_CXX_EXTENSIONS OFF )

set( SOURCES
    source/angelscript.cpp
    source/CASBaseObject.cpp
    source/CASBinaryStringBuilder.cpp
    source/CASSQLite.cpp
    source/CASSQLItem.cpp
    source/CASSQLGrid.cpp
    source/dllapi.cpp
    source/engine_api.cpp
    source/h_export.cpp
    source/meta_api.cpp
    source/sdk_util.cpp
    source/vftable.cpp
)

set( HEADERS
    angelscript/angelscriptlib.h
    header/angelscript.h
    header/CASBaseObject.h
    header/CASBinaryStringBuilder.h
    header/CASSQLite.h
    header/CASSQLItem.h
    header/CASSQLGrid.h
    header/dlldef.h
    header/enginedef.h
    header/info_name.h
    header/signatures.h
    header/utility.h
    header/vftable.h
)

add_library( ${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS} )

target_include_directories( ${PROJECT_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/common
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/dlls
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/pm_shared
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/hlsdk/engine
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/metamod
    ${CMAKE_CURRENT_SOURCE_DIR}/../../external/metamod/asext/include
    ${CMAKE_CURRENT_SOURCE_DIR}/angelscript
    ${CMAKE_CURRENT_SOURCE_DIR}/header
)

set_target_properties( ${PROJECT_NAME} PROPERTIES OUTPUT_NAME "aslp" )
