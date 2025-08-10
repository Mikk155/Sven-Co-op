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
*
*   Credits:
*        Original script by Gaftherman.
**/

bool reflection_register = g_RegisterReflection();

bool g_RegisterReflection()
{
    Reflection reflect();
    @g_Reflection = @reflect;
    return true;
}

Reflection@ g_Reflection;

class Reflection
{
    uint MaxMethods
    {
        get const { return Reflection::g_Reflection.Module.GetGlobalFunctionCount(); }
    }

    private uint __FakeIteration__ = 0;

    Reflection::Function@ GetFunctionByName( const string&in fnName, bool IgnoreNamespace = false )
    {
        for( ; this.__FakeIteration__ < this.MaxMethods; this.__FakeIteration__++ )
        {
            Reflection::Function@ Func = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( this.__FakeIteration__ );

            if( Func !is null )
            {
                string MethodName = Func.GetName();

                if( !IgnoreNamespace && !Func.GetNamespace().IsEmpty() )
                {
                    snprintf( MethodName, "%1::%2", Func.GetNamespace(), MethodName );
                }

                if( fnName == MethodName )
                {
                    return Func;
                }
            }
        }
        this.__FakeIteration__ = 0;
        return null;
    }

    int CallNamespaces( const string&in fnName )
    {
        int iFunctions = 0;

        for( uint i = 0; i < this.MaxMethods; i++ )
        {
            Reflection::Function@ m_fFunction = Reflection::g_Reflection.Module.GetGlobalFunctionByIndex( i );

            if( m_fFunction !is null && m_fFunction.GetName() == fnName && !m_fFunction.GetNamespace().IsEmpty() )
            {
                iFunctions++;
                m_fFunction.Call();
            }
        }
        return iFunctions;
    }
}
