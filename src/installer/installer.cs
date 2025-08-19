/**
*    MIT License
*
*    Copyright (c) 2025 Mikk155
*
*    Permission is hereby granted, free of charge, to any person obtaining a copy
*    of this software and associated documentation files (the "Software"), to deal
*    in the Software without restriction, including without limitation the rights
*    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*    copies of the Software, and to permit persons to whom the Software is
*    furnished to do so, subject to the following conditions:
*
*    The above copyright notice and this permission notice shall be included in all
*    copies or substantial portions of the Software.
*
*    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*    SOFTWARE.
**/

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

#if DEBUG
#pragma warning disable CS1998 // Async method lacks 'await' operators and will run synchronously
#endif

class Installer
{
    private static readonly Version version = new Version( 1, 0, 0 );

#pragma warning disable CS8618
    private static Category Packages;
#pragma warning restore CS8618

    private static readonly string GithubUser = "Mikk155";
    private static readonly string GithubRepository = "Sven-Co-op";
    private static readonly string GithubBranch = "main";

    private static string GithubFullRepository =>
        $"https://github.com/{GithubUser}/{GithubRepository}";

#if DEBUG
    private static readonly string LocalRepository = Path.Combine( Directory.GetCurrentDirectory(), "..", ".." );
#endif

    private static async Task<string> GetFile( string FilePath )
    {
#if DEBUG
        return File.ReadAllText( Path.Combine( Path.Combine( LocalRepository, FilePath ) ) );
#else
        using HttpClient http = new HttpClient();
        return await http.GetStringAsync( $"{GithubFullRepository}/{GithubBranch}/{FilePath}" );
#endif
    }

    private static void ReportGithubIssue( string title, string body, Exception exception, bool critical )
    {
        Console.Beep();

        Console.WriteLine( $"There was an error\nPlease notify this in a github issue {GithubFullRepository}/issues" );
        Console.WriteLine( title );
        Console.WriteLine( $"Exception: {exception.Message}\n{exception}" );

        title = Uri.EscapeDataString( $"[Installer] {title}" );

        body = Uri.EscapeDataString( $"{body}\n> {exception.Message}\n## Exception:\n```\n{exception}`\n```\n" );

        string labels = Uri.EscapeDataString( "installer" );

        string url = $"{GithubFullRepository}/issues/new?title={title}&body={body}&labels={labels}";

        try
        {
            System.Diagnostics.Process.Start( new System.Diagnostics.ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            } );
        }
        catch { }

