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
#include "main"
#endif

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
        g_Logger.trace( "Registered hook \"" + this.GetName() + "\" for \"" + this.Owner.GetName() + "\" method index " + this.Index );
    }
}

final class MKExtensionManager : Reflection
{
    MKExtensionManager() { }
    ~MKExtensionManager() { }

    private bool TemporalVariableToDisableGlobally;

    bool IsActive()
    {
        if( TemporalVariableToDisableGlobally )
            return false;

        return true;
    }

    // List containing all the plugin's hooks
    private array<Hooks::Hook@> m_Hooks = {};

    // List containing all the extensions
    private array<MKExtension@> m_Extensions = {};

    private Hooks::Hook@ FirstOrNullHook( const string &in Name )
    {
        for( uint ui = 0; ui < m_Hooks.length(); ui++ )
        {
            Hooks::Hook@ hHook = m_Hooks[ui];

            if( hHook.GetName() == Name )
            {
                return @hHook;
            }
        }
        return null;
    }

    void RegisterHook( Hooks::Hook@ hHook )
    {
        if( FirstOrNullHook( hHook.GetName() ) !is null )
        {
            g_Logger.critical( "Hook with name \"" + hHook.GetName() + "\" is already registered!" );
            return;
        }

        m_Hooks.insertLast( @hHook );
    }

    void RegisterAllHooks()
    {
        g_Logger.info( "Loading Hooks" );

        // This being at the first index is important.
        this.RegisterHook( @Hooks::Hook( "OnExtensionInit" ) );
        // Same goes for PluginInit. these two are removed from the array after used.
        this.RegisterHook( @Hooks::Hook( "OnPluginInit" ) );

        for( uint ui = 0; ui < MaxMethods; ui++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( ui );

            if( Func is null )
                continue;

            if( Func.GetName() != "Register" )
                continue;

            if( !Func.GetNamespace().StartsWith( "Hooks::" ) )
                continue;

            g_Logger.trace( "Calling \"" + Func.GetNamespace() + "::Register()\"" );

            Func.Call();
        }
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
                g_Logger.error( "Fail registration of extension \"" + ExtensionName + "\"\nRegister the extension in MKExtension/Extensions/main.as" );
                continue;
            }

            MKExtension@ pExtension = MKExtension( ExtensionName );

            m_Extensions.insertLast( @pExtension );
            g_Logger.info( "Registered extension \"" + ExtensionName + "\" at index " + this.Count );
        }

        if( this.Count == 0 )
        {
            this.TemporalVariableToDisableGlobally = true;
            g_Logger.critical( "No extensions loaded! Disabling plugin..." );
            return;
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

            Hooks::Hook@ pHook = this.FirstOrNullHook( Func.GetName() );

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

            Hooks::IExtensionInit@ info = Hooks::IExtensionInit( ui + 1 );
            Func.Call( @info );
        }

        m_Hooks.removeAt(0); // OnExtensionInit

        this.CallHook( "OnPluginInit", @Hooks::IHookInfo() );

        m_Hooks.removeAt(0); // OnPluginInit

        g_Logger.info( "Registering Hooks" );

        for( uint ui = 0; ui < m_Hooks.length(); ui++ )
        {
            Hooks::Hook@ pHook = m_Hooks[ui];

            if( pHook.Callables.length() > 0 )
            {
                pHook.Register();
                continue;
            }

            g_Logger.trace( "Removed unused hook \"" + pHook.GetName() + "\" to free some memory" );
            m_Hooks.removeAt(ui);
            ui--;
        }
    }

    int CallHook( const string&in HookName, Hooks::IHookInfo@ info )
    {
        if( !this.IsActive() )
            return -1;

        int ActionPostHook = HookCode::Continue;

        Hooks::Hook@ pHook = this.FirstOrNullHook( HookName );

        if( pHook is null )
        {
            g_Logger.warn( "Unknown hook \"" + HookName + "\"" );
            return -1;
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

            Func.Call( @info );

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
