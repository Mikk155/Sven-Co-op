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

using Sledge.Formats.Bsp;
using Sledge.Formats.GameData;
using Sledge.Formats.GameData.Objects;

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

    /// <summary>
    /// CFG file
    /// </summary>
    public readonly CFG cfg;

    /// <summary>
    /// Contains generic map upgrades you can apply to your map
    /// </summary>
    public readonly MapUpgrades upgrade;

    public List<int> _RemovedEntities = new List<int>();

    private void _RemoveDeletedEntities()
    {
        this._RemovedEntities.Sort();
        this._RemovedEntities.Reverse();

        foreach( int index in this._RemovedEntities )
        {
            Entity? entity = this.entities.FirstOrDefault( e => e.index == index );

            if( entity is not null )
            {
                this.entities.Remove( entity );
            }
        }
    }

    public void _WriteBSP()
    {
        this._RemoveDeletedEntities();

        using FileStream stream = File.OpenRead( this.filepath );
        BspFile bsp = new BspFile( stream );
        stream.Close();

        List<EntityGroup> fgd_entities = FgdFormatter.ReadFile( Path.Combine( this.owner.GetSvenCoopInstallation(), "svencoop", "sven-coop.fgd" ) ).EntityGroups;

        List<Sledge.Formats.Bsp.Objects.Entity> sledge_entities = this.entities.Select( e =>
        {
            string classname = e.GetString( "classname" );

            if( string.IsNullOrWhiteSpace( classname ) )
            {
                string index = e.index >= 0 ? $"Index: {e.index}" : "";
                this.owner.logger.error
                    .WriteLine( $"Got a entity with no classname! Removing {index}" );
            }
            else if( fgd_entities.FirstOrDefault( e => e.Name == classname ) is null )
            {
                this.owner.logger.error
                    .WriteLine( $"Got a entity with classname \"{classname}\" that doesn't exists in the FGD!" );
            }

            Sledge.Formats.Bsp.Objects.Entity sledge_entity = new Sledge.Formats.Bsp.Objects.Entity();

            foreach( KeyValuePair<string, string> kv in e.keyvalues )
            {
                sledge_entity.KeyValues[ kv.Key ] = kv.Value;
            }

            return sledge_entity;
        } ).ToList();

        bsp.Entities.Clear();

        foreach( Sledge.Formats.Bsp.Objects.Entity entity in sledge_entities )
        {
            bsp.Entities.Add( entity );
        }

        using FileStream write_stream = File.Create( this.filepath );
        bsp.WriteToStream( write_stream, bsp.Version );
        stream.Close();
    }

    public Map( string map, Context.Upgrade _owner )
    {
        this.filename = this.name = Path.GetFileNameWithoutExtension( map );

        this.filepath = map;
        this.owner = _owner;
        this.cfg = new CFG( this );

        this.upgrade = new MapUpgrades( this );

        using FileStream stream = File.OpenRead( this.filepath );
        BspFile bsp = new BspFile( stream );
        stream.Close();

        int i = 0;
        foreach( Sledge.Formats.Bsp.Objects.Entity entity in bsp.Entities )
        {
            this.entities.Add( new Entity( entity.KeyValues.ToDictionary( kvp => kvp.Key, kvp => kvp.Value ), i++, this ) );
        }
    }
}
