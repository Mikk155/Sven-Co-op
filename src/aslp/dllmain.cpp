#include <iostream>

#ifdef _WIN32
#include <windows.h>
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
#else
void __attribute__((constructor)) my_init() {
    std::cout << "Library loaded!" << std::endl;
}

void __attribute__((destructor)) my_fini() {
    std::cout << "Library unloaded!" << std::endl;
}
#endif
