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

#if DEBUG
#pragma warning disable CS1998
#endif

class Installer
{
    private static readonly string Repository = "https://raw.githubusercontent.com/Mikk155/Sven-Co-op/main/";

#if DEBUG
    private static readonly string Workspace = Path.Combine( Directory.GetCurrentDirectory(), "..", ".." );
#endif

    private static async Task<string> GetFile( string FilePath )
    {
#if DEBUG
        return File.ReadAllText( Path.Combine( Path.Combine( Workspace, FilePath ) ) );
#else
        using HttpClient http = new HttpClient();
        return await http.GetStringAsync( $"{Repository}{FilePath}" );
#endif
    }

    static async Task Main()
    {
        string PackageRaw = await GetFile( "package.json" );
        Console.WriteLine( PackageRaw );
    }
}
