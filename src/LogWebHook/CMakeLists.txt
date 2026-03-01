project( LogWebHook )

set( LOGWEBHOOK_SOURCES
    main.cpp
)

# Windows-specific source files
if( WIN32 )
    list( APPEND LOGWEBHOOK_SOURCES ../../external/metamod/asext/dllmain.cpp )
endif()

add_library( LogWebHook SHARED ${LOGWEBHOOK_SOURCES} )

# JSON
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../external/json/single_include )

# FMT
target_compile_options( ${PROJECT_NAME} PRIVATE "/utf-8" )
target_include_directories( ${PROJECT_NAME} SYSTEM PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../external/fmt/include )
target_compile_definitions( ${PROJECT_NAME} PRIVATE FMT_HEADER_ONLY=1 )

add_dependencies( ${PROJECT_NAME} metamod )

if( MSVC )
    if( EXISTS "${CMAKE_INSTALL_PREFIX}/svencoop.exe" )
        set( PLUGIN_DEST_DIR "${CMAKE_INSTALL_PREFIX}/svencoop/addons/metamod/dlls" )
        set( PLUGIN_DEST "${PLUGIN_DEST_DIR}/LogWebHook.json" )
        file( MAKE_DIRECTORY "${PLUGIN_DEST_DIR}" )
#        if( NOT EXISTS "${PLUGIN_DEST}" )
            message( STATUS "Installing ${PLUGIN_DEST}" )
            file( COPY "${CMAKE_CURRENT_SOURCE_DIR}/LogWebHook.json" DESTINATION "${PLUGIN_DEST_DIR}" )
#        endif()
    endif()
endif()
