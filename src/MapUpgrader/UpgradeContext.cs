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

#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a context for upgrading</summary>
public class UpgradeContext( ILanguageEngine Language, string Script )
{
    /// <summary>The scripting engine interface used for this upgrade.</summary>
    public readonly ILanguageEngine Language = Language;

    /// <summary>The absolute file path for the script for this upgrade.</summary>
    public readonly string Script = Script;

    /// <summary>The script filename without extension for this upgrade.</summary>
    public string Name =>
        Path.GetFileName( this.Script );

    /// <summary>Title to display as an option.</summary>
    public string title = null!;

    /// <summary>Mod folder to install assets.</summary>
    public string mod = null!;

    /// <summary>Mod download URL or multiple url for mirroring..</summary>
    public string[] urls = null!;

    /// <summary>Optional description to display as an option.</summary>
    public string? description { get; set; }

    /// <summary>Maps to upgrade. Leave empty to upgrade all maps.</summary>
    public string[]? maps { get; set; }

    /// <summary>
    /// Get the mod's installation absolute path
    /// </summary>
    /// <returns>The absolute path directory to the mod installation</returns>
    public string GetModPath()
    {
        return string.Empty;
    }

    /// <summary>
    /// Get the list of defined maps or all the maps in the mod installation if the script left it empty.
    /// </summary>
    /// <returns></returns>
    public string[] GetMaps()
    {
        if( this.maps is null || this.maps.Length <= 0 )
        {
            this.maps = Directory.GetFiles( Path.Combine( this.GetModPath(), "maps" ) )
                .Select( m => Path.GetFileNameWithoutExtension( m ) )
                .ToArray();
        }

        return this.maps;
    }
}
#pragma warning restore IDE1006 // Naming Styles
