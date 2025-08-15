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

// Represents an extension's method.
final class MKEHook : NameGetter
{
    private MKExtension@ __Owner__;
    const MKExtension@ Owner {
        get const { return this.__Owner__; }
    }

    private int __Index__;
    const int Index {
        get const { return this.__Index__; }
    }

    MKEHook( const string &in name, int index, MKExtension@ extension )
    {
        this.Name = name;
        this.__Index__ = index;
        @this.__Owner__ = extension;
    }
}

// Represents a global hook
final class HookData : NameGetter
{
    HookData( const string &in name )
    {
        this.Name = name;
        g_Logger.debug( "Registered hook \"" + this.GetName() + "\"" );
    }

    array<MKEHook@> Callables;
}

final class MKExtensionManager : Reflection
{
    bool IsActive()
    {
        return true;
    }

    // a list containing all the plugin's hooks
    private array<HookData@> m_Hooks = {};
    private array<MKExtension@> m_Extensions = {};

    private HookData@ FirstOrNullHook( const string &in Name )
    {
        for( uint ui = 0; ui < m_Hooks.length(); ui++ )
        {
            HookData@ pHook = m_Hooks[ui];

            if( pHook.GetName() == Name )
            {
                return @pHook;
            }
        }
        return null;
    }

    private MKExtension@ FirstOrNullExtension( const string &in Name )
    {
        for( uint ui = 0; ui < m_Extensions.length(); ui++ )
        {
            MKExtension@ pExtension = m_Extensions[ui];

            if( pExtension.GetName() == Name )
            {
                return @pExtension;
            }
        }
        return null;
    }

    private void RegisterHookName( const string &in name )
    {
        m_Hooks.insertLast( @HookData( name ) );
        g_Logger.trace( "Registered hook name \"" + name + "\"" );
    }

    MKExtensionManager()
    {
        g_Logger.info( "Registering Hooks" );

        // This being at the first index is important.
        RegisterHookName( "OnExtensionInit" );

        for( uint fnIndex = 0; fnIndex < MaxMethods; fnIndex++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( fnIndex );

            if( Func !is null && Func.GetNamespace() == "Hooks" )
            {
                RegisterHookName( Func.GetName() );
            }
        }
    }

    private array<string>@ m_temp_plugins = {};

    void Register( const string&in name )
    {
        if( m_temp_plugins.find( name ) > 0 )
        {
            g_Logger.error( "An extension with name \"" + name + "\" already exists!" );
        }
        else
        {
            m_temp_plugins.insertLast( name );
        }
    }

    const uint Count
    {
        get const { return this.m_Extensions.length(); }
    }

    void InitExtensions()
    {
        g_Logger.info( "Registering Extensions" );

        for( uint fnIndex = 0; fnIndex < this.MaxMethods; fnIndex++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( fnIndex );

            if( Func is null )
                continue;

            if( Func.GetName() != "GetName" )
                continue;

            if( !Func.GetNamespace().StartsWith( "Extensions::" ) )
                continue;

            string ExtensionName;

            Reflection::ReturnValue@ ValueReturn = Func.Call();

            if( !ValueReturn.HasReturnValue() )
            {
                g_Logger.error( "Method \""+ Func.GetNamespace() + "::" + Func.GetName() + "\" has no return type of string!" );
                continue;
            }

            any@ ValueAny = ValueReturn.ToAny();

            ValueAny.retrieve( ExtensionName );

            bool result;
            
            // Seems the "find" method checks for the same memory and not if they're equals
            // m_temp_plugins.find( ExtensionName );
            for( uint ui = 0; ui < m_temp_plugins.length(); ui++ )
            {
                if( m_temp_plugins[ui] == ExtensionName )
                {
                    m_temp_plugins.removeAt(ui);
                    result = true;
                    break;
                }
            }

            if( !result )
            {
                g_Logger.error( "Unregistered extension \"" + ExtensionName + "\"\nPlease check MKExtension/Extensions/main.as" );
                continue;
            }

            MKExtension@ pExtension = MKExtension( ExtensionName );

            m_Extensions.insertLast( @pExtension );
            g_Logger.info( "Registered extension \"" + ExtensionName + "\" at index " + this.Count );
        }

        while( m_temp_plugins.length() > 0 )
        {
            g_Logger.error( "Extension \""+ m_temp_plugins[0] + "\" is not being registered!" );
            m_temp_plugins.removeAt(0);
        }
        @m_temp_plugins = null;

        for( uint fnIndex = 0; fnIndex < this.MaxMethods; fnIndex++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( fnIndex );

            if( Func is null )
                continue;

            if( Func.GetNamespace().IsEmpty() )
                continue;

            if( !Func.GetNamespace().StartsWith( "Extensions::" ) )
                continue;;

            HookData@ pHook = this.FirstOrNullHook( Func.GetName() );

            if( pHook is null )
                continue;

            string szLastNameSpace = Func.GetNamespace().SubString( 12 /*"Extensions::"*/ );

            MKExtension@ pExtension = this.FirstOrNullExtension( szLastNameSpace );

            if( pExtension is null )
                continue;

            pHook.Callables.insertLast( MKEHook( pHook.GetName(), fnIndex, @pExtension ) );
        }

        array<MKEHook@>@ Callables = m_Hooks[0].Callables;

        for( uint ui = 0; ui < Callables.length(); ui++ )
        {
            MKEHook@ pHookMethod = Callables[ui];

            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( pHookMethod.Index );

            if( Func is null )
                continue;

            Hooks::InfoExtensionInit@ info = Hooks::InfoExtensionInit();
            info.ExtensionIndex = int(ui) + 1;
            Func.Call( @info );
        }
        m_Hooks.removeAt(0);
    }

    int CallHook( const string&in HookName, Hooks::Info@ info )
    {
        int ActionPostHook = HookCode::Continue;

        if( !this.IsActive() )
            return -1;

        HookData@ pHook = this.FirstOrNullHook( HookName );

        if( pHook is null )
        {
            g_Logger.critical( "Unknown hook \"" + HookName + "\"" );
            return ActionPostHook;
        }

        array<MKEHook@>@ Callables = pHook.Callables;

        for( uint ui = 0; ui < Callables.length(); ui++ )
        {
            MKEHook@ pHookMethod = Callables[ui];

            if( !pHookMethod.Owner.IsActive() )
                continue;

            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( pHookMethod.Index );

            if( Func is null )
                continue;

            Func.Call( info );

            if( info.code == HookCode::Continue )
            {
                continue;
            }

            if( info.code & HookCode::Supercede != 0 )
            {
                ActionPostHook |= HookCode::Supercede;
                g_Logger.warn( "Plugin \"" + pHookMethod.Owner.GetName() + "\" prevented the game's original call for \"" + HookName + "\" " );
            }

            if( info.code & HookCode::Handle != 0 )
            {
                ActionPostHook |= HookCode::Handle;
                g_Logger.warn( "Plugin \"" + pHookMethod.Owner.GetName() + "\" returned HOOK_HANDLED for hook \"" + HookName + "\" " );
            }

            if( info.code & HookCode::Break != 0 )
            {
                ActionPostHook |= HookCode::Break;
                g_Logger.warn( "Plugin \"" + pHookMethod.Owner.GetName() + "\" breaked the chain of calls for hook \"" + HookName + "\"" );
                return ActionPostHook;
            }
        }
        return ActionPostHook;
    }
}

MKExtensionManager g_MKExtensionManager;
