
using System.Text.Json;

#pragma warning disable CS8604 // Possible null reference argument.
#pragma warning disable CS8602 // Dereference of a possibly null reference.

class Program
{
    static readonly string SvenCoopPath = Path.Combine(
        JsonSerializer.Deserialize<Dictionary<string, string>>(
            File.ReadAllText(
                Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                    "SvenCoopRepository",
                    "config.json"
                )
            )
        )["svencoop"],
        "svencoop_addon"
    );

    static void CopyAsset( string source, string dest )
    {
        Directory.CreateDirectory(Path.GetDirectoryName(dest)!);

        if( !File.Exists(dest) || File.GetLastWriteTimeUtc( source ) > File.GetLastWriteTimeUtc( dest ))
        {
            Console.WriteLine( $"Installing {dest.Replace( SvenCoopPath, string.Empty )}" );
            File.Copy( source, dest, overwrite: true );
        }
        else
        {
            Console.WriteLine( $"Up to date: {dest}" );
        }
    }

    static void InstallAssets( string assetsJsonPath )
    {
        string assetsJsonPathRelative = assetsJsonPath.Replace( Directory.GetCurrentDirectory(), string.Empty );

        Console.WriteLine( $"Installing assets from {assetsJsonPathRelative}" );

        if( !File.Exists( assetsJsonPath ) )
        {
            throw new FileNotFoundException( $"Unexistent package file {assetsJsonPath}" );
        }

        var assetsObject = JsonSerializer.Deserialize<Dictionary<string, object>>( File.ReadAllText( assetsJsonPath ) )!;

        // assets
        foreach( JsonElement assetElement in ( (JsonElement)assetsObject[ "assets" ] ).EnumerateArray() )
        {
            string asset = assetElement.GetString()!.Replace( '/', Path.DirectorySeparatorChar );
            CopyAsset( Path.Combine( Directory.GetCurrentDirectory(), "src", asset ), Path.Combine( SvenCoopPath, asset ) );
        }

        if( assetsObject.TryGetValue( "includes", out object? includesElement ) )
        {
            foreach( string include in ( (JsonElement)includesElement ).EnumerateArray().Select( e => e.GetString()! ) )
            {
                InstallAssets( Path.Combine( Directory.GetCurrentDirectory(), "src", include.Replace( '/', Path.DirectorySeparatorChar ) ) );
            }
        }
    }

    static void Main( string[] args )
    {
        InstallAssets( Path.Combine( Path.GetDirectoryName( args[0] ), "assets.json" ) );
    }
}
#pragma warning restore CS8604
#pragma warning restore CS8602
