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

        /*
        if( !Path.Exists( this.BSPFile ) )
        {
            throw new FileNotFoundException( $"BSP File not found at \"{this.BSPFile}\"" );
        }
        */

        // -TODO Read entity lump
        Entity worldspawn = new Entity(0);
        worldspawn.classname = "worldspawn";
        Entities.Add( worldspawn );
        Entity info_player_start = new Entity(1);
        info_player_start.classname = "info_player_start";
        Entities.Add( info_player_start );

        // -Apply C# specific upgrades

        // -Call python context

        // -Merge if provided

        // -If merged, call C# and Python post proccessing
    }
}
