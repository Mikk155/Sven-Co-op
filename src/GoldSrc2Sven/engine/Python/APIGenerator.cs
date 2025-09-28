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

#if DEBUG
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Reflection;

using Mikk.Logger;

using GoldSrc2Sven.BSP;

public class PythonNET
{
    public readonly Logger logger = new Logger( "PythonNET Type Hints", ConsoleColor.Yellow );

    public Dictionary<string, string> m_DocStrings = new Dictionary<string, string>();

    public Dictionary<Type, string> MapTypeList = new()
    {
        { typeof(string), "str" },
        { typeof(int), "int" },
        { typeof(float), "float" },
        { typeof(void), "None" },
        { typeof(bool), "bool" },

        { typeof(string[]), "list[str]" },
        { typeof(List<string>), "list[str]" },

        { typeof(Dictionary<string, string>), "dict[str, str]" },

// -TODO Fix circular import by importing Upgrade in within Assets class
//        { typeof(Context.Assets), "Assets" },
        { typeof(Context.Upgrade), "Upgrade" },
        { typeof(Context.Map), "Map" },
        { typeof(Context.CFG), "CFG" },
        { typeof(Context.MapUpgrades), "MapUpgrades" },
        { typeof(Context.IMapUpgrade), "IMapUpgrade" },

        { typeof(Logger), "Logger" },
        { typeof(ConsoleColor), "ConsoleColor" },

        { typeof(Vector), "Vector" },

        { typeof(Entity), "Entity" },
        { typeof(List<Entity>), "list[Entity]" }
    };

    /// <summary>Load a xml document and parse into m_DocStrings</summary>
    /// <param name="XMLDocument">Path to a .xml file for C# summary to Python docstring</param>
    /// <param name="Override">Whatever to clear the summary if not empty</param>
    /// <returns>True if all right</returns>
    public bool LoadDocument( string? XMLDocument, bool Override = false )
    {
        if( !string.IsNullOrEmpty( XMLDocument ) )
        {
            if( File.Exists( XMLDocument ) )
            {
                Dictionary<string, string>? newxml = System.Xml.Linq.XDocument.Load( XMLDocument )
                    .Descendants( "member" )
                    .Where( m => m.Attribute( "name" ) != null && !string.IsNullOrWhiteSpace( m.Element( "summary" )?.Value ) )
                    .ToDictionary( m => m.Attribute( "name" )!.Value, m => m.Element( "summary" )!.Value.TrimStart() );

                if( newxml is null )
                {
                    return false;
                }

                if( Override )
                {
                    this.m_DocStrings = newxml;
                }
                else
                {
                    foreach( KeyValuePair<string, string> kv in newxml )
                    {
                        this.m_DocStrings[ kv.Key ] = kv.Value;
                    }
                }

                return true;
            }
            else
            {
                this.logger.error
                    .Write( "XMLDocument file at path \"" )
                    .Write( XMLDocument, ConsoleColor.Green )
                    .Write( "\" doesn't exists!" )
                    .NewLine();
            }
        }
        else
        {
            this.logger.info.WriteLine( "No XMLDocument specified. Python docstring will not be generated" );
        }

        return false;
    }

    public void WriteMember( StringBuilder strbuild, char type, Type member, Type prop_type, MemberInfo prop )
    {
        strbuild.AppendLine( $"\t{prop.Name}: {this.MapType(prop_type, member)}" );

        if( this.m_DocStrings.TryGetValue( $"{type}:{member.Name}.{prop.Name}", out string? methodsummary ) )
        {
            strbuild.AppendLine( $"\t'''{methodsummary.Trim()}'''" );
        }
    }

