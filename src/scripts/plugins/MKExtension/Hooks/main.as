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

#if VSC_EXTENSION
#include "../main"
#endif

#include "events/OnMapActivate"
#include "events/OnMapChange"
#include "events/OnMapInit"
#include "events/OnMapStart"
#include "events/OnMapThink"
#include "events/OnPlayerSay"
#include "events/OnPluginExit"

namespace Hooks
{
    class Hook : NameGetter
    {
        Hook( const string &in name )
        {
            this.Name = name;
        }

        // Called only if this hook is being used by any extension
        void Register()
        {
            g_Logger.debug( "Registered hook \"" + this.GetName() + "\"" );
        }

        array<MKEHook@> Callables;
    }

    // Base class for any hook's arguments
    class IHookInfo
    {
        HookCode code = HookCode::Continue;

        IHookInfo() { }
    }

    class IExtensionInit : IHookInfo
    {
        private uint __ExtensionIndex__;

        uint ExtensionIndex {
            get const { return this.__ExtensionIndex__; }
        }

        IExtensionInit( uint _ExtensionIndex )
        {
            this.__ExtensionIndex__ = _ExtensionIndex;
        }
    }
}
