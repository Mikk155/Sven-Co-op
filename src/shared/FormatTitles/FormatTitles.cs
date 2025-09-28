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

#pragma warning disable IDE1006 // Naming Styles

public enum Effect
{
    /// <summary>
    /// fade in/fade out
    /// </summary>
    FadeInOut = 0,
    /// <summary>
    /// flickery credits
    /// </summary>
    Credits = 1,
    /// <summary>
    /// write out (training room)
    /// </summary>
    ScanOut = 2,
    /// <summary>
    /// Sven Co-op specific print center (normal text in center of screen)
    /// </summary>
    CenterPrint = -1,
    /// <summary>
    /// Sven Co-op specific print notify (normal text in top left of screen)
    /// </summary>
    NotifyPrint = -2,
    /// <summary>
    /// Sven Co-op specific print center (text piped straight into console)
    /// </summary>
    CenterPrintnConsole = -3,
    /// <summary>
    /// Sven Co-op specific print talk (normal text in lower middle of screen)
    /// </summary>
    ChatPrint = -4
};

public class GameText
{
    /// <summary>
    /// Default values has been taken from sven coop FGD and may be different than the game's defaults.
    /// This may require an update.
    /// </summary>
    public static class Defaults
    {
        public static float x = -1;
        public static float y = 0.67f;
        public static int _effect = 0;
        public static List<Byte> color = new List<Byte>(){ 0, 0, 0 };
        public static List<Byte> color2 = new List<Byte>(){ 0, 0, 0 };
        public static float fadein = 1.5f;
        public static float fadeout = 0.5f;
        public static float holdtime = 1.2f;
#if false
        public static float fxtime = 0.25f;
#endif
    }

    public string label = string.Empty;
    public string message = string.Empty;

    /// <summary>
    /// Position command $position x y
    /// x & y are from 0 to 1 to be screen resolution independent
    /// -1 means center in each dimension
    /// </summary>
    public float x = -1;

    /// <summary>
    /// Position command $position x y
    /// x & y are from 0 to 1 to be screen resolution independent
    /// -1 means center in each dimension
    /// </summary>
    public float y = 0.67f;

    /// <summary>
    /// Effect command $effect <effect number>
    /// effect 0 is fade in/fade out
    /// effect 1 is flickery credits
    /// effect 2 is write out (training room)
    /// Sven Co-op-specific:
    /// effect -1 is print center (normal text in center of screen)
    /// effect -2 is print notify (normal text in top left of screen)
    /// effect -3 is print center (text piped straight into console)
    /// effect -4 is print talk (normal text in lower middle of screen)
    /// </summary>
    public int _effect = 0;

    /// <summary>
    /// Effect command $effect <effect number>
    /// </summary>
    public Effect effect => (Effect)this._effect;

    /// <summary>
    /// Text color r g b command $color
    /// </summary>
    public List<Byte> color = new List<Byte>(){ 0, 0, 0 };

    /// <summary>
    /// Text color2 r g b command $color2
    /// </summary>
    public List<Byte> color2 = new List<Byte>(){ 0, 0, 0 };

    /// <summary>
    /// $fadein message fade in time - per character in effect 2
    /// </summary>
    public float fadein = 1.5f;

    /// <summary>
    /// $fadeout message fade out time
    /// </summary>
    public float fadeout = 0.5f;

    /// <summary>
    /// $holdtime stay on the screen for this long
    /// </summary>
    public float holdtime = 1.2f;

#if false
    /// <summary>
    /// Scan time (scan effect only)
    /// </summary>
    public float fxtime = 0.25f;
#endif

    public GameText()
    {
    }

    public GameText( GameText other )
    {
        this.label = other.label;
        this.message = other.message;
        this.x = other.x;
        this.y = other.y;
        this.color = other.color;
        this.color2 = other.color2;
        this._effect = other._effect;
        this.fadein = other.fadein;
        this.fadeout = other.fadeout;
        this.holdtime = other.holdtime;
#if false
        this.fxtime = other.fxtime;
#endif
    }
}

/// <summary>
/// Format a string representing titles.txt into game_text entities for Sven Co-op as they don't allow cool stuff x[
/// </summary>
public static class FormatTitles
{
    private static bool ReadingMessage;
    private static bool ReadingMessageStarted;
    private static bool ReadingLabel;
    private static bool ReadingComment;
    private static string ReadingKeyCharacters = string.Empty;
    private static string ReadingValueCharacters = string.Empty;
    private static bool ReadingKey;
    private static bool Readingvalue;

    private static void Reset()
    {
        ReadingMessage = false;
        ReadingMessageStarted = false;
        ReadingLabel = false;
        ReadingComment = false;
        ReadingKey = false;
        Readingvalue = false;
        ReadingKeyCharacters = string.Empty;
        ReadingValueCharacters = string.Empty;
    }