    public string Generate( Type type, StringBuilder? strbuild = null )
    {
        if( strbuild is null )
        {
            strbuild = new StringBuilder();
        }
        else
        {
            strbuild.AppendLine();
        }

        if( type.IsEnum )
        {
            strbuild.AppendLine( "from enum import IntEnum;" );
            strbuild.AppendLine();

            strbuild.AppendLine($"class {type.Name}( IntEnum ):");

            foreach( string name in Enum.GetNames( type ) )
            {
                strbuild.AppendLine( $"\t{name} = {Convert.ToInt32( Enum.Parse( type, name ) )}" );
            }

            return strbuild.ToString();
        }

        strbuild.AppendLine( $"class {type.Name}:" );

        if( this.m_DocStrings.TryGetValue( $"T:{type.Name}", out string? classsummary ) )
        {
            strbuild.AppendLine($"\t'''{classsummary.Trim()}'''");
        }

        foreach( FieldInfo prop in type.GetFields() )
        {
            if( !prop.IsSpecialName && !prop.IsStatic && !prop.IsPrivate && prop.Name[0] != '_' )
            {
                this.WriteMember( strbuild, 'F', type, prop.FieldType, prop );
            }
        }

        foreach( PropertyInfo prop in type.GetProperties() )
        {
            if( !prop.IsSpecialName && prop.Name[0] != '_' )
            {
                this.WriteMember( strbuild, 'P', type, prop.PropertyType, prop );
            }
        }

        foreach( MethodInfo method in this.ExtensionMethods( type ) )
        {
            if( method.Name[0] != '_' )
            {
                this.WriteMethods( strbuild, method, type );
            }
        }

        foreach( MethodInfo method in type.GetMethods(
            BindingFlags.Public |
            BindingFlags.GetProperty |
            BindingFlags.Instance |
            BindingFlags.DeclaredOnly
        ) )
        {
            if( !method.IsSpecialName && !method.IsStatic && !method.IsPrivate && method.Name[0] != '_' )
            {
                this.WriteMethods( strbuild, method, type );
            }
        }

        return strbuild.ToString();
    }

    public void WriteMethods( StringBuilder strbuild, MethodInfo method, Type member )
    {
        ParameterInfo[] parameters = method.GetParameters();

        strbuild.Append( $"\tdef {method.Name}( self" );

        string doc_string = $"M:{member.Name}.{method.Name}";

        if( parameters.Length > 0 )
        {
            doc_string = $"M:{member.Name}.{method.Name}({string.Join( ",", parameters.Select( p => p.ParameterType.FullName ) ).Trim()})";

            if( method.IsDefined( typeof( System.Runtime.CompilerServices.ExtensionAttribute ), false ) )
            {
                parameters = parameters.Skip(1).ToArray();
            }

            bool GotDefault = false;

            if( parameters.Length > 0 )
            {
                strbuild.Append( $", " );

                int counter = 0;

                foreach( ParameterInfo param in parameters )
                {
                    counter++;

                    if( this.IsParameterNullable( param ) )
                    {
                        strbuild.Append( $"{param.Name}: Optional[{MapType(param.ParameterType, member)}]" );
                    }
                    else
                    {
                        strbuild.Append( $"{param.Name}: {MapType(param.ParameterType, member)}" );
                    }

                    if( GotDefault || param.HasDefaultValue && param.DefaultValue is not null )
                    {
                        GotDefault = true;
                        strbuild.Append( $" = None" );
                    }

                    if( counter < parameters.Length )
                    {
                        strbuild.Append( ", " );
                    }
                }
            }
        }

        strbuild.Append( $" ) -> {MapType(method.ReturnType, member)}:" );
        strbuild.AppendLine();

        if( this.m_DocStrings.TryGetValue( doc_string, out string? methodsummary ) )
        {
            strbuild.AppendLine( $"\t\t'''{methodsummary.Trim()}'''" );
        }

        strbuild.AppendLine( "\t\tpass;" );
    }

    public IEnumerable<MethodInfo> ExtensionMethods(Type extype)
    {
        return from assembly in AppDomain.CurrentDomain.GetAssemblies()

            from type in assembly.GetTypes()

            where type.IsSealed && type.IsAbstract && !type.IsGenericType && !type.IsNested

            from method in type.GetMethods(
                BindingFlags.Static |
                BindingFlags.Public |
                BindingFlags.NonPublic
            )

            where method.IsDefined( typeof( System.Runtime.CompilerServices.ExtensionAttribute ), false )

            let parameters = method.GetParameters()

            where parameters.Length > 0 && parameters[0].ParameterType == extype

            select method;
    }

    public bool IsParameterNullable( ParameterInfo param )
    {
        NullabilityInfoContext nullability_info = new NullabilityInfoContext();

        NullabilityInfo info = nullability_info.Create( param );

        return ( info.WriteState == NullabilityState.Nullable || info.ReadState == NullabilityState.Nullable );
    }

