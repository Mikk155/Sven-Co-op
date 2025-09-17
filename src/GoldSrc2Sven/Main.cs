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

namespace GoldSrc2Sven;

using Mikk.Logger;
using Mikk.Arguments;

public static class App
{
    public static readonly Logger logger = new Logger( "GoldSrc2Sven", ConsoleColor.DarkMagenta );

    /// <summary>
    /// Arguments provided on the App's execution
    /// </summary>
    public static Arguments arguments = null!;

    /// <summary>
    /// Scripting engine and all the supported languages
    /// </summary>
    public static engine.ScriptEngine engine = null!;

    public static void Main( params string[] args )
    {
        App.arguments = new Arguments( args );

        App.engine = new engine.ScriptEngine();

        Console.CancelKeyPress += (p, e) =>
        {
            App.Shutdown();
        };

        AppDomain.CurrentDomain.ProcessExit += (p, e) =>
        {
            App.Shutdown();
        };


        if( App.engine.Mods.Count <= 0 )
        {
            App.logger.error
                .Write( "No valid scripts detected in the directory \"" )
                .Write( App.FullScriptingFolder, ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine()
                .Call( App.Shutdown )
                .Pause()
                .Exit();
        }

        List<Context.Upgrade> mods = ContextSelector.GetContexts();

        if( mods.Count <= 0 )
        {
            App.logger.error
                .Write( "No upgrades selected." )
                .NewLine()
                .Beep()
                .Call( App.Shutdown )
#if DEBUG
#else
                .Pause()
#endif
                .Exit();
        }

        foreach( Context.Upgrade context in mods )
        {
            context.logger.info
                .Write( "Installing " )
                .Write( context.Name, ConsoleColor.Green )
                .Write( " (" )
                .Write( context.title, ConsoleColor.Cyan )
                .WriteLine( ")" );

            context._Language.install_assets( context );

            foreach( string map in Directory.GetFiles( Path.Combine( App.WorkSpace, "maps" ), "*.bsp" ) )
            {
                context.logger.info.Write( "Updating map " ).WriteLine( map, ConsoleColor.Cyan );

                Context.Map map_context = new Context.Map( map, context );

                context.maps_context.Add( map_context );

                map_context.owner._Language.upgrade_map( map_context );

                context.logger.info.Write( "Writing map " ).WriteLine( map, ConsoleColor.Cyan );

                map_context._WriteBSP();
            }

            context.Shutdown();
        }

        App.Shutdown();
    }

    /// <summary>
    /// Workspace directory for assets manipulation
    /// </summary>
    public static string WorkSpace
    {
        get
        {
            string dir = Path.Combine( Directory.GetCurrentDirectory(), "workspace" );

            if( !Directory.Exists( dir ) )
                Directory.CreateDirectory( dir );

            return dir;
        }
    }

    public static string ScriptingFolder = "scripts";

    /// <summary>
    /// Workspace directory for assets manipulation
    /// </summary>
    public static readonly string FullScriptingFolder =
        Path.Combine( Directory.GetCurrentDirectory(), ScriptingFolder );

    private static bool _ShutDown = false;

    public static void Shutdown()
    {
        if( App._ShutDown )
            return;

        App._ShutDown = true;

        App.logger.debug.WriteLine( "Shutting down" );

        App.engine.Shutdown();

        Console.ResetColor();
        Console.Beep();
    }
}