        if( critical )
        {
            Console.WriteLine( "Press enter to exit" );
            Console.ReadLine();
            Environment.Exit(1);
        }
    }

    /// <summary>
    /// Read the package from github or from the local repository if in debug mode
    /// </summary>
    private static async Task GetPackage()
    {
        string PackageRaw = await GetFile( "package.json" );

        try
        {
            JObject? PackageJson = JsonConvert.DeserializeObject<JObject>( PackageRaw );
            Packages = new Category( PackageJson );
        }
        catch( Exception exception )
        {
            ReportGithubIssue( "Failed to fetch package", "Json deserialization error", exception, true );
        }
    }

    private static async Task OpenUpdatedLink()
    {
//
        using HttpClient http = new HttpClient();
        http.DefaultRequestHeaders.UserAgent.ParseAdd( "AssetInstaller" );

        try
        {
            string GithubData = await http.GetStringAsync( $"https://api.github.com/repos/{GithubUser}/{GithubRepository}/releases/tags/installer-{Packages.version.ToString()}" );

            JObject? ReleaseData = JsonConvert.DeserializeObject<JObject>( GithubData );

            // string? url = ReleaseData?[ "html_url" ]?.ToString();
            // Assume is valid to get the proper exception
#pragma warning disable CS8602
            string url = ReleaseData[ "html_url" ].ToString();
#pragma warning restore CS8602

            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = url,
                UseShellExecute = true
            } );
        }
        catch( Exception exception )
        {
            Console.WriteLine( $"Error getting the Github release. Open the link manually. {GithubFullRepository}/releases" );
            ReportGithubIssue( "Failed to fetch release tag", $"unexistent version {Packages.version.ToString()}", exception, true );
        }
    }

    /// <summary>
    /// Check for updates.
    /// If we're in a old Major or Minor update the program exists.
    /// If we're in a old Patch the program just prints a warning.
    /// </summary>
    private static async Task CheckForUpdates()
    {
        if( Packages.version.Major > version.Major || Packages.version.Minor > version.Minor )
        {
            Console.Beep();

            Console.WriteLine( "There is a newer version of this program available and may be required." );

            Console.WriteLine( $"Current version: {version.ToString()}" );
            Console.WriteLine( $"Updated version: {Packages.version.ToString()}" );

            Console.WriteLine( "Press enter to exit" );

            await OpenUpdatedLink();

            Console.ReadLine();
            Environment.Exit(1);
        }
        else if( Packages.version.Patch > version.Patch )
        {
            Console.WriteLine( "There is patch available for this program." );

            Console.WriteLine( $"Current version: {version.ToString()}" );
            Console.WriteLine( $"Updated version: {Packages.version.ToString()}" );

            Console.WriteLine( "Write \"u\" to update." );

            if( Console.Read() == 'u' )
            {
                await OpenUpdatedLink();
            }
        }
    }

    static async Task InstallProject( Project project )
    {
        Console.WriteLine( $"Installing project {project.Name}" );
        Console.WriteLine( $"Project installed! Press Enter to continue." );
        Console.ReadLine();
    }

    static void RestoreConsole()
    {
        Console.Clear();
    }

    // Garbage code ahead but i ain't doing a UI yet!
    static async Task OpenMenu()
    {
        // If null assume we're in the category section
        Package? SelectedPackage = null;

        string? input;

        while( true )
        {
            if( SelectedPackage is null )
            {
                RestoreConsole();

                Console.WriteLine( "=== Select a category ===" );

                List<Package> NonEmptyPackages = new List<Package>();

                if( Packages.Plugins.Projects.Count > 0 )
                {
                    NonEmptyPackages.Add( Packages.Plugins );
                }
                if( Packages.MapScripts.Projects.Count > 0 )
                {
                    NonEmptyPackages.Add( Packages.MapScripts );
                }
                if( Packages.Tools.Projects.Count > 0 )
                {
                    NonEmptyPackages.Add( Packages.Tools );
                }
                if( Packages.UtilityScripts.Projects.Count > 0 )
                {
                    NonEmptyPackages.Add( Packages.UtilityScripts );
                }

                for( int i = 1; i <= NonEmptyPackages.Count; i++ )
                {
                    Package pkg = NonEmptyPackages[i-1];

                    Console.WriteLine( $"\n {i}: {pkg.Name}\n   {pkg.Description}\n" );
                }

                Console.WriteLine( " 0: Exit\n" );

                input = Console.ReadLine();

                if ( !string.IsNullOrEmpty( input ) && int.TryParse( input, out int CatResult ) )
                {
                    if( CatResult == 0 )
                    {
                        Environment.Exit(0);
                    }
                    else if( CatResult <= NonEmptyPackages.Count )
                    {
                        SelectedPackage = NonEmptyPackages[CatResult-1];
                    }
                }
                continue;
            }

            List<List<Project>> PagedProjects = [[]];

            int iCount = 0;
            int ListIndex = 0;

            foreach( Project p in SelectedPackage.Projects )
            {
                iCount++;

                if( iCount > 7 )
                {
                    iCount = 1;
                    PagedProjects.Add( new List<Project>() );
                    ListIndex++;
                }
                PagedProjects[ListIndex].Add(p);
            }

            int CurrentPage = 1;
            int MaxPages = PagedProjects.Count;

            while( SelectedPackage is not null )
            {
                RestoreConsole();

                Console.WriteLine( "=== Select a project to download ===" );

                List<Project> CurrentPageProjects = PagedProjects[CurrentPage - 1];
                int CurrentSizeOfProjects = CurrentPageProjects.Count;

                for( int i = 0; i < CurrentPageProjects.Count; i++ )
                {
                    Project project = CurrentPageProjects[i];

                    Console.WriteLine( $"\n {i + 1}: {project.Title}" );

                    if( !string.IsNullOrEmpty( project.Description ) )
                    {
                        Console.WriteLine( $"   {project.Description}" );
                    }
                }

                Console.WriteLine( "\n" );

                Console.WriteLine( ( CurrentPage == 1 ) ? "" : " 8: Previus page\n" );
                Console.WriteLine( ( CurrentPage == MaxPages ) ? "" : " 9: Next page\n" );

                Console.WriteLine( " 0: Back\n" );

                Console.WriteLine( $"=== current page {CurrentPage}/{MaxPages} ===" );

                input = Console.ReadLine();

                if( !string.IsNullOrEmpty( input ) )
                {
                    if( int.TryParse( input, out int result ) )
                    {
                        switch( result )
                        {
                            case 0:
                            {
                                SelectedPackage = null;
                                break;
                            }
                            case 8:
                            {
                                if( CurrentPage > 1 )
                                    CurrentPage--;
                                break;
                            }
                            case 9:
                            {
                                if( CurrentPage < MaxPages )
                                    CurrentPage++;
                                break;
                            }
                            default:
                            {
                                if( result <= CurrentSizeOfProjects )
                                {
                                    await InstallProject( CurrentPageProjects[result - 1] );
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    static async Task Main()
    {
        await GetPackage();
        await CheckForUpdates();
        await OpenMenu();
    }
}
