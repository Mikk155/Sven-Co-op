/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

/**
*   MKE aka "Mikk's Extensions" As for lack of imagination for a proper name.
*   This plugin works as a loader for other plugins of mine to prevent multiple initialization of different objects.
*   To include any new plugin go to the MKExtension/plugins.as and add a new entry.
**/

#include "../../Mikk155/Logger"
CLogger g_Logger( "MKExtension", true );

#include "Utils"

#include "Hooks/main"

#include "Reflection"

#include "Extensions/Extension"
#include "Extensions/main"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );

    // Required reload to have the concommand prefix from default_plugins x[
    Logger::RegisterConCommands();

    // Register all plugins in here.
    Extensions::RegisterExtensions();

    g_MKExtensionManager.InitExtensions();
}

void PluginExit()
{
    g_MKExtensionManager.CallHook( "OnPluginExit", @Hooks::Info() );
}

void MapInit()
{
    g_MKExtensionManager.CallHook( "OnMapInit", @Hooks::Info() );
}

void MapStart()
{
    g_MKExtensionManager.CallHook( "OnMapStart", @Hooks::Info() );
}

void MapActivate()
{
    Hooks::InfoMapActivate@ info = Hooks::InfoMapActivate();
    info.NumberOfEntities = g_EngineFuncs.NumberOfEntities();
    g_MKExtensionManager.CallHook( "OnMapActivate", @info );
}
