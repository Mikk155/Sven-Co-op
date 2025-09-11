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

public class MapUpgrader()
{
    public static readonly Logger logger = new Logger( "MapUpgrader", ConsoleColor.DarkMagenta );

    public readonly ScriptEngine ScriptEngine = new ScriptEngine();

    public void Initialize()
    {
        ScriptEngine.Initialize();

        if( ScriptEngine.Mods.Count <= 0 )
        {
            MapUpgrader.logger.error
                .Write( "No scripts detected in the directory \"" )
                .Write( Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" ), ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine()
                .Beep()
                .Pause()
                .Exit( this.Shutdown );
        }

        List<UpgradeContext> mods = ContextSelector.GetContexts();

        if( mods.Count <= 0 )
        {
            MapUpgrader.logger.error
                .Write( "No upgrades selected." )
                .NewLine()
                .Beep()
                .Exit( this.Shutdown );
        }

        foreach( UpgradeContext context in mods )
        {
            InstallContext( context );
        }
    }

    private void InstallContext( UpgradeContext context )
    {
        MapUpgrader.logger.info.WriteLine( $"=================================================================" );
        MapUpgrader.logger.info.WriteLine( $"Name {context.Name}" );
        MapUpgrader.logger.info.WriteLine( $"Title {context.title}" );
        MapUpgrader.logger.info.WriteLine( $"Description {context.description}" );
        MapUpgrader.logger.info.WriteLine( $"Mod {context.mod}" );
        MapUpgrader.logger.info.WriteLine( $"urls {string.Join( " ", context.urls )}" );

        if( context.maps is not null )
            MapUpgrader.logger.info.WriteLine( $"maps {string.Join( " ", context.maps )}" );

        MapUpgrader.logger.warn.WriteLine( context.GetHalfLifeInstallation() );

        MapUpgrader.logger.info.WriteLine( $"=================================================================" );

        context.Language.Shutdown();
    }

    ~MapUpgrader()
    {
        this.Shutdown();
    }

    private bool _ShutDown = false;

    public void Shutdown()
    {
        if( this._ShutDown )
            return;

        this._ShutDown = true;
        MapUpgrader.logger.debug.WriteLine( "Shutting down" );
        this.ScriptEngine.Shutdown();
        Console.ResetColor();
        Console.Beep();
    }
}
