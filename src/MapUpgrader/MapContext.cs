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
        Entities.Add( new Entity( "worldspawn" ) );
        Entities.Add( new Entity( "info_player_start" ) );
    }
}
