#include <string>
#include <vector>

#pragma once

namespace curl
{
    typedef void CURL;
    typedef void curl_slist;
    typedef int CURLcode;

    enum
    {
        CURLE_OK = 0
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

        bool Init();

        bool IsValid()
        {
            return easy_init && easy_setopt && easy_perform;
        }
    };
}

static curl::API g_Curl;

namespace curl
{
    static size_t CurlWrite( char* ptr, size_t size, size_t nmemb, void* userdata )
    {
        std::string* out = (std::string*)userdata;
        out->append( ptr, size * nmemb );
        return size * nmemb;
    }

    struct CurlRequest
    {
        std::string url;
        std::string response;
        std::string post;
        std::vector<std::string> headers;
        long status = 0;

        bool Perform()
        {
            CURL* curl = g_Curl.easy_init();

            if( !curl )
            {
                return false;
            }

            curl_slist* hdr = nullptr;

            for( auto& h : headers )
            {
                hdr = g_Curl.slist_append( hdr, h.c_str() );
            }

            g_Curl.easy_setopt( curl, 10002 /* CURLOPT_URL */, url.c_str() );
            g_Curl.easy_setopt( curl, 10023 /* CURLOPT_HTTPHEADER */, hdr );
            g_Curl.easy_setopt( curl, 20011 /* CURLOPT_WRITEFUNCTION */, CurlWrite );
            g_Curl.easy_setopt( curl, 10001 /* CURLOPT_WRITEDATA */, &response );

            if( !post.empty() )
            {
                g_Curl.easy_setopt( curl, 10015 /* CURLOPT_POSTFIELDS */, post.c_str() );
            }

            CURLcode res = g_Curl.easy_perform( curl );

            g_Curl.easy_cleanup( curl );
            g_Curl.slist_free_all( hdr );

            return res == CURLE_OK;
        }
    };
}
