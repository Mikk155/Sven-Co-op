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
