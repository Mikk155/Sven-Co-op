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

enum HookCode
{
    Continue = 0,
    // Stop calling other IPlugin classes
    Break = ( 1 << 0 ),
    // Handle vanilla and metamod plugins. equivalent to HOOK_HANDLED
    Handle = ( 1 << 1 ),
    // Handle the original game's call (metamod plugins)
    Supercede = ( 1 << 2 ),
};

class HookInfo
{
    HookCode code = HookCode::Continue;

    HookInfo() { }
}

void PluginExit()
{
    g_MKExtensionManager.CallHook( "OnPluginExit", HookInfo() );
}

void MapInit()
{
    g_MKExtensionManager.CallHook( "OnMapInit", HookInfo() );
}

void MapStart()
{
    g_MKExtensionManager.CallHook( "OnMapStart", HookInfo() );
}

class HookInfoMapActivate : HookInfo
{
    // Number of entities before any hook spawns something else
    int NumberOfEntities;
}

void MapActivate()
{
    HookInfoMapActivate@ info = HookInfoMapActivate();
    info.NumberOfEntities = g_EngineFuncs.NumberOfEntities();
    g_MKExtensionManager.CallHook( "OnMapActivate", @info );
}

namespace Hooks
{
}
