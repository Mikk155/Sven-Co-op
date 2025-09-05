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

using Python.Runtime;

#if DEBUG
using System.Reflection;
using System.Text;
using System.Xml.Linq;
#endif

public class PythonLanguage : ILanguageEngine
{
    public static readonly Logger logger = new Logger( "Python", ConsoleColor.DarkYellow );

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

    public PythonLanguage()
    {
        ConfigContext config = new ConfigContext();

#if DEBUG // Generate docs for python Type hints
        new PyExportAPI();
#endif

        config.Get( "python_dll", value =>
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
            sys.path.insert( 0, Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" ) );

            PyObject Script = Py.Import( Path.GetFileNameWithoutExtension( script ) );

            try
            {
                if( !Script.HasAttr( ILanguageEngine.InitializationMethod ) )
                {
                    throw new MissingMemberException( $"Script {Path.GetFileName( script )} doesn't implements the \"{ILanguageEngine.InitializationMethod}\" method" );
                }

                PyObject OnRegister = Script.GetAttr( ILanguageEngine.InitializationMethod );

                if( !OnRegister.IsCallable() )
                {
                    throw new InvalidDataException( $"Method \"{ILanguageEngine.InitializationMethod}\" is not a callable method" );
                }

                UpgradeContext context = new UpgradeContext( this, script );

                PyObject? result = OnRegister.Invoke( context.ToPython() );

                ArgumentNullException.ThrowIfNull( context.mod );
                ArgumentNullException.ThrowIfNull( context.urls );
                ArgumentNullException.ThrowIfNull( context.title );

                return context;
            }
            catch( Exception exception )
            {
                PythonLanguage.logger.error( $"[Python Engine] Exception thrown by the script \"{Path.GetFileName( script )}\"\nError: {exception.Message}\n{exception.StackTrace}" );
            }
            return null;
        }
    }
}

#if DEBUG

public class PyExportAPI
{
    public static readonly Logger logger = new Logger( "Python API", ConsoleColor.Blue );

    private readonly Dictionary<string, string> Summary;

    private string MemberParameters( MethodInfo member )
    {
        var parameters = member.GetParameters().Select( p => p.ParameterType.FullName );

        if( parameters is not null && parameters.Count() > 0 )
        {
            return $"M:{member.DeclaringType?.FullName}.{member.Name}({string.Join( ",", parameters ).Trim()})";
        }

        return $"M:{member.DeclaringType?.FullName}.{member.Name}";
    }

    private string? MemberSummary( MemberInfo member )
    {
        string key = member.MemberType switch
        {
            System.Reflection.MemberTypes.TypeInfo => $"T:{member.DeclaringType?.FullName}",
            System.Reflection.MemberTypes.Property => $"P:{member.DeclaringType?.FullName}.{member.Name}",
            System.Reflection.MemberTypes.Method => MemberParameters((MethodInfo)member),
            System.Reflection.MemberTypes.Field => $"F:{member.DeclaringType?.FullName}.{member.Name}",
            _ => ""
        };

        return Summary.TryGetValue( key, out var summary ) ? summary.Trim() : null;
    }

    private static IEnumerable<MethodInfo> ExtensionMethods( Type extype )
    {
        return from type in Assembly.GetExecutingAssembly().GetTypes()

            where type.IsSealed && type.IsAbstract && !type.IsGenericType && !type.IsNested

            from method in type.GetMethods( BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic )

            where method.IsDefined( typeof( System.Runtime.CompilerServices.ExtensionAttribute ), false )

            let parameters = method.GetParameters()

            where parameters.Length > 0 && parameters[0].ParameterType == extype

            select method;
    }

    public PyExportAPI()
    {
        PyExportAPI.logger.info( $"Generating API for python scripting Type Hints" );

        Summary = XDocument.Load( Path.Combine( Directory.GetCurrentDirectory(), "bin", "Debug", "net9.0", "MapUpgrader.xml" ) ).Descendants( "member" )
            .Where( m => m.Attribute( "name" ) != null )
            .ToDictionary( m => m.Attribute( "name" )!.Value, m => (string?)m.Element( "summary" ) ?? ""
        );

        this.Generate( typeof(Sledge.Formats.Bsp.Objects.Entity), "Entity" );
        this.Generate( typeof(Vector), "Vector" );
        this.Generate( typeof(UpgradeContext), "UpgradeContext" );
    }

    public void Generate( Type t, string PythonScript )
    {
        StringBuilder f = new StringBuilder();

        f.AppendLine( "from typing import Any" );

        if( t.Name == "Entity" )
        {
            f.AppendLine( "from netapi.Vector import Vector" );
        }

        f.AppendLine();

        f.AppendLine( $"class {t.Name}:" );

        string? class_doc = MemberSummary( t );

        if( !string.IsNullOrEmpty( class_doc ) )
        {
            f.AppendLine($"\t'''{class_doc}'''");
        }

        f.AppendLine();

        foreach( PropertyInfo prop in t.GetProperties() )
        {
            string? doc = MemberSummary( prop );

            if( string.IsNullOrEmpty( doc ) )
            {
                continue;
            }

            f.AppendLine( $"\t{prop.Name}: {MapType(prop.PropertyType, t)}" );
            f.AppendLine($"\t'''{doc}'''");
        }

        foreach( MethodInfo m in ExtensionMethods(t) )
        {
            WriteMethods( f, m, t );
        }

        foreach( MethodInfo m in t.GetMethods(
            BindingFlags.Public |
            BindingFlags.Instance |
            BindingFlags.DeclaredOnly |
            BindingFlags.Static
        ) )
        {
            WriteMethods( f, m, t );
        }

        string PyAPI = Path.Combine( Directory.GetCurrentDirectory(), "Upgrades", "netapi", $"{PythonScript}.py" );
        PyExportAPI.logger.info( $"Generated {PyAPI}" );
        File.WriteAllText( PyAPI, f.ToString() );
    }

    private void WriteMethods( StringBuilder f, MethodInfo m, Type member )
    {
        if( m.IsSpecialName )
        {
            return;
        }

        string? doc = MemberSummary(m);

        if( string.IsNullOrEmpty(doc) )
        {
            return;
        }

        ParameterInfo[] parameters = m.GetParameters();

        if( parameters.Length <= 0 )
        {
//            return;
        }

        string args;

        if( m.IsDefined( typeof( System.Runtime.CompilerServices.ExtensionAttribute ), false ) )
        {
            args = string.Join( ", ", parameters.Skip(1).Select( p => $"{p.Name}: {MapType(p.ParameterType, member)}" ) );
        }
        else
        {
            args = string.Join( ", ", m.GetParameters().Select( p => $"{p.Name}: {MapType(p.ParameterType, member)}" ) );
        }

        if( !string.IsNullOrEmpty( args ) )
        {
            args = ", " + args;
        }

        f.AppendLine($"\tdef {m.Name}(self{args}) -> {MapType(m.ReturnType, member)}:");
        f.AppendLine($"\t\t'''{doc}'''");
    }

    private string MapType( Type type, Type member )
    {
        if( type == member )
            return "Any";
        if( type == typeof( string ) )
            return "str";
        if( type == typeof( int ) )
            return "int";
        if( type == typeof( float ) )
            return "float";
        if( type == typeof( void ) )
            return "None";
        if( type == typeof( bool ) )
            return "bool";
        if( type == typeof( Vector ) )
            return "Vector";
        return "Any";
    }
}

#endif
