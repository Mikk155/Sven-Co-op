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

using Spectre.Console;
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

        AnsiConsole.MarkupLine( $"[##486088]There was an error\nPlease notify this in a github issue [#00ff00]{GithubFullRepository}/issues[/][/]" );
        AnsiConsole.MarkupLine( $"[#f00]{title}[/]" );
        AnsiConsole.MarkupLine( $"[#486088][#00ff00]Exception[/]: [#f85]{exception.Message}[/]\n[#f00]{exception}[/][/]" );

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
            AnsiConsole.MarkupLine( "[#f00]Press enter to exit[/]" );
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
            AnsiConsole.MarkupLine( $"[#486088]Error getting the Github release. Open the link manually. [#00ff00]{GithubFullRepository}/releases[/][/]" );
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

            AnsiConsole.MarkupLine( "[#486088]There is a newer version of this program available and may be required.[/]" );

            AnsiConsole.MarkupLine( $"[#486088]Current version: [#00ff00]{version.ToString()}[/][/]" );
            AnsiConsole.MarkupLine( $"[#486088]Updated version: [#00ff00]{Packages.version.ToString()}[/][/]" );

            AnsiConsole.MarkupLine( "[#f00]Press enter to exit[/]" );

            await OpenUpdatedLink();

            Console.ReadLine();
            Environment.Exit(1);
        }
        else if( Packages.version.Patch > version.Patch )
        {
            AnsiConsole.MarkupLine( "[#486088]There is patch available for this program.[/]" );

            AnsiConsole.MarkupLine( $"[#486088]Current version: [#00ff00]{version.ToString()}[/][/]" );
            AnsiConsole.MarkupLine( $"[#486088]Updated version: [#00ff00]{Packages.version.ToString()}[/][/]" );

            AnsiConsole.MarkupLine( "[#486088]Write \"[#00ff00]u[/]\" to update.[/]" );

            if( Console.Read() == 'u' )
            {
                await OpenUpdatedLink();
            }
        }
    }

    static async Task InstallProject( Project project )
    {
        AnsiConsole.MarkupLine( $"[#486088]Installing project [#00ff00]{project.Name}[/][/]" );
        AnsiConsole.MarkupLine( $"[#486088]Project installed![/]" );
        AnsiConsole.MarkupLine( "[#00ff00]Press enter to continue[/]" );
        Console.ReadLine();
    }

    static string? FormatedAsciArt;
    static string AsciArt = 
"""
               #**************               
          %%###*************####***          
        ######*********** ####*******        
      ######**      ****#      ********      
    ######************#####**************    
   ######***********#####***************##   
  ###### ********  %%##**   ******** **##**  
 ####**    ******#% #**** ********    ##**** 
####**       **#####************       ******
##***          #%#************          *****
#**********#####************            *****
*********######************             *****
********#####***************            ****#
******#####**       ********#%          **###
****#% ##*****      *******###*        **####
**####  ********    *****###*****      *#####
 #####*   ********  ****#  ********   #####% 
  ##****    ***********##    ********####%#  
   *******    *******###*      *****#####%   
    ********   *****##***        *######%    
      *********  *###****     ***#####%      
        *********###***********####%%        
          ******##************###%%          
               ##***********##               
""";

    static string GetAsciArt()
    {
        if( FormatedAsciArt is null )
        {
            char? currentSymbol = null;
            FormatedAsciArt = "";

            foreach( char c in AsciArt )
            {
                if( c == '#' || c == '%' || c == '*' )
                {
                    if( currentSymbol != c )
                    {
                        if( currentSymbol != null )
                            FormatedAsciArt += "[/]";
                        if( c == '#' )
                            FormatedAsciArt += "[#ae18f1]";
                        else if( c == '%' )
                            FormatedAsciArt += "[#ae05b1]";
                        else if( c == '*' )
                            FormatedAsciArt += "[#ae18b2]";
                        currentSymbol = c;
                    }
                }

                FormatedAsciArt += c;
            }
            FormatedAsciArt += "[/]";
            AsciArt = string.Empty;
        }
        return FormatedAsciArt;
    }

    static void RestoreConsole()
    {
        Console.Clear();
        AnsiConsole.MarkupLine( GetAsciArt() );
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

                AnsiConsole.MarkupLine( "[#f00]=== [#486088]Select a category[/] ===[/]" );

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

                    AnsiConsole.MarkupLine( $"\n [#f00]{i}[/]: [#00ff00]{pkg.Name}[/]\n   [#486088]{pkg.Description}[/]\n" );
                }

                AnsiConsole.MarkupLine( " [#f00]0[/]: [#f00]Exit[/]\n" );

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

                AnsiConsole.MarkupLine( "[#f00]=== [#486088]Select a project to download[/] ===[/]" );

                List<Project> CurrentPageProjects = PagedProjects[CurrentPage - 1];
                int CurrentSizeOfProjects = CurrentPageProjects.Count;

                for( int i = 0; i < CurrentPageProjects.Count; i++ )
                {
                    Project project = CurrentPageProjects[i];

                    AnsiConsole.MarkupLine( $"\n [#f00]{i + 1}[/]: [#00ff00]{project.Title}[/]" );

                    if( !string.IsNullOrEmpty( project.Description ) )
                    {
                        AnsiConsole.MarkupLine( $"   [#486088]{project.Description}[/]" );
                    }
                }

                Console.WriteLine( "\n" );

                AnsiConsole.MarkupLine( ( CurrentPage == 1 ) ? "" : " [#f00]8[/]: [#f50]Previus page[/]\n" );
                AnsiConsole.MarkupLine( ( CurrentPage == MaxPages ) ? "" : " [#f00]9[/]: [#f50]Next page[/]\n" );

                AnsiConsole.MarkupLine( " [#f00]0[/]: [#f50]Back[/]\n" );

                AnsiConsole.MarkupLine( $"[#f00]=== [#486088]current page [#00ff00]{CurrentPage}[/][#f00]/[/][#00ff00]{MaxPages}[/][/] ===[/]" );

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
