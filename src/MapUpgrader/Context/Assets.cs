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

namespace MapUpgrader.Context;

public class Assets()
{
    public Upgrade? owner;

    public Dictionary<string, string> AssetsList = new Dictionary<string, string>();

    /// <summary>
    /// Copy over an asset to the workspace directory.
    /// 
    /// if target is provided the destination path will be overriden
    /// 
    /// Supports wildcard "*" for a whole folder's files or a partial match for files starting with a prefix
    /// 
    /// When using wildcarding, the destination target must be a folder only
    /// 
    /// For entering folders use "/"
    /// </summary>
    public void install( string src, string? target = null )
    {
        ArgumentNullException.ThrowIfNull( this.owner );

        string? wildcard = null;

        Dictionary<string, string> assets = new Dictionary<string, string>();

        string[] src_folders = src.Split( "/" );

        string directory = this.owner.GetModPath();

        foreach( string folder in src_folders )
        {
            if( folder.Contains( '*' ) )
            {
                wildcard = folder;
                continue;
            }

            directory = Path.Combine( directory, folder );
        }

        if( wildcard is null )
        {
            CopyAssetToWorkspace( directory, target ?? src );
        }
        else if( wildcard == "*" )
        {
            foreach( string asset in Directory.GetFiles( directory ) )
            {
                string relative = Path.GetRelativePath( this.owner.GetModPath(), asset );
                CopyAssetToWorkspace( asset, target is not null ? Path.Combine( target, Path.GetFileName( relative ) ) : relative );
            }
        }
        else
        {
            foreach( string asset in Directory.GetFiles( directory, wildcard ) )
            {
                string relative = Path.GetRelativePath( this.owner.GetModPath(), asset );
                CopyAssetToWorkspace( asset, target is not null ? Path.Combine( target, Path.GetFileName( relative ) ) : relative );
            }
        }
    }

    private void CopyAssetToWorkspace( string src, string target )
    {
        string destination = Path.Combine( App.WorkSpace, target );

        if( !File.Exists( src ) )
        {
            this.owner!.logger.warn
                .Write( "Unknown asset file at \"" )
                .Write( src, ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine();
            return;
        }

        string? folder = Path.GetDirectoryName( destination );

        if( !string.IsNullOrEmpty( folder ) && !Directory.Exists( folder ) )
        {
            Directory.CreateDirectory( folder );
        }

        FileInfo isrc = new FileInfo( src );
        FileInfo idest = new FileInfo( destination );

        if( !File.Exists( destination ) || isrc.Length != idest.Length || isrc.LastWriteTimeUtc != idest.LastWriteTimeUtc )
        {
            Mikk.Logger.Logger log = this.owner!.logger.info;

            if( log.IsLevelActive )
            {
                string log_src = Path.GetRelativePath( this.owner.GetModPath(), src );
                string log_dest = Path.GetRelativePath( App.WorkSpace, destination );

                log.Write( "Copying asset \"" ).Write( log_src, ConsoleColor.Green );

                if( log_src != log_dest )
                {
                    log.Write( "\" -> \"" ).Write( log_dest, ConsoleColor.Cyan );
                }

                log.WriteLine( "\"" );
            }

            File.Copy( src, destination, true );
        }
        else
        {
            this.owner!.logger.trace
                .Write( "File \"" )
                .Write( Path.GetRelativePath( App.WorkSpace, destination ), ConsoleColor.Yellow )
                .WriteLine( "\" Up-to-date" );
        }
    }

    ~Assets()
    {
        this.owner = null;
    }
}
