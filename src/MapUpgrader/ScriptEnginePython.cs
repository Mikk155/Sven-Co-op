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

using Mikk.Logger;
using Python.Runtime;

#if DEBUG
using Mikk.PythonNET;
using System.Text;
using System.Diagnostics;
using System.IO;
#endif // DEBUG

#if DEBUG
public static class PythonNET
{
    /// <summary>Get a key's value in string form</summary>
    public static void GenerateFile( this TypeHint typehint, Type type, string filename, StringBuilder? StringBuilder = null )
    {
        TypeHint.logger.info
            .Write( "Generating API class " )
            .Write( type.Name, ConsoleColor.Green )
            .Write( " for file " )
            .Write( filename, ConsoleColor.Cyan )
            .NewLine();

        if( StringBuilder is null )
        {
            StringBuilder = new StringBuilder();
        }

        StringBuilder.Insert( 0, $"'''\n{File.ReadAllText( Path.Combine( Directory.GetCurrentDirectory(), "LICENSE_MAPUPGRADER" ) )}\n'''\n\n" );

        StringBuilder.AppendLine( "from typing import Any, Optional;" );

        File.WriteAllText( Path.Combine( Directory.GetCurrentDirectory(), ScriptEngine.ScriptingFolder, "netapi", $"{filename}.py" ),
            typehint.Generate( type, StringBuilder ) );
    }

    public static void UpdateThirdPartyDocument( this TypeHint typehint, string projectName, string projectPath )
    {
        string CSProjPath = Path.Combine( projectPath, $"{projectName}.csproj" );

        if( !File.Exists( CSProjPath ) )
        {
            TypeHint.logger.error
                .Write( "Invalid csproj at " )
                .Write( CSProjPath, ConsoleColor.Green )
                .NewLine();
            return;
        }

        TypeHint.logger.info
            .Write( "Compiling " )
            .Write( projectName, ConsoleColor.Green )
            .Write( " to generate a XML document" )
            .Write( CSProjPath, ConsoleColor.Cyan )
            .NewLine();

        ProcessStartInfo terminal = new ProcessStartInfo
        {
            FileName = "dotnet",
            Arguments = $"build \"{CSProjPath}\" -c Debug /p:GenerateDocumentationFile=true",
            UseShellExecute = true
        };

        using Process proc = Process.Start( terminal )!;

        proc.WaitForExit();

        typehint.LoadDocument( Path.Combine( projectPath, "bin", "Debug", Program.FrameworkVersion, $"{projectName}.xml" ) );
    }
}
#endif // DEBUG

public class PythonLanguage : ILanguageEngine
{
    public static readonly Logger logger = new Logger( "Python", ConsoleColor.DarkYellow );

    public string GetName() => "Python";

    public void Shutdown()
    {
        PythonLanguage.logger.debug.WriteLine( "Shutting down" );

        try
        {
            PythonEngine.Shutdown();
            PythonEngine.InteropConfiguration = Python.Runtime.InteropConfiguration.MakeDefault();
        } // Runtime.Shutdown(); raises exception. find updates later or fork my own (If not embedable python is used later)
        catch {}
    }

    public PythonLanguage()
    {
#if DEBUG // Generate docs for python Type hints
        TypeHint PythonAPIGen = new TypeHint(
            Path.Combine( Directory.GetCurrentDirectory(), "bin", "Debug", Program.FrameworkVersion, "MapUpgrader.xml" )
        );

        // Assets.py
        PythonAPIGen.MapTypeList[ typeof(List<string>) ] = "list[str]";
        PythonAPIGen.MapTypeList[ typeof(Dictionary<string, string>) ] = "dict[str, str]";

        // UpgradeContext.py
        PythonAPIGen.MapTypeList[ typeof(Assets) ] = "Assets";
        PythonAPIGen.MapTypeList[ typeof(Logger) ] = "Logger";

        // Vector.py
        PythonAPIGen.MapTypeList[ typeof(Vector) ] = "Vector";

        // Entity.py
        PythonAPIGen.MapTypeList[ typeof(List<KeyValuePair<string, string>>) ] = "list[list[str, str]]";
        PythonAPIGen.MapTypeList[ typeof(IDictionary<string, string>) ] = "dict[str, str]";

#if APIGEN_PROTOTYPE_EXTERNAL
        // Logger.py
        PythonAPIGen.UpdateThirdPartyDocument( "Mikk.Logger",
            Path.Combine( Directory.GetCurrentDirectory(), "..", "..","external", "MikkNET", "Mikk.Logger" )
        );
#endif // APIGEN_PROTOTYPE_EXTERNAL

        PythonAPIGen.GenerateFile( typeof(UpgradeContext), "UpgradeContext", new StringBuilder()
            .AppendLine( "from netapi.Assets import Assets;" )
            .AppendLine( "from netapi.Logger import Logger;" )
        );

        PythonAPIGen.GenerateFile( typeof(Assets), "Assets" );

        PythonAPIGen.GenerateFile( typeof(Vector), "Vector" );

        PythonAPIGen.GenerateFile( typeof(Sledge.Formats.Bsp.Objects.Entity), "Entity", new StringBuilder()
            .AppendLine( "from netapi.Vector import Vector;" )
        );

        PythonAPIGen.GenerateFile( typeof(Logger), "Logger" );
#endif // DEBUG

        ConfigContext.Get( "python_dll", value =>
        {
            Runtime.PythonDLL = value;
            return true; // No exception raised. break the loop
        }, "Absolute path to your Python dll, it usually looks like \"C:\\Users\\Usuario\\AppData\\Local\\Programs\\Python\\Python311\\python311.dll\" You can drag and drop the dll too." );

        PythonEngine.Initialize();
    }

    public UpgradeContext? Initialize( string script )
    {
        using ( Py.GIL() )
        {
            dynamic sys = Py.Import( "sys" );
            sys.path.insert( 0, Path.Combine( Directory.GetCurrentDirectory(), ScriptEngine.ScriptingFolder ) );

            try
            {
                PyObject Script = Py.Import( Path.GetFileNameWithoutExtension( script ) );

                if( !Script.HasAttr( ScriptEngine.HookName_Init ) )
                {
                    throw new MissingMemberException( $"Script {Path.GetFileName( script )} doesn't implements the \"{ScriptEngine.HookName_Init}\" method" );
                }

                PyObject OnRegister = Script.GetAttr( ScriptEngine.HookName_Init );

                if( !OnRegister.IsCallable() )
                {
                    throw new InvalidDataException( $"Method \"{ScriptEngine.HookName_Init}\" is not a callable method" );
                }

                UpgradeContext context = new UpgradeContext( this, script );

                PyObject? result = OnRegister.Invoke( context.ToPython() );

                context.Initialize();

                return context;
            }
            catch( Exception exception )
            {
                PythonLanguage.logger.error
                    .Write( "Exception thrown by the script \"" )
                    .Write( Path.GetFileName( script ) )
                    .Write( "\"" )
                    .NewLine()
                    .Write( "Error: " )
                    .Write( exception.Message, ConsoleColor.Red )
                    .NewLine()
                    .Write( exception.StackTrace, ConsoleColor.Yellow )
                    .NewLine();
            }
            return null;
        }
    }
}
