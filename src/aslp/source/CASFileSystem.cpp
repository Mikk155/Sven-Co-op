#include "CASFileSystem.h"

#include <vector>
#include <string>

static std::vector<FileWatcher> g_FileSystemWatcher = {};

#define WF_F( w, c, d ) \
!CheckFileModified( w, "svencoop"#d, c )

#define WatchFileSystemDate( w, c ) \
if( WF_F( w, c, _addon ) || WF_F( w, c, _hd ) || WF_F( w, c, ) || WF_F( w, c, _downloads ) ) {}

bool CheckFileModified( FileWatcher& watcher, const char *Directory, bool Initializing = false )
{
    std::error_code ec;

    std::filesystem::path path = std::filesystem::current_path() / std::filesystem::path( Directory ) / std::filesystem::path( watcher.Name );

    if( Initializing ) // Setup
    {
        watcher.Exists = std::filesystem::exists( path, ec );

        if( watcher.Exists )
        {
            if( auto currentTime = std::filesystem::last_write_time( path, ec ); !ec )
            {
                watcher.LastWriteTime = currentTime;
                return true;
            }
        }
        return false;
    }

    auto ASCallback = [&]()
    {
        if( watcher.Callback && ASEXT_CallCASBaseCallable && (*ASEXT_CallCASBaseCallable) )
        {
            CString* filename = new CString();
            filename->assign( watcher.Name.c_str(), watcher.Name.length() );
            (*ASEXT_CallCASBaseCallable)( watcher.Callback, 0, &filename );
        }
    };

    // File currently exists
    if( bool fExists = std::filesystem::exists( path, ec ); fExists )
    {
        watcher.Exists = fExists;

        if( auto currentTime = std::filesystem::last_write_time( path, ec ); !ec )
        {
            if( currentTime != watcher.LastWriteTime )
            {
                watcher.LastWriteTime = currentTime;
                ASCallback();
            }
        }
    }
    // File used to exist but now it does not.
    else if( watcher.Exists )
    {
        watcher.Exists = false;
        ASCallback();
    }
    return true;
}

extern globalvars_t* gpGlobals;
static float g_FileSystemCooldown;

void CheckFileSystemWatcher()
{
    if( g_FileSystemCooldown > gpGlobals->time || g_FileSystemWatcher.size() <= 0 )
        return;

    g_FileSystemCooldown = gpGlobals->time + 0.5f;

    g_FileSystemWatcher.erase( std::remove_if( g_FileSystemWatcher.begin(), g_FileSystemWatcher.end(),
        [](const FileWatcher& w)
        {
            if( w.Callback == nullptr )
            {
    	        ALERT( at_console, "FileSystem::WatchFile null pointer callback for \"%s\". removing...\n", w.Name.c_str() );
            }
            return false;
        }
    ), g_FileSystemWatcher.end() );

	for( auto& watcher : g_FileSystemWatcher )
	{
        WatchFileSystemDate( watcher, false )
	}
}

bool SC_SERVER_DECL CASFileSystem_WatchFile( void* pthis, SC_SERVER_DUMMYARG const CString& filename, aslScriptFunction* callback )
{
    std::string Name = std::string( filename.c_str() );

    if( Name.empty() )
    {
	    ALERT( at_console, "FileSystem::WatchFile empty string given\n" );
        return false;
    }
    else if( !Name.starts_with( "scripts/" ) )
    {
	    ALERT( at_console, "FileSystem::WatchFile can not watch outside of \"scripts/\" folder.\n" );
        return false;
    }

    FileWatcher watcher = {
        .Name = std::move( Name ),
        .Callback = ASEXT_CreateCASFunction( callback, ASEXT_GetServerManager()->curModule, 1 )
    };

    WatchFileSystemDate( watcher, true )

    g_FileSystemWatcher.push_back( std::move( watcher ) );

    return true;
}
