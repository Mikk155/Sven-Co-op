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
/// Ref: https://github.com/FWGS/xash3d-fwgs/blob/master/engine/client/titles.c
/// </summary>
public static class FormatTitles
{
    /// <summary>
    /// Max buffer of characters in the game's Server dll that is transfered to the clients in game_text
    /// </summary>
    public static int MaxBufferSize = 512;

    /// <summary>
    /// Set to false to supress Exceptions breaking the loop
    /// </summary>
    public static bool Sensitive = true;

    /// <summary>
    /// Return a .json like formated game_text entries
    /// </summary>
    public static string ToJson( string[] input )
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
    public static string ToEnt( string[] input )
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
    public static List<Dictionary<string, string>> ToList( string[] input )
    {
        List<Dictionary<string, string>> entries = new List<Dictionary<string, string>>();

        Dictionary<string, string> entry = new Dictionary<string, string>();

        entry[ "classname" ] = "game_text";

        MSGType mode = MSGType.Name;

//        string[] lines = input.Split( '\n', StringSplitOptions.RemoveEmptyEntries  | StringSplitOptions.TrimEntries );

#if DEBUG
        int i = 0;
#endif

        string message = string.Empty;

        foreach( string line in input )
        {
            if( string.IsNullOrWhiteSpace( line ) )
                continue;

            switch( mode )
            {
                case MSGType.Name:
                {
                    if( line.StartsWith( "//" ) )
                        break;

                    // Is this a directive "$command"?, if so parse it and break
                    if( line[0] == '$' )
                    {
                        string[] items = line.Split( ' ' );

                        switch( items[0] )
                        {
                            case "$position":
                            {
                                if( items.Length > 1 && int.TryParse( items[1], out int x ) )
                                {
                                    entry[ "x" ] = x.ToString();
                                }

                                if( items.Length > 2 && int.TryParse( items[2], out int y ) )
                                {
                                    entry[ "y" ] = y.ToString();
                                }

                                break;
                            }
                            case "$effect":
                            {
                                if( items.Length > 1 && int.TryParse( items[1], out int effect ) )
                                {
                                    entry[ "effect" ] = effect.ToString();
                                }
                                break;
                            }
                            case "$fxtime":
                            {
                                if( items.Length > 1 && float.TryParse( items[1], out float fxtime ) )
                                {
                                    entry[ "fxtime" ] = fxtime.ToString();
                                }
                                break;
                            }
                            case "$color":
                            {
                                List<int> color = new List<int>(){ 0, 0, 0 };

                                if( items.Length > 1 && int.TryParse( items[1], out int r ) )
                                {
                                    color[0] = r;
                                }

                                if( items.Length > 2 && int.TryParse( items[2], out int g ) )
                                {
                                    color[0] = g;
                                }

                                if( items.Length > 3 && int.TryParse( items[3], out int b ) )
                                {
                                    color[0] = b;
                                }

                                entry[ "color" ] = string.Join( ' ', color );

                                break;
                            }
                            case "$color2":
                            {
                                List<int> color = new List<int>(){ 0, 0, 0 };

                                if( items.Length > 1 && int.TryParse( items[1], out int r ) )
                                {
                                    color[0] = r;
                                }

                                if( items.Length > 2 && int.TryParse( items[2], out int g ) )
                                {
                                    color[0] = g;
                                }

                                if( items.Length > 3 && int.TryParse( items[3], out int b ) )
                                {
                                    color[0] = b;
                                }

                                entry[ "color2" ] = string.Join( ' ', color );

                                break;
                            }
                            case "$fadein":
                            {
                                if( items.Length > 1 && float.TryParse( items[1], out float fadein ) )
                                {
                                    entry[ "fadein" ] = fadein.ToString();
                                }
                                break;
                            }
                            case "$fadeout":
                            {
                                if( items.Length > 1 && float.TryParse( items[1], out float fadeout ) )
                                {
                                    entry[ "fadeout" ] = fadeout.ToString();
                                }
                                break;
                            }
                            case "$holdtime":
                            {
                                if( items.Length > 1 && float.TryParse( items[1], out float holdtime ) )
                                {
                                    entry[ "holdtime" ] = holdtime.ToString();
                                }
                                break;
                            }
                            default:
                            {
                                if( FormatTitles.Sensitive )
                                {
#if DEBUG
                                    throw new FormatException( $"Unknown token: {items[0]} at line \"{line}\"" );
#else
                                    throw new FormatException( $"Unknown token: {items[0]} at line {i} \"{line}\"" );
#endif
                                }
                                break;
                            }
                        }
                        break;
                    }

                    if( line[0] == '{' )
                    {
                        mode = MSGType.Content;
                        message = string.Empty;
                        break;
                    }

                    entry[ "targetname" ] = line;

                    break;
                }
                case MSGType.Content:
                {
                    if( line[0] == '}' )
                    {
                        mode = MSGType.Name;

                        if( FormatTitles.Sensitive )
                        {
#if DEBUG
                            if( string.IsNullOrWhiteSpace( entry[ "targetname" ] ) )
                            {
                                throw new OverflowException( $"Got an empty label for message {message}" );
                            }
#endif
                            if( message.Length > FormatTitles.MaxBufferSize )
                            {
                                throw new OverflowException( $"Message for label {entry[ "targetname" ]} is too large! 512 is the maximun set. See FormatTitles.MaxBufferSize" );
                            }
                        }

                        entry[ "message" ] = message;

                        Dictionary<string, string> new_entry = new Dictionary<string, string>( entry );

                        entry[ "message" ] = string.Empty;
                        entry[ "targetname" ] = string.Empty;

                        entries.Add( new_entry );

                        break;
                    }

                    message += line;
                    break;
                }
            }
#if DEBUG
            i++;
#endif
        }

        return entries;
    }

    private enum MSGType
    {
        // Looking for a message name
        Name = 0,
        // Looking for the actual message content
        Content
    };
}
