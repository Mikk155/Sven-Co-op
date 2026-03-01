set( CMAKE_SYSTEM_NAME Windows )

add_compile_definitions( 
    WIN32
    _WINDOWS
    _USRDLL
    _CRT_SECURE_NO_WARNINGS
)

set( CMAKE_C_FLAGS "-m32" CACHE STRING "c flags" )
set( CMAKE_CXX_FLAGS "-m32" CACHE STRING "c++ flags" )

set( CMAKE_GENERATOR_PLATFORM Win32 CACHE STRING "" FORCE )

set( CMAKE_MSVC_RUNTIME_LIBRARY
    "MultiThreaded$<$<CONFIG:Debug>:Debug>"
    CACHE STRING "" FORCE
)
