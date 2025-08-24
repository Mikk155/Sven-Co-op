using System.Text.Json;
using System.Diagnostics;

public interface IProject
{
    public string GetName();
    public string GetHeader();
    public void Setup();

#pragma warning disable CS8601
    public static Dictionary<string, string> cache = JsonSerializer.Deserialize<Dictionary<string, string>>( File.ReadAllText( GetConfigPath() ) );
#pragma warning restore CS8601

    private static string? ConfigFile = null;

    private static string GetConfigPath()
    {
        if( ConfigFile is null )
        {
            string AppFolder = Path.Combine( Environment.GetFolderPath( Environment.SpecialFolder.ApplicationData ), "SvenCoopRepository" );

            if( !Directory.Exists( AppFolder ) )
            {
                Directory.CreateDirectory( AppFolder );
            }

            ConfigFile = Path.Combine( AppFolder, "config.json" );

            if( !File.Exists( ConfigFile ) )
            {
                File.WriteAllText( ConfigFile, "{}" );
            }
        }

        return ConfigFile;
    }

    public static void Config( string key, Func<string, bool> validator, string? additional_info = null )
    {
        while( true )
        {
            // Try to use the cached one
            cache.TryGetValue( key, out string? value );

            try
            {
                if( !string.IsNullOrEmpty( value ) && validator( value ) )
                {
                    File.WriteAllText( GetConfigPath(), JsonSerializer.Serialize( cache ) );
                    return;
                }
            }
            catch( Exception exception )
            {
                Console.WriteLine( $"Invalid configuration '{key}'. Error: {exception.Message}\nPlease input a valid value:" );
            }

            if( additional_info is not null )
            {
                Console.WriteLine( additional_info );
            }

            string? input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) )
            {
                cache[ key ] = input;
            }
        }
    }

    public static void RunCommand( string filename, string arguments, string directory )
    {
        ProcessStartInfo prompt = new ProcessStartInfo
        {
            FileName = filename,
            Arguments = arguments,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            WorkingDirectory = directory
        };

        using Process process = Process.Start( prompt )!;

        string output = process.StandardOutput.ReadToEnd();
        string error = process.StandardError.ReadToEnd();

        process.WaitForExit();

        Console.WriteLine( output );

        if( !string.IsNullOrEmpty( error ) )
        {
            Console.WriteLine( error );
        }
    }

    public void Initialize()
    {
        Console.WriteLine( GetHeader() );

        Console.WriteLine( " 1: Yes" );
        Console.WriteLine( " 2: No" );

        string? input;
        int option = 0;

        (int left, int right) = Console.GetCursorPosition();

        while( option != 1 && option != 2 )
        {
            input = Console.ReadLine();

            Console.SetCursorPosition( left, right );

            if( string.IsNullOrEmpty( input ) )
                continue;

            if( int.TryParse( input, out option ) )
            {
                if( option == 2 )
                {
                    return;
                }
                if( option == 1 )
                {
                    Console.WriteLine( $"Setting up {GetName()} workspace" );
                    Setup();
                    return;
                }
            }
        }
    }
}
