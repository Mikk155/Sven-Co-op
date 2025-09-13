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

public static class App
{
    /// <summary>
    /// .NET version to retrieve xml files from
    /// </summary>
    public const string NETVersion = "net9.0";

    /// <summary>
    /// Workspace directory
    /// </summary>
    public static string WorkSpace = App._Getworkspace_();

    private static string _Getworkspace_()
    {
        string dir = Path.Combine( Directory.GetCurrentDirectory(), "workspace" );

        if( !Directory.Exists( dir ) )
            Directory.CreateDirectory( dir );

        return dir;
    }

    private static MapUpgrader _upgrader_ = null!;

    /// <summary>
    /// Program itself
    /// </summary>
    public static MapUpgrader Upgrader => App._upgrader_;

    private static string[] _args_ = [];

    /// <summary>
    /// launch parameters
    /// </summary>
    public static string[] Arguments = App._args_;

    public static void Main( params string[] args )
    {
        App._args_ = args;

        App._upgrader_ = new MapUpgrader();

        Console.CancelKeyPress += (p, e) =>
        {
            App.Upgrader.Shutdown();
        };

        AppDomain.CurrentDomain.ProcessExit += (p, e) =>
        {
            App.Upgrader.Shutdown();
        };

        App.Upgrader.Initialize();
        App.Upgrader.Shutdown();
    }
}
