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

    Mikk.Json.ReadJsonFile( "plugins/chatbridge/chatbridge", pJson );

    g_Reflection.CallFunction( 'PluginInit' );
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"PluginInit"+'\n' );
}

void MapInit()
{
    g_Reflection.CallFunction( 'MapInit' );
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapInit"+'\n' );
}

void MapActivate()
{
    g_Reflection.CallFunction( 'MapActivate' );
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapActivate"+'\n' );
}

void MapStart()
{
    g_Reflection.CallFunction( 'MapStart' );
    g_Game.AlertMessage( at_console, '[Reflection] Called '+"MapStart"+'\n' );
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