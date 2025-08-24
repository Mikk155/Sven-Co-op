using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

class ConfigContext
{
    public JObject cache;

#pragma warning disable CS8601 // Possible null reference assignment.
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
    public ConfigContext()
    {
        cache = (JObject?)JsonConvert.DeserializeObject( File.ReadAllText( FilePath ) );
    }
#pragma warning restore CS8618
#pragma warning restore CS8601

    private string GetConfigPath()
    {
        string AppFolder = Path.Combine( Environment.GetFolderPath( Environment.SpecialFolder.ApplicationData ), "MapUpgrader" );

        if( !Directory.Exists( AppFolder ) )
        {
            Directory.CreateDirectory( AppFolder );
        }

        string ConfigFile = Path.Combine( AppFolder, "config.json" );

        if( !File.Exists( ConfigFile ) )
        {
            File.WriteAllText( ConfigFile, "{}" );
        }

        return ConfigFile;
    }

    /// <summary>
    /// Get the config.json absulote path
    /// </summary>
    public string FilePath =>
        GetConfigPath();

    public void Get( string key, Func<string, bool> validator, string? additional_info = null )
    {
        while( true )
        {
            // Try to use the cached one
            string? value = cache[ key ]?.ToString();

            try
            {
                if( !string.IsNullOrEmpty( value ) && validator( value ) )
                {
                    File.WriteAllText( FilePath, JsonConvert.SerializeObject( cache, Formatting.Indented ) );
                    break;
                }
            }
            catch { }

            Console.WriteLine( $"Invalid configuration '{key}'. Please input a valid value:" );

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
}
