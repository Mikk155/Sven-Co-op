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

/// <summary>
/// Represents a BSP
/// </summary>
public class MapContext
{
    private readonly string __Name__;

    /// <summary>
    /// This BSP file name
    /// </summary>
    public string Name =>
        __Name__;

    private readonly string __BSPFile__;

    /// <summary>
    /// Absolute path to this BSP file
    /// </summary>
    public string BSPFile =>
        __BSPFile__;

    /// <summary>
    /// List of entities in the current BSP
    /// </summary>
    public List<Entity> Entities = new List<Entity>();

    public MapContext( string mapname )
    {
        this.__Name__ = mapname;

        this.__BSPFile__ = Path.Combine( Directory.GetCurrentDirectory(), "maps", mapname );

        if( !Path.Exists( this.BSPFile ) )
        {
            throw new FileNotFoundException( $"BSP File not found at \"{this.BSPFile}\"" );
        }

        // -TODO Read entity lump
        string[] lines = File.ReadAllLines( this.BSPFile );
        int index = 0;
        Entity? entity = null;
        foreach( string line in lines )
        {
            if( entity is null ) {
                if( line[0] == '{' ) {
                    entity = new Entity(index);
                    index++;
                }
                continue;
            }
            if( line[0] == '}' )
            {
                entity = null;
                continue;
            }

            string[] keyvalues = line.Substring( 1, line.Length - 1 ).Split( "\" \"" );
            entity.SetString( keyvalues[0], keyvalues[1] );
        }

        // -Apply C# specific upgrades

        // -Call python context

        // -Merge if provided

        // -If merged, call C# and Python post proccessing
    }
}
