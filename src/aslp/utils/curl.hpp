#include <string>
#include <vector>

#pragma once

#include <fmt/core.h>

#ifndef EXTERNAL_PROGRAM_TEST
#include <extdll.h>
#include <meta_api.h>
#include "progdefs.h"
extern mutil_funcs_t* gpMetaUtilFuncs;
#define LOG_ARGS(fmt_str, ...) ALERT( at_console, fmt::format( "[Curl Lib] " fmt_str "\n", __VA_ARGS__).c_str() )
#define LOG(fmt_str, ...) ALERT( at_console, "[Curl Lib] " fmt_str "\n" )
#else
#include <iostream>
#include <windows.h>
using DLHANDLE = HMODULE;
#define LOG_ARGS(fmt_str, ...) fmt::print( "[Curl Lib] " fmt_str "\n", __VA_ARGS__ )
#define LOG(fmt_str) fmt::print( "[Curl Lib] " fmt_str "\n" )
#endif

namespace curl
{
    typedef void CURL;
    typedef void curl_slist;
    typedef int CURLcode;

    enum Response
    {
        NotInitialized = -1,
        Ok = 0
    };

    typedef CURL* ( *curl_easy_init_fn )();
    typedef CURLcode ( *curl_easy_perform_fn )( CURL* );
    typedef void ( *curl_easy_cleanup_fn )( CURL* );
    typedef const char* ( *curl_easy_strerror_fn )( CURLcode );

    typedef CURLcode ( *curl_easy_setopt_fn )( CURL*, int, ... );

    typedef curl_slist* ( *curl_slist_append_fn )( curl_slist*, const char* );
    typedef void ( *curl_slist_free_all_fn )( curl_slist* );
    typedef CURLcode ( *curl_global_init_fn )( long );
    typedef void ( *curl_global_cleanup_fn )();
    typedef CURLcode (*curl_easy_getinfo_fn)(CURL*, int, ...);

    static curl_easy_init_fn easy_init;
    static curl_easy_setopt_fn easy_setopt;
    static curl_easy_perform_fn easy_perform;
    static curl_easy_cleanup_fn easy_cleanup;
    static curl_easy_strerror_fn easy_strerror;
    static curl_slist_append_fn slist_append;
    static curl_slist_free_all_fn slist_free_all;
    static curl_global_init_fn global_init;
    static curl_global_cleanup_fn global_cleanup;
    static curl_easy_getinfo_fn easy_getinfo;

    static bool __IsActive__ = false;

    inline bool IsActive()
    {
        return __IsActive__;
    }

#ifdef _WIN32
#define LibCurlName "libcurl.dll"
#else
#define LibCurlName "libcurl.so.4"
#endif


    static DLHANDLE curl_library = nullptr;

    inline DLHANDLE GetCurlModule()
    {

        if( curl_library == nullptr )
        {
#ifndef EXTERNAL_PROGRAM_TEST
            curl_library = gpMetaUtilFuncs->pfnGetModuleHandle( LibCurlName );
#else
            curl_library = LoadLibraryA( LibCurlName );
#endif
        }
        return curl_library;
    }

    inline void Shutdown()
    {
        if( IsActive() )
        {
            if( global_cleanup )
                global_cleanup();

#ifndef EXTERNAL_PROGRAM_TEST
            gpMetaUtilFuncs->pfnCloseModuleHandle( GetCurlModule() );
#else
            FreeLibrary( GetCurlModule() );
#endif
            curl_library = nullptr;
            __IsActive__ = false;
        }
    }

    inline bool Initialize()
    {
        if( IsActive() )
            return true;

        if( GetCurlModule() == nullptr )
        {
            LOG_ARGS( "Failed to find {}", LibCurlName );
            return false;
        }

#ifndef EXTERNAL_PROGRAM_TEST
#define CURLGET( name ) \
    name = ( curl_##name##_fn )gpMetaUtilFuncs->pfnGetProcAddress( GetCurlModule(), "curl_" #name ); if( !##name ) { \
        LOG( "failed to get " #name " from libcurl" ); return false; }
#else
#define CURLGET( name ) \
    name = ( curl_##name##_fn )reinterpret_cast<void*>( GetProcAddress( GetCurlModule(), "curl_" #name ) ); if( !##name ) { \
        LOG( "failed to get " #name " from libcurl" ); return false; }
#endif

        CURLGET( easy_init );
        CURLGET( easy_setopt );
        CURLGET( easy_perform );
        CURLGET( easy_cleanup );
        CURLGET( easy_strerror );
        CURLGET( slist_free_all );
        CURLGET( slist_append );
        CURLGET( global_init );
        CURLGET( global_cleanup );
        CURLGET( easy_getinfo );

        if( global_init( 3 ) != 0 )
        {
            LOG( "Failed to initialize libcurl" );
            return false;
        }

        __IsActive__ = true;

        return true;
    }

    static size_t CurlWrite( char* ptr, size_t size, size_t nmemb, void* userdata )
    {
        std::string* out = (std::string*)userdata;
        out->append( ptr, size * nmemb );
        return size * nmemb;
    }

    struct Request
    {
        std::string url;
        std::string response;
        std::string post;
        std::vector<std::string> headers;
        long status = 0;

        Response Perform()
        {
            if( !IsActive() )
            {
                LOG_ARGS( "Can not request. libcurl is not initialized! {}", url );
                return Response::NotInitialized;
            }

            CURL* curl = easy_init();

            if( !curl )
                return Response::NotInitialized;

            // Cleanup for reusing
            response.clear();
            status = 0;

            curl_slist* hdr = nullptr;

            for( auto& h : headers )
            {
                hdr = slist_append( hdr, h.c_str() );
            }

            easy_setopt( curl, 10002 /* CURLOPT_URL */, url.c_str() );
            easy_setopt( curl, 10023 /* CURLOPT_HTTPHEADER */, hdr );
            easy_setopt( curl, 20011 /* CURLOPT_WRITEFUNCTION */, CurlWrite );
            easy_setopt( curl, 10001 /* CURLOPT_WRITEDATA */, &response );
            easy_setopt( curl, 10018 /* CURLOPT_USERAGENT */, "svencoop/1.0" );
            easy_setopt( curl, 13 /* CURLOPT_TIMEOUT */, 10L );
            easy_setopt( curl, 78 /* CURLOPT_CONNECTTIMEOUT */, 5L );
            easy_setopt( curl, 52 /* CURLOPT_FOLLOWLOCATION */, 1L );

            if( !post.empty() )
            {
                easy_setopt( curl, 47 /* CURLOPT_POST */, 1L );
                easy_setopt( curl, 10015 /* CURLOPT_POSTFIELDS */, post.c_str() );
                easy_setopt( curl, 60 /* CURLOPT_POSTFIELDSIZE */, post.size() );
//               easy_setopt( curl, 41 /* CURLOPT_VERBOSE */, 1L );
            }

            CURLcode res = easy_perform( curl );

            easy_cleanup( curl );
            slist_free_all( hdr );

            if( res != 0 )
            {
                LOG_ARGS( "curl error {}: {}", res, easy_strerror( res ) );
            }
            else
            {
                easy_getinfo( curl, 0x200002 /* CURLINFO_RESPONSE_CODE */, &status );
            }

            return (Response)res;
        }
    };
}
#undef LOG
#undef LOG_ARGS
