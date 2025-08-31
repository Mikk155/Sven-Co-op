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

public class MapUpgrader
{
    public readonly ScriptEngine ScriptEngine;

    public MapUpgrader()
    {
#if DEBUG // Generate docs for python Type hints
        PyExportAPI PyAPI = new PyExportAPI();

        PyAPI.Generate( typeof(Entity), "Entity" );
        PyAPI.Generate( typeof(Vector), "Vector" );
        PyAPI.Generate( typeof(UpgradeContext), "UpgradeContext" );
#endif

        ScriptEngine = new ScriptEngine();
    }

    public void Initialize()
    {
        if( ScriptEngine.Mods.Count <= 0 )
        {
            Console.WriteLine( $"No scripts detected in the directory \"{Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" )}\"" );
            Console.ReadLine();
            return;
        }

        // -TODO Display a menu with all the available UpgradeContext in ScriptEngine.Mods and get a choice from the user
        foreach( UpgradeContext context in ScriptEngine.Mods )
        {
            InstallContext( context );
        }
    }

    private void InstallContext( UpgradeContext context )
    {
        Console.WriteLine( $"=================================================================" );
        Console.WriteLine( $"Name {context.Name}" );
        Console.WriteLine( $"Title {context.Title}" );
        Console.WriteLine( $"Description {context.Description}" );
        Console.WriteLine( $"Mod {context.Mod}" );
        Console.WriteLine( $"urls {string.Join( " ", context.urls )}" );

        if( context.maps is not null )
            Console.WriteLine( $"maps {string.Join( " ", context.maps )}" );

        Console.WriteLine( $"=================================================================" );

        context.Language.Shutdown();
    }

    ~MapUpgrader()
    {
        this.Shutdown();
    }

    public void Shutdown()
    {
        this.ScriptEngine.Shutdown();
    }
}
