#include <extdll.h>
#include <meta_api.h>
#include "enginedef.h"
#include "curl.h"

extern mutil_funcs_t* gpMetaUtilFuncs;

bool curl::API::Init()
{
    DLHANDLE curlHandle = gpMetaUtilFuncs->pfnGetModuleHandle(
#ifdef _WIN32
        "libcurl.dll"
#else
        "libcurl.so.4"
#endif
    );

    if( !curlHandle )
        return false;

    auto get = [&]( const char* n )
    {
        return gpMetaUtilFuncs->pfnGetProcAddress( curlHandle, n );
    };

    easy_init = ( curl_easy_init_fn )get( "curl_easy_init" );
    easy_setopt = ( curl_easy_setopt_fn )get( "curl_easy_setopt" );
    easy_perform = ( curl_easy_perform_fn )get( "curl_easy_perform" );
    easy_cleanup = ( curl_easy_cleanup_fn )get( "curl_easy_cleanup" );
    easy_strerror = ( curl_easy_strerror_fn )get( "curl_easy_strerror" );
    slist_append = ( curl_slist_append_fn )get( "curl_slist_append" );
    slist_free_all = ( curl_slist_free_all_fn )get( "curl_slist_free_all" );

    return IsValid();
}
