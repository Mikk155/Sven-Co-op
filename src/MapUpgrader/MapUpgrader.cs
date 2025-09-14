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
                .Write( Path.Combine( Directory.GetCurrentDirectory(), ScriptEngine.ScriptingFolder ), ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine()
                .Beep()
                .Call( this.Shutdown )
                .Pause()
                .Exit();
        }

        List<UpgradeContext> mods = ContextSelector.GetContexts();

        if( mods.Count <= 0 )
        {
            MapUpgrader.logger.error
                .Write( "No upgrades selected." )
                .NewLine()
                .Beep()
                .Call( this.Shutdown )
                .Pause()
                .Exit();
        }

        foreach( UpgradeContext context in mods )
        {
            InstallContext( context );
        }
    }

    private void InstallContext( UpgradeContext context )
    {
        context.logger.info
            .Write( "Installing " )
            .Write( context.Name, ConsoleColor.Green )
            .Write( " (" )
            .Write( context.title, ConsoleColor.Cyan )
            .WriteLine( ")" );

        context._Language.GetAssets( context );

        foreach( string map in Directory.GetFiles( Path.Combine( App.WorkSpace, "maps" ), "*.bsp" ) )
        {
            context.logger.info.Write( "Updating map " ).WriteLine( map, ConsoleColor.Cyan );

            MapContext map_context = new MapContext( map, context );

            context.maps.Add( map_context );

            using FileStream fs = File.OpenRead( map_context.filepath );

            Sledge.Formats.Bsp.BspFile BSP = new Sledge.Formats.Bsp.BspFile( fs );

            Sledge.Formats.Bsp.Lumps.Entities BSPEntities = BSP.GetLump<Sledge.Formats.Bsp.Lumps.Entities>();

            foreach( Sledge.Formats.Bsp.Objects.Entity entity in BSPEntities )
            {
                map_context.entities.Add( new Entity( entity ) );
            }

            BSPEntities.Clear();

            foreach( Entity entity in map_context.entities )
            {
                BSPEntities.Add( entity.entity );
            }

            map_context.owner._Language.UpgradeMap( map_context );

            BSP.WriteToStream( fs, BSP.Version );
        }

        context.Shutdown();
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
