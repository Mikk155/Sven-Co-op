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

namespace Hooks
{
    class Info
    {
        HookCode code = HookCode::Continue;

        Info() { }
    }

    class InfoExtensionInit : Info
    {
        int ExtensionIndex;
    }

    class InfoMapActivate : Info
    {
        int NumberOfEntities;
    }

    class InfoMapChange : Info
    {
        private string __NextMap__;

        const string& NextMap {
            get const { return this.__NextMap__; }
        }

        InfoMapChange( const string& in szNextMap )
        {
            __NextMap__ = szNextMap;
        }
    }

    HookReturnCode OnMapChange( const string& in szNextMap )
    {
        Hooks::InfoMapChange@ info = Hooks::InfoMapChange(szNextMap);
        g_MKExtensionManager.CallHook( "OnMapChange", @info );

        if( info.code & HookCode::Handle != 0 )
            return HOOK_HANDLED;
        return HOOK_CONTINUE;
    }

    class InfoClientSay : Info
    {
        SayParameters@ params;
    }

    HookReturnCode OnClientSay( SayParameters@ pParams )
    {
        Hooks::InfoClientSay@ info = Hooks::InfoClientSay();
        @info.params = pParams;
        g_MKExtensionManager.CallHook( "OnClientSay", @info );

        if( info.code & HookCode::Handle != 0 )
            return HOOK_HANDLED;
        return HOOK_CONTINUE;
    }

    namespace Garbage
    {
        class MKExtensionThinker : ScriptBaseEntity
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
                g_MKExtensionManager.CallHook( "OnThink", @Info() );
                self.pev.nextthink = g_Engine.time;
            }
        }

        void MapInit()
        {
            if( g_MKExtensionManager.HookOnThinkEnabled )
            {
                g_CustomEntityFuncs.RegisterCustomEntity( "Hooks::Garbage::MKExtensionThinker", "MKExtensionThinker" );
            }

            g_MKExtensionManager.CallHook( "OnMapInit", @Info() );
        }

        void MapActivate()
        {
            InfoMapActivate@ info = InfoMapActivate();
            info.NumberOfEntities = g_EngineFuncs.NumberOfEntities();
            g_MKExtensionManager.CallHook( "OnMapActivate", @info );

            if( g_MKExtensionManager.HookOnThinkEnabled )
            {
                g_EntityFuncs.CreateEntity( "MKExtensionThinker", null, true );
            }
        }
    }
}
