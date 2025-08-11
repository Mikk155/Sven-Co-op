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

abstract class IPlugin
{
    string GetName()
    {
        return String::EMPTY_STRING;
    }

    CLogger@ Logger;

    IPlugin()
    {
        @Logger = CLogger( GetName() );

        string buffer;
        snprintf( buffer, "Registered plugin %1", GetName() );
        Logger.info( buffer );
    }

/**
* ========================
*          Start of Hooks
* ========================
**/
    // Equivalent to PluginInit
    HookCode OnPluginEnable() { return HookCode.Continue; }
    // Equivalent to PluginExit
    HookCode OnPluginDisable() { return HookCode.Continue; }
    // Equivalent to MapInit
    HookCode OnMapInit() { return HookCode.Continue; }
    // Equivalent to MapActivate
    HookCode OnMapActivate() { return HookCode.Continue; }
    // Equivalent to MapStart
    HookCode OnMapStart() { return HookCode.Continue; }
    // Called every server frame. starting from MapActivate
    HookCode OnThink() { return HookCode.Continue; }
    // Called when the class plugin is disabled for the current map
    HookCode OnMapDisabled() { return HookCode.Continue; }
    // Called when the map is being changed
    HookCode OnMapChange( const string&in mapname ) { return HookCode.Continue; }
    // Called when the map is restarted to the same level
    HookCode OnMapRestart() { return HookCode.Continue; }
    // Called when all players die in a survival mode game
    HookCode OnSurvivalRoundEnd() { return HookCode.Continue; }
}
