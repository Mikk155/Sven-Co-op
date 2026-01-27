#include <extdll.h>
#include <meta_api.h>
#include <asext_api.h>
#include <angelscriptlib.h>

#include <filesystem>

#pragma once

struct FileWatcher
{
    std::string Name;
    CASFunction* Callback;
    std::filesystem::file_time_type LastWriteTime{};
    bool Exists;
};

void CheckFileSystemWatcher();
bool SC_SERVER_DECL CASFileSystem_WatchFile( void* pthis, SC_SERVER_DUMMYARG const CString& filename, aslScriptFunction* callback );
