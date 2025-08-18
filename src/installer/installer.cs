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

using System;
using System.Net.Http;
using System.Threading.Tasks;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

#if DEBUG
#pragma warning disable CS1998 // Async method lacks 'await' operators and will run synchronously
#endif

class Installer
{
    private static readonly Version version = new Version( 1, 0, 0 );

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

    static async Task Main()
    {
        // Read package
        string PackageRaw = await GetFile( "package.json" );

        JObject? Package;

        try
        {
            Package = JsonConvert.DeserializeObject<JObject>( PackageRaw );
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
}
