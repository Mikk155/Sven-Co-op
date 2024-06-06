bool reflection_register = g_RegisterReflection();

bool g_RegisterReflection()
{
    Reflection reflect(); @g_Reflection = @reflect;
    return true;
}

const uint MAX_FUNCTIONS = Reflection::g_Reflection.Module.GetGlobalFunctionCount();

Reflection@ g_Reflection;

class Reflection
{
    int Call( const string m_iszFunction )
    {
        int f = 0;

        for( uint i = 0; i < MAX_FUNCTIONS; i++ )
        {
            Reflection::Function@ m_fFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( m_fFunction !is null && !m_fFunction.GetNamespace().IsEmpty() && m_fFunction.GetName() == m_iszFunction )
            {
                f++;
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
        IsInitialised = true;
    }

    Reflection::Function@ opIndex( string m_iszFunction )
    {
        if( !IsInitialised )
        {
            Initialise();
        }

        if( Functions.find( m_iszFunction ) < 1 )
        {
            g_EngineFuncs.ServerPrint( '[Reflection] Couldn\'t find function "' + m_iszFunction + '"\n' );
            return null;
        }
        // g_Game.AlertMessage( at_console, '[Reflection] GetFunction "' + Functions[ Functions.find( m_iszFunction ) ] + '" (' + Functions.find( m_iszFunction ) + ')\n' );
        return Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( Functions.find( m_iszFunction ) );
    }

    CScheduledFunction@ SetTimeOut( string &in szFunction, float flTime )
    {
        return @g_Scheduler.SetTimeout( this, 'SetTimeOutPost', flTime, szFunction );
    }

    void SetTimeOutPost( string &in szFunction )
    {
        if( this[ szFunction ] !is null )
            this[ szFunction ].Call();
    }
}