    /// <summary>
    /// Return a .ent like formated game_text entries
    /// </summary>
    public static string ToEnt( string input )
    {
        List<Dictionary<string, string>> list = ToDictionary( input );

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
    /// Return a .json like formated game_text entries
    /// </summary>
    public static string ToJson( string input )
    {
        List<Dictionary<string, string>> list = ToDictionary( input );

        return System.Text.Json.JsonSerializer.Serialize( list,
            new System.Text.Json.JsonSerializerOptions(){
                WriteIndented = true,
                IndentSize = 4,
                NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.WriteAsString,
            }
        );
    }

    /// <summary>
    /// Return a list of key-value pairs representing each game_text
    /// </summary>
    public static List<Dictionary<string, string>> ToDictionary( string input )
    {
        List<GameText> list = ToList( input );

        List<Dictionary<string, string>> entities = new List<Dictionary<string, string>>();

        foreach( GameText text in list )
        {
            Dictionary<string, string> entity = new Dictionary<string, string>();

            entity[ "classname" ] = "game_text";

            entity[ "targetname" ] = text.label;
            entity[ "message" ] = text.message;

            if( text.x != GameText.Defaults.x )
                entity[ "x" ] = text.x.ToString();

            if( text.y != GameText.Defaults.y )
                entity[ "y" ] = text.y.ToString();

            if( text._effect != GameText.Defaults._effect )
                entity[ "effect" ] = text._effect.ToString();

            if( text.color[0] != GameText.Defaults.color[0]
            && text.color[1] != GameText.Defaults.color[1]
            && text.color[2] != GameText.Defaults.color[2] )
                entity[ "color" ] = string.Join( " ", text.color );

            if( text.color2[0] != GameText.Defaults.color2[0]
            && text.color2[1] != GameText.Defaults.color2[1]
            && text.color2[2] != GameText.Defaults.color2[2] )
                entity[ "color2" ] = string.Join( " ", text.color2 );

            if( text.fadein != GameText.Defaults.fadein )
                entity[ "fadein" ] = text.fadein.ToString();

            if( text.fadeout != GameText.Defaults.fadeout )
                entity[ "fadeout" ] = text.fadeout.ToString();

            if( text.holdtime != GameText.Defaults.holdtime )
                entity[ "holdtime" ] = text.holdtime.ToString();

#if false
            if( text.fxtime != GameText.Defaults.fxtime )
                entity[ "fxtime" ] = text.fxtime.ToString();
#endif

            entities.Add( entity.Where( kv => !string.IsNullOrWhiteSpace( kv.Value ) ).ToDictionary() );
        }

        return entities;
    }

    /// <summary>
    /// Return a List of GameText entries
    /// </summary>
    public static List<GameText> ToList( string input )
    {
        Reset();

        GameText entity = new GameText();
        List<GameText> entities = new List<GameText>();

        char last = ' ';

        foreach( char c in input )
        {
            if( last == '/' && c == '/' )
            {
                ReadingComment = true;
            }

            // We're on a commentary for how long?
            if( ReadingComment )
            {
                if( c == '\n' )
                {
                    ReadingComment = false;
                }
            }
            else if( ReadingMessage )
            {
                if( c == '}' )
                {
                    GameText new_entity = new GameText( entity );

                    entity.label = string.Empty;
                    entity.message = string.Empty;

                    // Remove last newline as is not intended.
                    if( new_entity.message.EndsWith( '\n' ) )
                    {
                        new_entity.message = new_entity.message.Substring( 0, new_entity.message.Length - 1 );
                    }

                    entities.Add( new_entity );

                    ReadingMessage = false;
                }
                else
                {
                    if( ReadingMessageStarted )
                    {
                        ReadingMessageStarted = false;

                        // Skip first new line after a bracket open
                        if( c == '\n' )
                        {
                            last = c;
                            continue;
                        }
                    }

#if false
                    // -TODO See if escaped quotes are allowed otherwise add double '
                    if( c == '\n' || c == '"' )
                    {
                        entity.message += '\\'; // escape new lines
                    }
#endif
                    entity.message += c;
                }
                last = c;
                continue;
            }
            else if( ReadingMessageStarted )
            {
                if( c == '{' )
                {
                    ReadingMessage = true;
                }
            }
            else if( ReadingLabel )
            {
                // Newline? Then we're done here.
                if( c == '\n' )
                {
                    ReadingLabel = false;
                    ReadingMessageStarted = true;
                }
                else
                {
                    entity.label += c;
                }
            }
            else if( ReadingKey )
            {
                // New line? We're done reading keyvalues
                if( c == '\n' )
                {
                    ReadingKey = false;
                    Readingvalue = false;
                    ReadingKeyCharacters = string.Empty;
                    ReadingValueCharacters = string.Empty;
                }
                else if( Readingvalue )
                {
                    switch( ReadingKeyCharacters )
                    {
                        case "$position":
                        case "$effect":
                        case "$color":
                        case "$color2":
                        case "$fadein":
                        case "$fadeout":
                        case "$holdtime":
                        {
                            break;
                        }
                    }
                }
                // Space? We're reading a value now
                else if( c == ' ' )
                {
                    Readingvalue = true;
                }
                // Nothing? Then we may be still reading the key
                else
                {
                    ReadingKeyCharacters += c;
                }
            }
            else if( c == '$' )
            {
                ReadingKey = true;
                ReadingKeyCharacters = "$";
            }
            else if( c != '\n' && c != ' ' && c != '/' )
            {
                ReadingLabel = true;
            }

            last = c;
        }

        return entities;
    }
}

#pragma warning restore IDE1006 // Naming Styles
