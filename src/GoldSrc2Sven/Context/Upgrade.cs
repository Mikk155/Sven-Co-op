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

using Mikk.Logger;

using GoldSrc2Sven.engine;
using GoldSrc2Sven.Config;

#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a context for upgrading</summary>
public class Upgrade
{
    public readonly Logger logger;

    public Upgrade( ILanguage lang, string src )
    {
        this._Language = lang;
        this.Script = src;
        this.logger = new Logger( this.Name, ConsoleColor.DarkGreen );
    }

    /// <summary>The scripting engine interface used for this upgrade.</summary>
    public readonly ILanguage _Language;

    /// <summary>The absolute file path for the script for this upgrade.</summary>
    public readonly string Script;

    /// <summary>The script filename without extension for this upgrade.</summary>
    public string Name =>
        Path.GetFileName( this.Script );

    /// <summary>
    /// Absolute path to the port workspace
    /// </summary>
    public string Workspace =>
        App.WorkSpace;

    /// <summary>
    /// List of maps in the workspace
    /// </summary>
    public string[] maps =>
        Directory.GetFiles( Path.Combine( App.WorkSpace, "maps" ), "*.bsp" );

    // -TODO These members aren't exported to python API
    /// <summary>Title to display as an option.</summary>
    public string title = null!;

    /// <summary>Mod folder to install assets.</summary>
    public string mod = null!;

    /// <summary>Mod download URL or multiple url for mirroring..</summary>
    public string[] urls = null!;

    /// <summary>Optional description to display as an option.</summary>
    public string? description { get; set; }

    /// <summary>
    /// Assets to copy over from the mod directory
    /// </summary>
    public Context.Assets assets = new Context.Assets();

    private string _ModDirectory => Path.Combine( this.GetHalfLifeInstallation(), this.mod );

    /// <summary>
    /// Get the mod's installation absolute path
    /// </summary>
    /// <returns>The absolute path directory to the mod installation</returns>
    public string GetModPath()
    {
        string dir = this._ModDirectory;

        if( Directory.Exists( dir ) )
            return dir;

        Logger log = App.logger.error
            .Write( "The mod \"" )
            .Write( this.mod, ConsoleColor.Green )
            .Write( "\" doesn't exists in the directory \"" )
            .Write( dir, ConsoleColor.Cyan )
            .Write( "\"" )
            .NewLine()
            .Write( "Are you sure it is installed? Try one of the following mirrors:" )
            .NewLine();

        foreach( string url in urls )
        {
            log.WriteLine( url, ConsoleColor.Yellow );
        }

        log.Call( App.Shutdown ).Pause().Exit();

        return string.Empty;
    }

    public List<Context.Map> maps_context = new List<Context.Map>()!;

    /// <summary>
    /// Get the absolute path to a Steam installation
    /// </summary>
    /// <returns>The absolute path directory to Steam</returns>
    public string? SteamInstallation()
    {
        if( OperatingSystem.IsWindows() )
        {
            using Microsoft.Win32.RegistryKey? key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey( @"Software\Valve\Steam" );
            return key?.GetValue( "SteamPath" )?.ToString();
        }
        else if( OperatingSystem.IsLinux() )
        {
            string SteamPath, UserProfile = Environment.GetFolderPath( Environment.SpecialFolder.UserProfile );

            SteamPath = Path.Combine( UserProfile, ".steam/steam" );

            if( Directory.Exists( SteamPath ) )
            {
                return SteamPath;
            }

            SteamPath = Path.Combine( UserProfile, ".local/share/Steam" );

            if( Directory.Exists( SteamPath ) )
            {
                return SteamPath;
            }
        }

        App.logger.error.WriteLine( "Failed to find Steam installation." );

        return null;
    }

    private string _GetSteamGameInstallation( string folder_name, string unique_name, string game_name, string env_name )
    {
        string? GameInstallationPath = null, SteamPath = this.SteamInstallation();

        if( SteamPath is not null )
        {
            GameInstallationPath = Path.Combine( SteamPath, "steamapps", "common", folder_name );

            if( !Directory.Exists( GameInstallationPath ) || !Directory.Exists( Path.Combine( GameInstallationPath, unique_name ) ) )
            {
                GameInstallationPath = null;
            }
        }

        if( GameInstallationPath is not null && !App.cache.data.ContainsKey( env_name ) )
        {
            Console.WriteLine( $"Detected {game_name} installation at \"{GameInstallationPath}\"" );
            Console.WriteLine( $"Want to override with a custom path? Y/N" );
            string? input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) && input.ToLower()[0] == 'y' )
            {
                GameInstallationPath = null;
            }
            else
            {
                App.cache.Write();
            }
        }

        if( string.IsNullOrEmpty( GameInstallationPath ) )
        {
            App.cache.UserConfig( env_name, value =>
            {
                GameInstallationPath = value;

                if( !Directory.Exists( GameInstallationPath ) )
                {
                    throw new DirectoryNotFoundException( $"Unexistent directory \"{GameInstallationPath}\"" );
                }

                if( !Directory.Exists( Path.Combine( GameInstallationPath, unique_name ) ) )
                {
                    throw new DirectoryNotFoundException( $"Invalid {game_name} directory at \"{GameInstallationPath}\"" );
                }

                return true; // No exception raised. break the loop
            }, $"Absolute path to your {game_name} installation, it usually looks like \"C:\\Program Files (x86)\\Steam\\steamapps\\common\\{folder_name}\"" );
        }

        return GameInstallationPath!;
    }

    /// <summary>
    /// Get the path to the Half-Life installation
    /// </summary>
    /// <returns>The absolute path to the Half-Life folder</returns>
    public string GetHalfLifeInstallation()
    {
        return _GetSteamGameInstallation( "Half-Life", "valve", "Half-Life", "halflife_installation" );
    }

    /// <summary>
    /// Get the path to the Sven Co-op installation
    /// </summary>
    /// <returns>The absolute path to the Sven Co-op folder</returns>
    public string GetSvenCoopInstallation()
    {
        return _GetSteamGameInstallation( "Sven Co-op", "svencoop", "Sven Co-op", "svencoop_installation" );
    }

    private bool _Initialized;

    public void Initialize()
    {
        if( this._Initialized )
            return;

        this._Initialized = true;

        this.assets.owner = this;

        ArgumentNullException.ThrowIfNull( this.mod );
        ArgumentNullException.ThrowIfNull( this.urls );
        ArgumentNullException.ThrowIfNull( this.title );

        // Early exit if uninstalled
        this.GetModPath();
    }

    ~Upgrade()
    {
        this.Shutdown();
    }

    public void Shutdown()
    {
        this.assets = null!;
    }
}
#pragma warning restore IDE1006 // Naming Styles
