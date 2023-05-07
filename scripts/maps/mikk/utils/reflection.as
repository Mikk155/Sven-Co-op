// Rename to "Register" your "MapInit" function and it'll be called as it normaly was MapInit.
void MapInit()
{
    g_Reflection.TriggerFunction( 'Register' );
}

bool reflection_blregister = reflection_register();
bool reflection_register()
{
    Reflection reflect(); @g_Reflection = @reflect;
    g_Reflection.TriggerFunction( 'MapPreInit' );
    return true;
}

Reflection@ g_Reflection;

final class Reflection
{
    array<any@> TriggerFunction( string strNameFunction )
    {
        uint GlobalCount = Reflection::g_Reflection.Module.GetGlobalFunctionCount();
        array<any@> AnyValues;

        for( uint i = 0; i < GlobalCount; i++ )
        {
            Reflection::Function@ fNameFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( strNameFunction != fNameFunction.GetName() || fNameFunction.GetNamespace().IsEmpty() )
                continue;

            AnyValues.insertLast(fNameFunction.Call().ToAny());
        }

        return AnyValues;
    }

    array<any@> TriggerFunction( string strNameFunction, array<string> strOrder )
    {
        uint GlobalCount = Reflection::g_Reflection.Module.GetGlobalFunctionCount();
        array<uint> Missings, Ejecuted;
        array<any@> AnyValues;

        for( uint i = 0; i < strOrder.length(); i++ )
        {
            for( uint j = 0; j < GlobalCount; j++ )
            {
                Reflection::Function@ fNameFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( j );

                if( strNameFunction != fNameFunction.GetName() )
                    continue;

                if( fNameFunction.GetNamespace() == strOrder[i] )
                {
                    AnyValues.insertLast(fNameFunction.Call().ToAny());
                    Ejecuted.insertLast(j);
                }
                else if( !fNameFunction.GetNamespace().IsEmpty() && Missings.find(j) == -1 )
                {
                    Missings.insertLast( j );
                }
            }
        }

        for( uint i = 0; i < Ejecuted.length(); i++ )
        {
            for( uint j = 0; j < Missings.length(); j++ )
            {
                if( Ejecuted[i] == Missings[j] )
                    Missings.removeAt( j );
            }
        }

        for( uint i = 0; i < Missings.length(); i++ )
        {
            Reflection::Function@ fNameFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( Missings[i] );

            if( strNameFunction == fNameFunction.GetName() && !fNameFunction.GetNamespace().IsEmpty() )
                AnyValues.insertLast(fNameFunction.Call().ToAny());
        }

        return AnyValues;
    }

    array<any@> TriggerFunction( string strNameFunction, string strNameSpace, Reflection::Arguments@ pArguments = null )
    {
        uint GlobalCount = Reflection::g_Reflection.Module.GetGlobalFunctionCount();
        array<any@> AnyValues;

        for( uint i = 0; i < GlobalCount; i++ )
        {
            Reflection::Function@ fNameFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( strNameSpace.IsEmpty() )
            {
                if( !fNameFunction.GetNamespace().IsEmpty() && strNameFunction == fNameFunction.GetName() )
                {
                    AnyValues.insertLast( (pArguments is null) ? fNameFunction.Call().ToAny() : fNameFunction.Call(pArguments).ToAny());
                }
            }
            else
            {
                if( strNameFunction == fNameFunction.GetName() && strNameSpace == fNameFunction.GetNamespace() )
                {
                    AnyValues.insertLast( (pArguments is null) ? fNameFunction.Call().ToAny() : fNameFunction.Call(pArguments).ToAny());
                }
            }
        }

        return AnyValues;
    }

    int ToInt( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0\n" );
            return 0;
        }

        int intValue; 
        AnyValue.retrieve( intValue );
        return intValue;
    }

    int64 ToInt64( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0\n" );
            return 0;
        }

        int64 int64Value; 
        AnyValue.retrieve( int64Value );
        return int64Value;
    }

    uint ToUint( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0\n" );
            return 0;
        }

        uint uintValue; 
        AnyValue.retrieve( uintValue );
        return uintValue;
    }

    uint64 ToUint64( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0\n" );
            return 0;
        }

        uint64 uint64Value; 
        AnyValue.retrieve( uint64Value );
        return uint64Value;
    }

    float ToFloat( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0.0\n" );
            return 0.0;
        }

        float floatValue; 
        AnyValue.retrieve( floatValue );
        return floatValue;
    }

    bool Tobool( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default false\n" );
            return false;
        }

        bool boolValue; 
        AnyValue.retrieve( boolValue );
        return boolValue;
    }

    string ToString( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default ''\n" );
            return false;
        }

        string stringValue; 
        AnyValue.retrieve( stringValue );
        return stringValue;
    }

    double ToDouble( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default 0.0\n" );
            return 0.0;
        }

        double doubleValue; 
        AnyValue.retrieve( doubleValue );
        return doubleValue;
    }

    EHandle ToEntity( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default null\n" );
            return EHandle(null);
        }

        EHandle EhandleValue = EHandle(null); 
        AnyValue.retrieve( EhandleValue );
        return EhandleValue;
    }

    dictionary@ ToDictionary( any@ AnyValue )
    {
        if( AnyValue is null )
        {
            g_Game.AlertMessage( at_console, "!!!ERROR: The function doesn't exist and can't return a value - default null\n" );
            return null;
        }

        dictionary dictionaryValues; 
        AnyValue.retrieve( dictionaryValues );
        return dictionaryValues;
    }
}