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

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a context for upgrading</summary>
public class UpgradeContext
{
    /// <summary>
    /// The scripting engine interface used for this upgrade.
    /// </summary>
    public readonly ILanguageEngine Language;

    /// <summary>
    /// The absolute file path for the script for this upgrade.
    /// </summary>
    public readonly string Script;

    /// <summary>
    /// The script filename without extension for this upgrade.
    /// </summary>
    public string Name =>
        Path.GetFileNameWithoutExtension( this.Script );

    public UpgradeContext( ILanguageEngine _Language, string _Script, string? data )
    {
        this.Language = _Language;
        this.Script = _Script;

        if( data is null )
        {
            throw new InvalidDataException( $"Invalid data from method {ILanguageEngine.InitializationMethod} for script {_Script}" );
        }

        JObject? JsonData = JsonConvert.DeserializeObject<JObject>( data );

        if( JsonData is null )
        {
            throw new InvalidDataException( $"Invalid data from method {ILanguageEngine.InitializationMethod} for script {_Script}" );
        }

        this.Title = JsonData.GetValue( "title" )?.ToString() ?? this.Name;
        this.Description = JsonData.GetValue( "title" )?.ToString() ?? "";

        this.Mod = JsonData[ "mod" ]?.ToString()!;
        this.urls = JsonData.GetValue( "urls" )?.Select( a => a.ToString() )?.ToArray()!;

        this.maps = JsonData.GetValue( "maps" )?.Select( a => a.ToString() )?.ToArray();
    }

    /// <summary>
    /// Title to display as an option.
    /// </summary>
    public string Title { get; set; }

    /// <summary>
    /// Description to display as an option.
    /// </summary>
    public string Description { get; set; }

    /// <summary>
    /// Mod folder to install assets. This is required.
    /// </summary>
    public string Mod { get; set; }

    /// <summary>
    /// Mod download URL or multiple url for mirroring. This is required.
    /// </summary>
    public string[] urls { get; set; }

    /// <summary>
    /// Maps to upgrade. Leave empty to upgrade all maps.
    /// </summary>
    public string[]? maps { get; set; }
}
#pragma warning restore IDE1006 // Naming Styles
