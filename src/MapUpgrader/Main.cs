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

using System.Runtime.Versioning;

class Program
{
    /// <summary>
    /// .NET version to retrieve xml files from
    /// </summary>
    public const string FrameworkVersion = "net9.0";

    /// <summary>
    /// Workspace directory
    /// </summary>
    public static string WorkSpace = Getworkspace();

    // Constant variables defined here in case of updating
    public static string HookName_Init = "OnRegister";

    private static string Getworkspace()
    {
        string dir = Path.Combine( Directory.GetCurrentDirectory(), "workspace" );

        if( !Directory.Exists( dir ) )
            Directory.CreateDirectory( dir );

        return dir;
    }

    public static readonly MapUpgrader Upgrader = new MapUpgrader();

    public static void Main()
    {
        Console.CancelKeyPress += (p, e) =>
        {
            Upgrader.Shutdown();
        };

        AppDomain.CurrentDomain.ProcessExit += (p, e) =>
        {
            Upgrader.Shutdown();
        };

        Upgrader.Initialize();
        Upgrader.Shutdown();
    }
}
