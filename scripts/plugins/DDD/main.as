/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

#include "../../mikk155/meta_api"
#include "Hooks/main"

#include "../../mikk155/SemanticVersion"

const SemanticVersion gpPluginVersion( 0, 0, 0 );

bool __PluginJustLoaded__ = true;

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    Hooks::Register();

    uint length = gpContextPointers.length();

    for( uint ui = 0; ui < length; ui++ )
    {
        IContext@ context = gpContextPointers[ui];

        if( context is null )
            continue;
        
        g_EngineFuncs.ServerPrint( "======================================================================\n" );
        g_Game.AlertMessage( at_console, "Registering context \"%1\" at index %2\n", context.GetName(), ui );
        g_EngineFuncs.ServerPrint( "----------------------------------------------------------------------\n" );
        context.Register( ( g_Engine.time <= 0 ) );
        g_EngineFuncs.ServerPrint( "======================================================================\n" );
    }
}

// uint alias representing difficulty level 0/100 percent.
typedef uint Difficulty;

/// Interface required for the bare minimum.
/// Call RegisterContext(this) under your object constructor and instantiate a const static class in the global scope that you can use anywhere
interface IContext
{
    // Unique name for your context
    const string& GetName() const;
    // Whatever your context is currently active in the given difficulty
    bool IsActive( const Difficulty difficulty ) const;
    // Called when the plugin is loaded.
    // runtime: true if it's too late to precache stuff.
    void Register( bool runtime );
}

array<IContext@> gpContextPointers;
dictionary gpContextNames;

// Register the given context into the context list. return the index where it's being stored. -1 if fail
int RegisterContext( IContext@ context )
{
    if( __PluginJustLoaded__ ) // This gotta be the first thing that happens
    {
        string buffer;
        snprintf( buffer, "Initializing plugin DDD \"Dynamic Difficulty Deluxe\" version: %1\n", gpPluginVersion.ToString() );
        g_EngineFuncs.ServerPrint( "======================================================================\n" );
        g_EngineFuncs.ServerPrint( buffer );

        if( !meta_api::IsInstalled() )
        {
            g_EngineFuncs.ServerPrint( "----------------------------------------------------------------------\n" );
            meta_api::NoticeInstallation();
        }
        g_EngineFuncs.ServerPrint( "======================================================================\n" );
        __PluginJustLoaded__ = false;
    }

    if( gpContextNames.exists( context.GetName() ) )
    {
        g_Game.AlertMessage( at_console, "Context with name \"%1\" already exists!\n", context.GetName() );
        return -1;
    }

    uint index = gpContextPointers.length();

    gpContextPointers.insertLast( context );
    gpContextNames[ context.GetName() ] = index;

    g_Game.AlertMessage( at_console, "Initialized context \"%1\" at index %2\n", context.GetName(), index );

    return index;
}

class b : IContext
{
    b()
    {
        RegisterContext(this);
    }

    const string& GetName() const
    {
        return "b";
    }

    bool IsActive( const Difficulty difficulty ) const
    {
        return difficulty > 90;
    }

    void Register( bool runtime )
    {
    }
}

const b gpb;

void MapActivate()
{
}

void MapInit()
{
}
