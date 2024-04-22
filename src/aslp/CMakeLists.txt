cmake_minimum_required( VERSION 3.10 )

project( aslp )

set( CMAKE_CXX_STANDARD 11 )
set( CMAKE_CXX_STANDARD_REQUIRED True )

set( SOURCES
    angelscript/vftable.cpp

    aslp.cpp
    dllapi.cpp
    dllmain.cpp
    engine_api.cpp
    engine_hook.cpp

    entities/CApache.cpp
    entities/CBloater.cpp
    entities/COsprey.cpp
    entities/CPlayer.cpp
    entities/CSentry.cpp
    entities/CTurret.cpp

    entities/base/hook_items.cpp

    entities/register.cpp

    h_export.cpp
    meta_api.cpp
    server_hook.cpp
)

set( HEADERS
    angelscript/angelscript.h
    angelscript/angelscriptlib.h
    angelscript/dlldef.h
    angelscript/signatures.h
    angelscript/vftable.h

    aslp.h
    enginedef.h

    entities/register.h

    entities/base/hook_items.h

    serverdef.h
    signatures.h
    utility.h
)

add_library( ${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS} )

target_include_directories( ${PROJECT_NAME} PUBLIC
	${CMAKE_CURRENT_SOURCE_DIR}
	../hlsdk/common
	../hlsdk/dlls
	../hlsdk/pm_shared
	../hlsdk/engine
	../metamod
	../asext/include
    angelscript
    entities/base
    entities
)

set_target_properties( ${PROJECT_NAME} PROPERTIES OUTPUT_NAME "aslp" )
