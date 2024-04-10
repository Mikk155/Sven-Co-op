//==========================================================================================================================================\\
//                                                                                                                                          \\
//                              Creative Commons Attribution-NonCommercial 4.0 International                                                \\
//                              https://creativecommons.org/licenses/by-nc/4.0/                                                             \\
//                                                                                                                                          \\
//   * You are free to:                                                                                                                     \\
//      * Copy and redistribute the material in any medium or format.                                                                       \\
//      * Remix, transform, and build upon the material.                                                                                    \\
//                                                                                                                                          \\
//   * Under the following terms:                                                                                                           \\
//      * You must give appropriate credit, provide a link to the license, and indicate if changes were made.                               \\
//      * You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.                   \\
//      * You may not use the material for commercial purposes.                                                                             \\
//      * You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.     \\
//                                                                                                                                          \\
//==========================================================================================================================================\\

bool reflection_register = g_RegisterReflection();

bool g_RegisterReflection()
{
    Reflection reflect(); @g_Reflection = @reflect;
    return true;
}

const uint MAX_FUNCTIONS = Reflection::g_Reflection.Module.GetGlobalFunctionCount();

Reflection@ g_Reflection;

final class Reflection
{
    /*
        @prefix g_Reflection.CallFunction CallFunction Reflection
        @body g_Reflection
        Calls a function globaly in all namespaces. Returns the number of functions called.
    */
    int Call( const string m_iszFunction )
    {
        int f = 0;

        for( uint i = 0; i < MAX_FUNCTIONS; i++ )
        {
            Reflection::Function@ m_fFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( m_fFunction !is null && !m_fFunction.GetNamespace().IsEmpty() && m_fFunction.GetName() == m_iszFunction )
            {
                f++;
                // g_Game.AlertMessage( at_console, '[Reflection] Called '+'"' + m_fFunction.GetNamespace() + '::' + m_fFunction.GetName() + '"' + '\n' );
                m_fFunction.Call();
            }
        }
        return f;
    }

    protected array<string> Functions(MAX_FUNCTIONS);

    protected bool IsInitialised = false;

    protected void Initialise()
    {
        for( uint i = 0; i < MAX_FUNCTIONS; i++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( Func !is null )
            {
                Functions.insertAt( i, ( Func.GetNamespace().IsEmpty() ? '' : Func.GetNamespace() + '::' ) + Func.GetName() );
            }
        }
    }

    /*
        @prefix g_Reflection.opIndex g_Reflection.Get g_Reflection.Function
        @body g_Reflection
        Get a script function by name or namespace::name
    */
    Reflection::Function@ opIndex( string m_iszFunction )
    {
        if( !IsInitialised )
        {
            Initialise();
        }

        if( Functions.find( m_iszFunction ) < 0 )
        {
            g_Game.AlertMessage( at_console, '[Reflection] GetFunction Couldn\'t find function "' + m_iszFunction + '"\n' );
            return null;
        }
        // g_Game.AlertMessage( at_console, '[Reflection] GetFunction "' + Functions[ Functions.find( m_iszFunction ) ] + '" (' + Functions.find( m_iszFunction ) + ')\n' );
        return Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( Functions.find( m_iszFunction ) );
    }
}