    /// <summary>
    /// Maps a C# type to a Python type
    /// </summary>
    public string MapType( Type type, Type member )
    {
        // Pythonism, can't make classes return their own type as is not yet "defined" X[
        if( type == member )
            return $"'{member.Name}'";

        if( this.MapTypeList.TryGetValue( type, out string? pyType ) && !string.IsNullOrWhiteSpace( pyType ) )
            return pyType;

        // Threat Templates as Any
        if( type.IsGenericParameter )
            return "Any";

        if( type.IsGenericType )
        {
            type = type.GetGenericTypeDefinition();

            if( type == typeof( List<> ) )
                return $"list[Any]";

            if( type == typeof( Dictionary<,> ) )
                return $"dict[Any, Any]";

            return "Any";
        }

        this.logger.warn
            .Write("Undefined python type conversion for CSharp's ")
            .Write( type.Name, ConsoleColor.Green )
            .NewLine()
            .Write( "Example: " )
            .Write( "MapTypeList", ConsoleColor.Cyan )
            .Write( "[ ", ConsoleColor.DarkCyan )
            .Write( "typeof", ConsoleColor.Blue )
            .Write( "(", ConsoleColor.Yellow )
            .Write( type.Name, ConsoleColor.Green )
            .Write( ")", ConsoleColor.Yellow )
            .Write( " ] ", ConsoleColor.DarkCyan )
            .Write( "=", ConsoleColor.Yellow )
            .Write( $"\"{type.Name.ToLower()}\"", ConsoleColor.DarkYellow )
            .Write( ";", ConsoleColor.Yellow )
            .NewLine();

        return "Any";
    }

    public PythonNET()
    {
        if( !App.arguments.Contains( "-docs" ) )
        {
            return;
        }

        this.LoadDocument( Path.Combine( Directory.GetCurrentDirectory(), "bin", "Debug", "GoldSrc2Sven.xml" ) );

#if APIGEN_PROTOTYPE_EXTERNAL
        // Logger.py
        this.UpdateThirdPartyDocument( "Mikk.Logger",
            Path.Combine( Directory.GetCurrentDirectory(), "..", "..","external", "MikkNET", "Mikk.Logger" )
        );
#endif // APIGEN_PROTOTYPE_EXTERNAL

        this.GenerateFile( typeof(Context.Upgrade), "Upgrade", new StringBuilder()
            .AppendLine( "from netapi.Logger import Logger;" )
        );

        this.GenerateFile( typeof(Context.Assets), "Assets", new StringBuilder()
            .AppendLine( "from netapi.Upgrade import Upgrade;" )
        );

        this.GenerateFile( typeof(Vector), "Vector" );

        this.GenerateFile( typeof(Context.Map), "Map", new StringBuilder()
            .AppendLine( "from netapi.Entity import Entity;" )
            .AppendLine( "from netapi.Upgrade import Upgrade;" )
            .AppendLine( "from netapi.CFG import CFG;" )
            .AppendLine( "from netapi.MapUpgrades import MapUpgrades;" )
        );

        this.GenerateFile( typeof(Context.CFG), "CFG" );

//        this.GenerateFile( typeof(Context.IMapUpgrade), "IMapUpgrade" );

        this.GenerateFile( typeof(Context.MapUpgrades), "MapUpgrades", new StringBuilder()
            .AppendLine( "from netapi.Logger import Logger;" )
            .AppendLine( "from netapi.Entity import Entity;" )
            .AppendLine( "from netapi.IMapUpgrade import IMapUpgrade;" )
        );

        this.GenerateFile( typeof(Entity), "Entity", new StringBuilder()
            .AppendLine( "from netapi.Vector import Vector;" )
        );

        this.GenerateFile( typeof(Logger), "Logger", new StringBuilder()
            .AppendLine( "from netapi.ConsoleColor import ConsoleColor;" )
        );

        this.GenerateFile( typeof(ConsoleColor), "ConsoleColor" );
    }

    public void GenerateFile( Type type, string filename, StringBuilder? StringBuilder = null )
    {
        this.logger.info
            .Write( "Generating API class " )
            .Write( type.Name, ConsoleColor.Green )
            .Write( " for file " )
            .Write( filename, ConsoleColor.Cyan )
            .NewLine();

        if( StringBuilder is null )
        {
            StringBuilder = new StringBuilder();
        }

        StringBuilder.Insert( 0, $"'''\n{File.ReadAllText( Path.Combine( Directory.GetCurrentDirectory(), "LICENSE", "LICENSE_GOLDSRC2SVEN" ) )}\n'''\n\n" );

        StringBuilder.AppendLine( "from typing import Any, Optional;" );

        File.WriteAllText( Path.Combine( Directory.GetCurrentDirectory(), App.ScriptingFolder, "netapi", $"{filename}.py" ),
            this.Generate( type, StringBuilder ) );
    }

    public void UpdateThirdPartyDocument( string projectName, string projectPath )
    {
        string CSProjPath = Path.Combine( projectPath, $"{projectName}.csproj" );

        if( !File.Exists( CSProjPath ) )
        {
            this.logger.error
                .Write( "Invalid csproj at " )
                .Write( CSProjPath, ConsoleColor.Green )
                .NewLine();
            return;
        }

        this.logger.info
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

        this.LoadDocument( Path.Combine( projectPath, "bin", "Debug", $"{projectName}.xml" ) );
    }
}
#endif // DEBUG
