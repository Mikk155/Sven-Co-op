#include '../../mikk/as_utils'

bool reflection_register = g_RegisterReflection();

bool g_RegisterReflection()
{
    Reflection reflect(); @g_Reflection = @reflect;
    return true;
}

void MapInit()
{
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapInit"+'\n' );
    g_Reflection.CallFunction( 'MapInit' );
}

void MapActivate()
{
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapActivate"+'\n' );
    g_Reflection.CallFunction( 'MapActivate' );
}

void MapStart()
{
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapStart"+'\n' );
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