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

using GoldSrc2Sven.BSP;

/// <summary>
/// Represents a BSP
/// </summary>
public class Map
{
    /// <summary>
    /// This BSP file name
    /// </summary>
    public string name;

    /// <summary>
    /// This BSP file name
    /// </summary>
    public readonly string filename;

    /// <summary>
    /// Absolute path to this BSP file
    /// </summary>
    public readonly string filepath;

    public readonly Context.Upgrade owner;

    /// <summary>
    /// List of entities in the current BSP
    /// </summary>
    public List<Entity> entities = new List<Entity>();

    public Map( string map, Context.Upgrade _owner )
    {
        this.filename = this.name = Path.GetFileNameWithoutExtension( map );

        this.filepath = map;
        this.owner = _owner;
    }
}
