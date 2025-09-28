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

namespace FormatTitles;

/// <summary>
/// Format a string representing titles.txt into game_text entities for Sven Co-op as they don't allow cool stuff x[
/// </summary>
public static class FormatTitles
{
    private static void Reset()
    {
    }

    /// <summary>
    /// Return a .json like formated game_text entries
    /// </summary>
    public static string ToJson( string input )
    {
        List<Dictionary<string, string>> list = FormatTitles.ToList( input );

        return System.Text.Json.JsonSerializer.Serialize( list,
            new System.Text.Json.JsonSerializerOptions(){
                WriteIndented = true,
                IndentSize = 4,
                NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.WriteAsString,
            }
        );
    }

    /// <summary>
    /// Return a .ent like formated game_text entries
    /// </summary>
    public static string ToEnt( string input )
    {
        List<Dictionary<string, string>> list = FormatTitles.ToList( input );

        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        foreach( Dictionary<string, string> entity in list )
        {
            sb.AppendLine( "{" );

            foreach( KeyValuePair<string, string> kv in entity )
            {
                sb.Append( '"' );
                sb.Append( kv.Key );
                sb.Append( '"' );
                sb.Append( ' ' );
                sb.Append( '"' );
                sb.Append( kv.Value );
                sb.Append( '"' );
                sb.AppendLine();
            }

            sb.AppendLine( "}" );
        }

        return sb.ToString();
    }

    /// <summary>
    /// Return a list of key-value pairs representing each game_text
    /// </summary>
    public static List<Dictionary<string, string>> ToList( string input )
    {
        List<Dictionary<string, string>> entities = new List<Dictionary<string, string>>();

        Dictionary<string, string> entity = new Dictionary<string, string>();

        entity[ "classname" ] = "game_text";

        entities.Add( entity );

        FormatTitles.Reset();

        return entities;
    }
}
