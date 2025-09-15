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

namespace GoldSrc2Sven.Context;

using System.Text;

/// <summary>
/// Represents a map's CFG file
/// </summary>
public class CFG( Map owner )
{
    private Map owner = owner;

    /// <summary>
    /// Absolute path to this CFG file
    /// </summary>
    public readonly string filepath = $"{owner.filepath.Replace( ".bsp", ".cfg" )}";

    /// <summary>
    /// Generate a CFG file. if template is true we'll apply a basic template config
    /// </summary>
    /// <param name="template"></param>
    public void Generate( bool template = false )
    {
        if( template )
        {
            // Sven features we-do-not-want-in-sp-mods x[
            this.AddNotOverride( "mp_disable_autoclimb", "1" );
            this.AddNotOverride( "mp_disablegaussjump", "1" );
            this.AddNotOverride( "mp_npckill", "2" );
            this.AddNotOverride( "mp_telefrag", "0" );
            this.AddNotOverride( "mp_banana", "0" );
            this.AddNotOverride( "mp_allowmonsterinfo", "0" );
            this.AddNotOverride( "mp_allowmonsterinfo", "0" );
            this.AddNotOverride( "mp_survival_supported", "1" );
            this.AddNotOverride( "mp_grapple_mode", "1" );
            this.AddNotOverride( "mp_hevsuit_voice", "1" );
            this.AddNotOverride( "npc_dropweapons", "1" );
            this.AddNotOverride( "mp_flashlight", "1" );

            this.AddNotOverride( "map_script", "HLSP" );
        }

        StringBuilder sb = new StringBuilder();

        sb.AppendLine( "## DO NOT MODIFY THIS FILE" );
        sb.AppendLine( "## This map has been ported with GoldSrc2Sven" );
        sb.AppendLine( "## To get this mod to work in this game install the GoldSrc2Sven tool" );
        sb.AppendLine( "## https://github.com/Mikk155/Sven-Co-op" );
        sb.AppendLine();

        foreach( KeyValuePair<string, string> pair in this.pairs )
        {
#if false // Bruh i swear sven used quoting strings
            if( int.TryParse( pair.Value, out int iValue ) )
            {
                sb.AppendLine( $"{pair.Key} {iValue}" );
            }
            else if( float.TryParse( pair.Value, out float fValue ) )
            {
                sb.AppendLine( $"{pair.Key} {fValue}" );
            }
            else
            {
                sb.AppendLine( $"{pair.Key} \"{pair.Value}\"" );
            }
#else
            sb.AppendLine( $"{pair.Key} {pair.Value}" );
#endif
        }

        File.WriteAllText( this.filepath, sb.ToString() );
    }

    private void AddNotOverride( string key, string value )
    {
        if( pairs.TryGetValue( key, out string? exists ) && string.IsNullOrEmpty( exists ) )
        {
            owner.owner.logger.trace
                .Write( "Skipping template config \"" )
                .Write( key, ConsoleColor.Green )
                .Write( "\" => \"" )
                .Write( value, ConsoleColor.Green )
                .Write( "\" Value \"" )
                .Write( exists, ConsoleColor.Green )
                .WriteLine( "\" Already defined by the script." );
        }
        else
        {
            pairs[ key ] = value;
        }
    }

    /// <summary>
    /// Key-Value pairs configuration.
    /// </summary>
    public Dictionary<string, string> pairs = new Dictionary<string, string>();
}
