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

#include "../../Mikk155/Reflection"

final class HookData
{
    // Contains the name of the hook, for example "OnMapInit"
    string Name;

    HookData( const string&in name )
    {
        this.Name = name;
        g_Logger.debug( "Registered hook \"" + this.Name + "\"" );
    }

    // Contains the index of the methods this hook should call
    array<uint> PluginHookIndex;
}

final class MKExtensionManager : Reflection
{
    private array<HookData@> m_hooks;

    private int RegisteredPluginIndex = -1;

    int PluginsCount
    {
        get const { return this.RegisteredPluginIndex; }
    }

    MKExtensionManager()
    {
        for( uint fnIndex = 0; fnIndex < MaxMethods; fnIndex++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( fnIndex );

            if( Func !is null && Func.GetNamespace() == "Hooks" )
            {
                m_hooks.insertLast( @HookData( Func.GetName() ) );
            }
        }
    }

    int RegisterHooks( const string&in szNameSpace )
    {
        for( uint fnIndex = 0; fnIndex < MaxMethods; fnIndex++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( fnIndex );

            if( Func is null )
                continue;

            string szMethodNameSpace = Func.GetNamespace();

            if( szMethodNameSpace.IsEmpty() )
                continue;

            if( szMethodNameSpace.Find( szNameSpace ) == String::INVALID_INDEX )
                continue;

            if( !szMethodNameSpace.StartsWith( "Extensions::" ) )
            {
                g_Logger.error( "Error \"" + szMethodNameSpace + "\"Can not register hooks outside of the \"Extensions\" namespace! Make sure your plugin's namespace is also in the \"Extensions\" namespace" );
                return -1;
            }

            for( uint HookIndex = 0; HookIndex < m_hooks.length(); HookIndex++ )
            {
                HookData@ pHookData = m_hooks[HookIndex];

                if( pHookData.Name == Func.GetName() )
                {
                    pHookData.PluginHookIndex.insertLast( fnIndex );
                    g_Logger.trace( "Adding hook callback \"" + szNameSpace + "::" + pHookData.Name + "\"" );
                }
            }
        }

        RegisteredPluginIndex++;
        return RegisteredPluginIndex;
    }

    int CallHook( const string&in HookName, HookInfo@ info )
    {
        int ActionPostHook = HookCode::Continue;

        for( uint HookIndex = 0; HookIndex < m_hooks.length(); HookIndex++ )
        {
            HookData@ pHookData = m_hooks[HookIndex];

            if( pHookData.Name == HookName )
            {
                for( uint fnIndex = 0; fnIndex < pHookData.PluginHookIndex.length(); fnIndex++ )
                {
                    uint CallbackIndex = pHookData.PluginHookIndex[fnIndex];

                    Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( CallbackIndex );

                    if( Func !is null )
                    {
                        Func.Call( info );

                        if( info.code == HookCode::Continue )
                        {
                            continue;
                        }

                        if( info.code & HookCode::Supercede != 0 )
                        {
                            ActionPostHook |= HookCode::Supercede;
//                            g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" prevented the game's original call for \"<()>\" " );
                        }

                        if( info.code & HookCode::Handle != 0 )
                        {
                            ActionPostHook |= HookCode::Handle;
//                            g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" returned HOOK_HANDLED for hook \"<()>\" " );
                        }

                        if( info.code & HookCode::Break != 0 )
                        {
                            ActionPostHook |= HookCode::Break;
//                            g_Logger.warn( "Plugin \"" + plugin.GetName() + "\" breaked the chain of calls for hook \"<()>\"" );
                            return ActionPostHook;
                        }
                    }
                }
            }
        }
        return ActionPostHook;
    }
}

MKExtensionManager g_MKExtensionManager;
