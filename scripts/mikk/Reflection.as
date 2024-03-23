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

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk" );
    g_Module.ScriptInfo.SetContactInfo( Mikk.GetContactInfo() );
    g_Reflection.CallFunction( 'PluginInit' );
}

void MapInit()
{
    g_Reflection.CallFunction( 'MapInit' );
}

void MapActivate()
{
    g_Reflection.CallFunction( 'MapActivate' );
}

void MapStart()
{
    g_Reflection.CallFunction( 'MapStart' );
}

Reflection@ g_Reflection;

final class Reflection
{
    void CallFunction( const string& in m_iszFunction )
    {
        uint GlobalCount = Reflection::g_Reflection.Module.GetGlobalFunctionCount();

        for( uint i = 0; i < GlobalCount; i++ )
        {
            Reflection::Function@ m_fFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( m_fFunction !is null && m_fFunction.GetName() == m_iszFunction && !m_fFunction.GetNamespace().IsEmpty() )
            {
                m_fFunction.Call();
                g_Game.AlertMessage( at_console, '[Reflection] Called '+'"' + m_fFunction.GetNamespace() + '::' + m_fFunction.GetName() + '"' + '\n' );
            }
        }
    }
}