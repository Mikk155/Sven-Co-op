/*
MIT License

Copyright (c) 2006-2017 the contributors of the "Python for .NET" project

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

using Python.Runtime;

public class PythonLanguage() : ILanguageEngine
{
    public string GetName() => "Python";

    public void Shutdown()
    {
        try
        {
            PythonEngine.Shutdown();
            PythonEngine.InteropConfiguration = Python.Runtime.InteropConfiguration.MakeDefault();
        } // Runtime.Shutdown(); raises exception. find updates later or fork my own (If not embedable python is used later)
        catch {}
    }

    private static string[]? PythonList( PyList list )
    {
        long Length = list.Length();

        if( Length <= 0 )
            return null;

        string[] SharpList = new string[ Length ];

        for( int i = 0; i < Length; i++ )
        {
            SharpList[i] = list[i].As<string>();
        }

        return SharpList;
    }

    public UpgradeContext? Initialize( string script )
    {
        ConfigContext config = new ConfigContext();

        config.Get( "python_dll", value =>
        {
            Runtime.PythonDLL = value;
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );

        PythonEngine.Initialize();

        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" ) );
            sys.path.append( Path.Combine( Directory.GetCurrentDirectory(), "Upgrades", "netapi" ) );

            dynamic Script = Py.Import( Path.GetFileNameWithoutExtension( script ) );

            try
            {
                PyObject result = Script.context();

                PyList ListDownloadURLs = new PyList( result.GetAttr( "urls" ) );

#pragma warning disable CS8601 // Possible null reference assignment.
                UpgradeContext context = new UpgradeContext(){
                    Name = result.GetAttr( "Name" ).ToString(),
                    Description = result.GetAttr( "Description" ).ToString(),
                    Mod = result.GetAttr( "Mod" ).ToString(),
                    urls = PythonList( new PyList( result.GetAttr( "urls" ) ) ),
                    maps = PythonList( new PyList( result.GetAttr( "maps" ) ) )
                };
#pragma warning restore CS8601 // Possible null reference assignment.

                return context;
            }
            catch( Exception exception )
            {
                Console.WriteLine( $"[Python Engine] Exception thrown by the script \"{Path.GetFileName( script )}\"" );
                Console.WriteLine( $"Error: {exception.Message}" );

                if( exception.StackTrace is not null )
                {
                    Console.WriteLine( "Trace:" );
                    Console.WriteLine( exception.StackTrace );
                }
            }
            return null;
        }
    }
}
