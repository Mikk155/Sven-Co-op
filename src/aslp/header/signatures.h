#pragma once
#include "signatures_template.h"

#ifdef _WIN32
#define SC_SERVER_DUMMYVAR int dummy = 0;
#define SERVER_DLL_NAME "server.dll"
#else
#define SC_SERVER_DUMMYVAR
#define SERVER_DLL_NAME "server.so"

#endif
#define FILL_AND_HOOK(dll, name) FILL_FROM_SIGNATURE(dll, name);INSTALL_INLINEHOOK(name)