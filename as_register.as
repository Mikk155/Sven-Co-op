#include 'as_utils'

bool reflection_register = g_RegisterReflection();

bool g_RegisterReflection()
{
    Reflection reflect(); @g_Reflection = @reflect;
    return true;
}

void MapInit()
{
    m_Debug.Server('[Reflection] Called '+"MapInit" );
    g_Reflection.CallFunction( 'MapInit' );
}

void MapActivate()
{
    m_Debug.Server('[Reflection] Called '+"MapActivate" );
    g_Reflection.CallFunction( 'MapActivate' );
}

CScheduledFunction@ g_MapLoadRef = g_Scheduler.SetTimeout( 'MapLoad', 0.0 );

void MapLoad()
{
    m_Debug.Server('[Reflection] Called '+"MapLoad" );
    g_Reflection.CallFunction( 'MapLoad' );
}

void MapStart()
{
    m_Debug.Server('[Reflection] Called '+"MapStart" );
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
                m_Debug.Server('[Reflection] Called '+'"' + m_fFunction.GetNamespace() + '::' + m_fFunction.GetName() + '"' );
            }
        }
    }
}