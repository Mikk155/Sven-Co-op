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
#include "../../main"
#endif

namespace Hooks
{
    class IPlayerSay : IHookInfo
    {
        SayParameters@ params;

        IPlayerSay( SayParameters@ _params )
        {
            @this.params = _params;
        }
    }

    namespace OnPlayerSay
    {
        class HookPlayerSay : Hook
        {
            HookPlayerSay( const string &in name )
            {
                super(name);
            }

            void Register()
            {
                g_Hooks.RegisterHook( Hooks::Player::ClientSay, @Hooks::OnPlayerSay::ClientSay );
                Hook::Register();
            }
        }

        void Register()
        {
            g_MKExtensionManager.RegisterHook( @HookPlayerSay( "OnPlayerSay" ) );
        }

        HookReturnCode ClientSay( SayParameters@ pParams )
        {
            Hooks::IPlayerSay@ info = Hooks::IPlayerSay(pParams);
            g_MKExtensionManager.CallHook( "OnPlayerSay", @info );

            if( info.code & HookCode::Handle != 0 )
                return HOOK_HANDLED;

            return HOOK_CONTINUE;
        }
    }
}
