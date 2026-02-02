#include <string>
#include <vector>
#include <fmt/core.h>

#pragma once

#include <extdll.h>
#include <meta_api.h>
#include "enginedef.h"

extern mutil_funcs_t* gpMetaUtilFuncs;

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

    struct API
    {
        curl_easy_init_fn easy_init;
        curl_easy_setopt_fn easy_setopt;
        curl_easy_perform_fn easy_perform;
        curl_easy_cleanup_fn easy_cleanup;
        curl_easy_strerror_fn easy_strerror;
        curl_slist_append_fn slist_append;
        curl_slist_free_all_fn slist_free_all;

        DLHANDLE curl_library = nullptr;

        bool Register()
        {
            if( curl_library != nullptr )
                return true;

            curl_library = gpMetaUtilFuncs->pfnGetModuleHandle(
#ifdef _WIN32
                "libcurl.dll"
#else
                "libcurl.so.4"
#endif
            );

            if( !curl_library )
            {
                return false;
            }

            auto get = [&]( const char* name )
            {
                return gpMetaUtilFuncs->pfnGetProcAddress( curl_library, name );
            };

            easy_init = ( curl_easy_init_fn )get( "curl_easy_init" );
            easy_setopt = ( curl_easy_setopt_fn )get( "curl_easy_setopt" );
            easy_perform = ( curl_easy_perform_fn )get( "curl_easy_perform" );
            easy_cleanup = ( curl_easy_cleanup_fn )get( "curl_easy_cleanup" );
            easy_strerror = ( curl_easy_strerror_fn )get( "curl_easy_strerror" );
            slist_append = ( curl_slist_append_fn )get( "curl_slist_append" );
            slist_free_all = ( curl_slist_free_all_fn )get( "curl_slist_free_all" );

            // curl_formadd
            // curl_formfree
            // curl_multi_init
            // curl_multi_perform
            // curl_multi_info_read
            // curl_multi_add_handle
            // curl_multi_remove_handle
            // curl_multi_cleanup
            // curl_easy_getinfo

            return IsValid();
        }

        bool IsValid()
        {
            return easy_init && easy_setopt && easy_perform;
        }
    };

    static size_t CurlWrite( char* ptr, size_t size, size_t nmemb, void* userdata )
    {
        std::string* out = (std::string*)userdata;
        out->append( ptr, size * nmemb );
        return size * nmemb;
    }
}

static curl::API g_Curl;

namespace curl
{
    struct Request
    {
        std::string url;
        std::string response;
        std::string post;
        std::vector<std::string> headers;
        long status = 0;

        Response Perform()
        {
            CURL* curl = g_Curl.easy_init();

            if( !curl )
                return Response::NotInitialized;

            curl_slist* hdr = nullptr;

            for( auto& h : headers )
            {
                hdr = g_Curl.slist_append( hdr, h.c_str() );
            }

            g_Curl.easy_setopt( curl, 10002 /* CURLOPT_URL */, url.c_str() );
            g_Curl.easy_setopt( curl, 10023 /* CURLOPT_HTTPHEADER */, hdr );
            g_Curl.easy_setopt( curl, 20011 /* CURLOPT_WRITEFUNCTION */, CurlWrite );
            g_Curl.easy_setopt( curl, 10001 /* CURLOPT_WRITEDATA */, &response );
            g_Curl.easy_setopt( curl, 10018 /* CURLOPT_USERAGENT */, "svencoop/1.0" );

            if( !post.empty() )
            {
                g_Curl.easy_setopt( curl, 47 /* CURLOPT_POST */, 1L );
                g_Curl.easy_setopt( curl, 10015 /* CURLOPT_POSTFIELDS */, post.c_str() );
                g_Curl.easy_setopt( curl, 60 /* CURLOPT_POSTFIELDSIZE */, post.size() );
//                g_Curl.easy_setopt( curl, 41 /* CURLOPT_VERBOSE */, 1L );
            }

            CURLcode res = g_Curl.easy_perform( curl );

            g_Curl.easy_cleanup( curl );
            g_Curl.slist_free_all( hdr );

            return (Response)res;
        }
    };
}
