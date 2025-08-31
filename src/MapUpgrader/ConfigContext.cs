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

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class ConfigContext
{
    public readonly Logger logger = new Logger( "Configuration", ConsoleColor.Red );

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

            logger.warn( $"Invalid configuration '{key}'. Please input a valid value:" );

            if( additional_info is not null )
            {
                logger.info( additional_info );
            }

            string? input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) )
            {
                cache[ key ] = input;
            }
        }
    }
}
