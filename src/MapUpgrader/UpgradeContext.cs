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
public class UpgradeContext( ILanguageEngine Language, string script )
{
    public readonly ILanguageEngine Language = Language;
    public readonly string Name = Path.GetFileName( script );
    public readonly string Script = script;

    /// <summary>
    /// Title to display as an option
    /// </summary>
    public required string Title { get; set; }

    /// <summary>
    /// Description to display as an option
    /// </summary>
    public required string Description { get; set; }

    /// <summary>
    /// Mod folder to install assets
    /// </summary>
    public required string Mod { get; set; }

    /// <summary>
    /// Mod download URL or multiple url for mirroring
    /// </summary>
    public required string[] urls { get; set; }

    /// <summary>
    /// Maps to upgrade. Leave empty to upgrade all maps
    /// </summary>
    public string[]? maps { get; set; }
}
#pragma warning restore IDE1006 // Naming Styles
