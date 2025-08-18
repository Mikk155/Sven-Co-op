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
    private static Package package;
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

    /// <summary>
    /// Read the package from github or from the local repository if in debug mode
    /// </summary>
    private static async Task GetPackage()
    {
        string PackageRaw = await GetFile( "package.json" );

        try
        {
            JObject? PackageJson = JsonConvert.DeserializeObject<JObject>( PackageRaw );
            package = new Package( PackageJson );
        }
        catch( Exception e )
        {
            Console.Beep();

            Console.WriteLine( $"Something went wrong fetching the package.\nPlease notify this in a github issue {GithubFullRepository}/issues\nException: {e}" );

            string title = Uri.EscapeDataString( "[Asset Installer] Package fetch error" );

            string body = Uri.EscapeDataString( $"Something went wrong fetching the package:\n> {e.Message}\n## Exception:\n```\n{e}`\n```\n" );

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

            Console.WriteLine( "Press enter to exit" );
            Console.ReadLine();
            Environment.Exit(1);
        }
    }

    private static async Task OpenUpdatedLink()
    {
    }

    /// <summary>
    /// Check for updates.
    /// If we're in a old Major or Minor update the program exists.
    /// If we're in a old Patch the program just prints a warning.
    /// </summary>
    private static async Task CheckForUpdates()
    {
        if( package.version.Major > version.Major || package.version.Minor > version.Minor )
        {
            Console.Beep();

            Console.WriteLine( "There is a newer version of this program available and may be required." );

            Console.WriteLine( $"Current version: {version.ToString()}" );
            Console.WriteLine( $"Updated version: {package.version.ToString()}" );

            Console.WriteLine( "Press enter to exit" );

            await OpenUpdatedLink();

            Console.ReadLine();
            Environment.Exit(1);
        }
        else
        {
            Console.WriteLine( "There is patch available for this program." );

            Console.WriteLine( $"Current version: {version.ToString()}" );
            Console.WriteLine( $"Updated version: {package.version.ToString()}" );

            Console.WriteLine( "Write \"u\" to update." );

            if( Console.Read() == 'u' )
            {
                await OpenUpdatedLink();
            }
        }
    }

    static async Task Main()
    {
        await GetPackage();
        await CheckForUpdates();
    }
}
