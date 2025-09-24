using System.Text.Json;

class AngelScriptAssets( string AbsoluteDirectory )
{
    public readonly string FullPath = AbsoluteDirectory;
    public readonly string BaseFolder = Path.GetDirectoryName( AbsoluteDirectory )!;
    public readonly string FileName = Path.GetFileNameWithoutExtension( AbsoluteDirectory );

    public readonly string AssetsFile = AngelScriptAssets.GetAssetsFile( AbsoluteDirectory );

    private static string GetAssetsFile( string AbsoluteDirectory )
    {
        string? dir = AbsoluteDirectory;

        while( true )
        {
            dir = Path.GetDirectoryName( dir );

            if( string.IsNullOrWhiteSpace( dir ) )
                break;

            string AssetsExists = Path.Combine( dir, "assets.json" );

            if( File.Exists( AssetsExists ) )
            {
                return AssetsExists;
            }
        }

        throw new FileNotFoundException( $"Couldn't find file \"assets.json\" in any of the parent directories of \"{AbsoluteDirectory}\"" );
    }

    public void Install()
    {
        this.InstallAssets( this.AssetsFile );
    }

    private void InstallAssets( string AssetsFilePath )
    {
        string assetsJsonPathRelative = Path.GetRelativePath( App.Workspace, AssetsFilePath );

        if( !File.Exists( AssetsFilePath ) )
        {
            throw new FileNotFoundException( $"Unexistent package file {AssetsFilePath}" );
        }

        Console.WriteLine( $"Installing assets from {assetsJsonPathRelative}" );

        var assetsObject = JsonSerializer.Deserialize<Dictionary<string, object>>( File.ReadAllText( AssetsFilePath ) )!;

        // assets
        foreach( JsonElement assetElement in ( (JsonElement)assetsObject[ "assets" ] ).EnumerateArray() )
        {
            string asset = assetElement.GetString()!.Replace( '/', Path.DirectorySeparatorChar );

            CopyAsset( asset, asset );
        }

        if( assetsObject.TryGetValue( "includes", out object? includesElement ) )
        {
            foreach( string include in ( (JsonElement)includesElement ).EnumerateArray().Select( e => e.GetString()! ) )
            {
                InstallAssets( Path.Combine( App.Workspace, include.Replace( '/', Path.DirectorySeparatorChar ) ) );
            }
        }
    }

    private static void CopyAsset( string src, string dest )
    {
        string Source = Path.Combine( App.Workspace, src );
        string Destination = Path.Combine( App.SvenCoop, "svencoop_addon", dest );

        Directory.CreateDirectory( Path.GetDirectoryName( Destination )! );

        if( !File.Exists( Destination ) || File.GetLastWriteTimeUtc( Source ) > File.GetLastWriteTimeUtc( Destination ) )
        {
            Console.WriteLine( $"Installing {dest}" );
            File.Copy( Source, Destination, overwrite: true );
        }
        else
        {
            Console.WriteLine( $"Up to date: {dest}" );
        }
    }
}

class App
{
    public static string AppDirectory = null!;

    public static string Workspace {
        get {
            return Path.Combine( App.AppDirectory, "..", "..", "src" );
        }
    }

    public static string SvenCoop => App.m_SvenCoopPath;

    private static Dictionary<string, string> Config = null!;

    private static string m_SvenCoopPath = null!;
    private static string m_SettingsPath = null!;

    //-TODO Track copied files and delete if they're not anymore in assets.json
    private static string m_PackagePath = null!;

    public static void Main( string[] Arguments )
    {
        App.AppDirectory = Directory.GetCurrentDirectory();

        if( !App.AppDirectory.EndsWith( "code-runner" ) )
        {
            App.AppDirectory = Path.Combine( App.AppDirectory, "build", "code-runner" );
        }

        App.GetConfig();

        AngelScriptAssets ASFile = new AngelScriptAssets( Arguments[0] );

        ASFile.Install();
    }

    private static void GetConfig()
    {
        m_SettingsPath = Path.Combine( App.AppDirectory, "settings.json" );
        m_PackagePath = Path.Combine( App.AppDirectory, "package.json" );

        if( !File.Exists( m_SettingsPath ) )
        {
            File.WriteAllText( m_SettingsPath, "{}" );
        }

        App.Config = JsonSerializer.Deserialize<Dictionary<string, string>>( File.ReadAllText( m_SettingsPath ) )!;

        App.m_SvenCoopPath = App.RetrieveValue( "svencoop_installation", value =>
        {
            if( !Directory.Exists( Path.Combine( value, "svencoop" ) ) )
            {
                throw new DirectoryNotFoundException( $"Could not found the svencoop directory at \"{value}\"" );
            }
            return true;
        }, "Input the absolute path of your Sven Co-op installation" );

        File.WriteAllText( m_SettingsPath, JsonSerializer.Serialize( Config ) );
    }

    private static string RetrieveValue( string key, Func<string, bool> validator, string description )
    {
        while( !App.Config.ContainsKey( key ) )
        {
            try
            {
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine( description );

                Console.BackgroundColor = ConsoleColor.White;
                Console.ForegroundColor = ConsoleColor.Black;

                string? input = Console.ReadLine();

                Console.ResetColor();

                if( !string.IsNullOrWhiteSpace( input ) && validator( input ) )
                {
                    App.Config[ key ] = input;
                    return input;
                }
            }
            catch( Exception exception )
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write( "Error: " );
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine( exception.Message );
                Console.ResetColor();
            }
        }

        return App.Config[ key ];
    }
}
