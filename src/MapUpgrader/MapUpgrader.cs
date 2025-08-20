/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*    Copyright (c) 2006-2017 the contributors of the "Python for .NET" project
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

/**
*   Special thanks to Nick Proud for introduction
*       https://www.youtube.com/watch?v=1sOTTXlIhZo
*
*   https://github.com/pythonnet/pythonnet
**/

using Python.Runtime;

class Program
{
    private static string Workspace =>
        Directory.GetCurrentDirectory();

    static void RunScript( string pyname )
    {
        Console.WriteLine( $"Loading module {Path.Combine( Workspace, "Upgrades", pyname )}.py" );

        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, Path.Combine( Workspace, "Upgrades" ) );

            PyObject Script = Py.Import( pyname );
            Console.WriteLine( Script.GetAttr( "__file__" ) );
            dynamic main = Script.GetAttr( "main" );
            PyObject result = main.Invoke();
            Console.WriteLine( result );
        }
    }

    static void Main()
    {
        // -TODO Ask user
        Runtime.PythonDLL = @"C:\Users\Usuario\AppData\Local\Programs\Python\Python311\python311.dll";
        PythonEngine.Initialize();
        Console.WriteLine( $"Hello world from CSharp!" );
        RunScript( "HelloWorld" );
    }
}
