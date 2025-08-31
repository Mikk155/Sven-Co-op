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

#if DEBUG

using System.Reflection;
using System.Text;
using System.Xml.Linq;

public class PyExportAPI
{
    public readonly Logger logger = new Logger( "Python API", ConsoleColor.Blue );

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

    public PyExportAPI()
    {
        logger.info( $"Generating API for python scripting Type Hints" );

        Summary = XDocument.Load( Path.Combine( Directory.GetCurrentDirectory(), "bin", "Debug", "net9.0", "MapUpgrader.xml" ) ).Descendants( "member" )
            .Where( m => m.Attribute( "name" ) != null )
            .ToDictionary( m => m.Attribute( "name" )!.Value, m => (string?)m.Element( "summary" ) ?? ""
        );
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

        string? classDoc = MemberSummary(t);

        if( !string.IsNullOrEmpty( classDoc ) )
        {
            f.AppendLine( $"\t'''{classDoc}'''" );
        }

        foreach( PropertyInfo prop in t.GetProperties() )
        {
            string? doc = MemberSummary( prop );

            f.AppendLine( $"\t{prop.Name}: {MapType(prop.PropertyType)}" );

            if( !string.IsNullOrEmpty( doc ) )
            {
                f.AppendLine($"\t'''{doc}'''");
            }
        }

        foreach( var method in t.GetMethods( BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly ) )
        {
            if( method.IsSpecialName )
            {
                continue;
            }

            string args = string.Join( ", ", method.GetParameters()
                .Select( p => $"{p.Name}: {MapType(p.ParameterType)}" )
            );

            if( !string.IsNullOrEmpty( args ) )
            {
                args = ", " + args;
            }

            string? doc = MemberSummary(method);

            if( !string.IsNullOrEmpty( doc ) )
            {
                f.AppendLine($"\tdef {method.Name}(self{args}) -> {MapType(method.ReturnType)}: '''{doc}'''" );
            }
            else
            {
                f.AppendLine($"\tdef {method.Name}(self{args}) -> {MapType(method.ReturnType)}: ..." );
            }
        }

        string PyAPI = Path.Combine( Directory.GetCurrentDirectory(), "Upgrades", "netapi", $"{PythonScript}.py" );
        logger.info( $"Generated {PyAPI}" );
        File.WriteAllText( PyAPI, f.ToString() );
    }

    private string MapType( Type type )
    {
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
        if( type == typeof( string[] ) )
            return "list[str]";
        if( type == typeof( Vector ) )
            return "Vector";
        return "Any";
    }
}

#endif
