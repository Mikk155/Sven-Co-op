/*
MIT License

Copyright (c) 2025 Mikk155

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

namespace GoldSrc2Sven.engine.python;

using Mikk.Logger;
using Python.Runtime;

using System.Diagnostics;
using System.Runtime.InteropServices;

public class Language : ILanguage
{
    public string ScriptsExtension() {
        return ".py";
    }

    public static readonly Logger logger = new Logger( "Python", ConsoleColor.DarkYellow );

    public string GetName() => "Python";

    public void Shutdown()
    {
        Language.logger.debug.WriteLine( "Shutting down" );

        try
        {
            PythonEngine.Shutdown();
            PythonEngine.InteropConfiguration = Python.Runtime.InteropConfiguration.MakeDefault();
        } // Runtime.Shutdown(); raises exception. find updates later or fork my own (If not embedable python is used later)
        catch {}
    }

    public Language()
    {
#if DEBUG
        new PythonNET(); // Generate docs for python Type hints
#endif // DEBUG

        // Momentary while is not embeded
        if( !App.cache.data.ContainsKey( "python_binary" ) && RuntimeInformation.IsOSPlatform( OSPlatform.Windows ) )
        {
            Language.logger.info.WriteLine( "Attempting to automatically detect a Python installation..." );

            try
            {
                ProcessStartInfo py = new ProcessStartInfo
                {
                    FileName = "python",
                    Arguments = "-c \"import sys; print(sys.executable)\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                ArgumentNullException.ThrowIfNull( py );

                using Process? process = Process.Start( py );

                ArgumentNullException.ThrowIfNull( process );

                string PythonPath = Path.GetDirectoryName( process.StandardOutput.ReadLine() )!;

                process.WaitForExit();

                string[] dll = Directory.GetFiles( PythonPath, "python3*.dll" )
                    .Where( dll => System.Text.RegularExpressions.Regex.IsMatch(Path.GetFileName(dll), @"^python3\d+\.dll$") )
                    .ToArray();

                if( dll.Length > 0 )
                {
                    App.cache.data[ "python_binary" ] = dll[0];
                    App.cache.Write();
                }
            }
            catch {}
        }

        ConfigContext.Get( "python_binary", value =>
        {
            Runtime.PythonDLL = value;
            PythonEngine.Initialize();
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );
    }

    public Context.Upgrade? register_context( string script )
    {
        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, App.FullScriptingFolder );

            try
            {
                PyObject Script = Py.Import( Path.GetFileNameWithoutExtension( script ) );

                Context.Upgrade context = new Context.Upgrade( this, script );

                PyObject? result = Script.GetAttr( "register_context" ).Invoke( context.ToPython() );

                context.Initialize();

                return context;
            }
            catch( Exception exception )
            {
                PyError( exception, script );
            }
            return null;
        }
    }

    public void install_assets( Context.Upgrade context )
    {
        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, App.FullScriptingFolder );

            try
            {
                PyObject Script = Py.Import( Path.GetFileNameWithoutExtension( context.Script ) );
                Script.GetAttr( "install_assets" ).Invoke( context.assets.ToPython() );
            }
            catch( Exception exception )
            {
                PyError( exception, context.Script );
            }
        }
    }

    public void upgrade_map( Context.Map context )
    {
        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, App.FullScriptingFolder );

            try
            {
                PyObject Script = Py.Import( Path.GetFileNameWithoutExtension( context.owner.Script ) );
                Script.GetAttr( "upgrade_map" ).Invoke( context.ToPython() );
            }
            catch( Exception exception )
            {
                PyError( exception, context.owner.Script );
            }
        }
    }

    private void PyError( Exception exception, string path )
    {
        Language.logger.error
            .Write( "Exception thrown by the script \"" )
            .Write( Path.GetFileName( path ) )
            .Write( "\"" )
            .NewLine()
            .Write( "Error: " )
            .Write( exception.Message, ConsoleColor.Red )
            .NewLine()
            .Write( exception.StackTrace, ConsoleColor.Yellow )
            .NewLine();
    }
}
