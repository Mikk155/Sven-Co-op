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
    namespace OnMapThink
    {
        bool IsEnabled = false;

        void MapInit()
        {
            if( IsEnabled )
            {
                g_CustomEntityFuncs.RegisterCustomEntity( "Hooks::OnMapThink::OnMapThinkEntity", "mke_hook_onmapthink" );
            }
        }

        void MapActivate()
        {
            if( IsEnabled )
            {
                g_EntityFuncs.CreateEntity( "mke_hook_onmapthink", null, true );
            }
        }

        class HookMapThink : Hook
        {
            HookMapThink( const string &in name )
            {
                super(name);
            }

            void Register()
            {
                IsEnabled = true;
                Hook::Register();
            }
        }

        void Register()
        {
            g_MKExtensionManager.RegisterHook( @HookMapThink( "OnMapThink" ) );
        }

        class OnMapThinkEntity : ScriptBaseEntity
        {
            void Spawn()
            {
                self.pev.solid = SOLID_NOT;
                self.pev.movetype = MOVETYPE_NONE;

                SetThink( ThinkFunction( this.Think ) );
                self.pev.nextthink = g_Engine.time;
            }

            void Think()
            {
                g_MKExtensionManager.CallHook( "OnMapThink", @IHookInfo() );
                self.pev.nextthink = g_Engine.time;
            }
        }
    }
}
