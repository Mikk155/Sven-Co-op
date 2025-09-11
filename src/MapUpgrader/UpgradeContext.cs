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

using Mikk.Logger;

#pragma warning disable IDE1006 // Naming Styles
/// <summary>Represents a context for upgrading</summary>
public class UpgradeContext( ILanguageEngine Language, string Script )
{
    /// <summary>The scripting engine interface used for this upgrade.</summary>
    public readonly ILanguageEngine Language = Language;

    /// <summary>The absolute file path for the script for this upgrade.</summary>
    public readonly string Script = Script;

    /// <summary>The script filename without extension for this upgrade.</summary>
    public string Name =>
        Path.GetFileName( this.Script );

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
    public Assets assets = new Assets();

    /// <summary>Maps to upgrade. Leave empty to upgrade all maps.</summary>
    public string[]? maps { get; set; }

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

        Logger log = MapUpgrader.logger.error
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

        log.Call( Program.Upgrader.Shutdown ).Beep().Pause().Exit();

        return string.Empty;
    }

    /// <summary>
    /// Get the list of defined maps or all the maps in the mod installation if the script left it empty.
    /// </summary>
    /// <returns></returns>
    public string[] GetMaps()
    {
        if( this.maps is null || this.maps.Length <= 0 )
        {
            this.maps = Directory.GetFiles( Path.Combine( this.GetModPath(), "maps" ) )
                .Select( m => Path.GetFileNameWithoutExtension( m ) )
                .ToArray();
        }

        return this.maps;
    }

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

        MapUpgrader.logger.error.WriteLine( "Failed to find Steam installation." );

        return null;
    }

    /// <summary>
    /// Get the path to the Half-Life installation
    /// </summary>
    /// <returns>The absolute path to the Half-Life folder</returns>
    public string GetHalfLifeInstallation()
    {
        string? HalfLifePath = null, SteamPath = this.SteamInstallation();

        if( SteamPath is not null )
        {
            HalfLifePath = Path.Combine( SteamPath, "steamapps", "common", "Half-Life" );

            if( !Directory.Exists( HalfLifePath ) || !Directory.Exists( Path.Combine( HalfLifePath, "valve" ) ) )
            {
                HalfLifePath = null;
            }
        }

        if( !ConfigContext.cache.ContainsKey( "halflife_installation" ) )
        {
            Console.WriteLine( $"Detected Half-Life installation at \"{HalfLifePath}\"" );
            Console.WriteLine( $"Want to override with a custom path? Y/N" );
            string? input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) && input.ToLower()[0] == 'y' )
            {
                HalfLifePath = null;
            }
        }
        else
        {
            HalfLifePath = null;
        }

        if( string.IsNullOrEmpty( HalfLifePath ) )
        {
            ConfigContext.Get( "halflife_installation", value =>
            {
                HalfLifePath = value;

                if( !Directory.Exists( HalfLifePath ) )
                {
                    throw new DirectoryNotFoundException( $"Unexistent directory \"{HalfLifePath}\"" );
                }

                if( !Directory.Exists( Path.Combine( HalfLifePath, "valve" ) ) )
                {
                    throw new DirectoryNotFoundException( $"Invalid Half-Life directory at \"{HalfLifePath}\"" );
                }

                return true; // No exception raised. break the loop
            }, "Absolute path to your Half-Life installation, it usually looks like \"C:\\Program Files (x86)\\Steam\\steamapps\\common\\Half-Life\"" );
        }

        return HalfLifePath!;
    }
}
#pragma warning restore IDE1006 // Naming Styles
