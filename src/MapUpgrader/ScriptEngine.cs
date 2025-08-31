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

public interface ILanguageEngine
{
    public string GetName();
    public void Shutdown();
    public UpgradeContext? Initialize( string script );
}

public class ScriptEngine
{
    public readonly Dictionary<string, ILanguageEngine> Languages = new Dictionary<string, ILanguageEngine>()
    {
        { ".py", new PythonLanguage() }
    };

    public Dictionary<string, List<string>> Scripts = new Dictionary<string, List<string>>();

    public ScriptEngine()
    {
        // Get all script files
        List<string> ScriptFiles = Directory.GetFiles(
                Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" )
            )
            .Where( file => this.Languages.ContainsKey( Path.GetExtension( file ) ) )
            .ToList();

        string[]? ScriptModule = null;

        foreach( string file in ScriptFiles )
        {
            string FileExtension = Path.GetExtension( file );

            List<string>? OrganizedScriptFiles;

            // Organize scripts to their languages
            if( Scripts.TryGetValue( FileExtension, out OrganizedScriptFiles ) && OrganizedScriptFiles is not null )
            {
                OrganizedScriptFiles.Add( file );
            }
            else
            {
                OrganizedScriptFiles = new List<string>(){ file };
                Scripts[ FileExtension ] = OrganizedScriptFiles;
            }

            // -TODO Add a contextual menu for the user to choose what to install
            // In the meanwhile use the last file found for testing
            ScriptModule = [ FileExtension, file ];
            break;
        }

        if( ScriptModule is not null )
        {
            ILanguageEngine lang = Languages[ ScriptModule[0] ];
            UpgradeContext? context = lang.Initialize( ScriptModule[1] );

            if( context is not null )
            {
                Console.WriteLine( $"Name {context.Name}" );
                Console.WriteLine( $"Description {context.Description}" );
                Console.WriteLine( $"Mod {context.Mod}" );
                Console.WriteLine( $"urls {string.Join( " ", context.urls )}" );
                if( context.maps is not null )
                    Console.WriteLine( $"maps {string.Join( " ", context.maps )}" );
            }

            lang.Shutdown();
        }
    }

    ~ScriptEngine()
    {
        Shutdown();
    }

    public void Shutdown()
    {
        foreach( KeyValuePair<string, ILanguageEngine> e in Languages )
        {
            if( e.Value is not null )
            {
                e.Value.Shutdown();
            }
        }
    }
}
