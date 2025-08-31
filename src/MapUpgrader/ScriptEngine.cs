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
    public readonly Logger logger = new Logger( "Script Engine", ConsoleColor.Green );

    public readonly List<UpgradeContext> Mods = new List<UpgradeContext>();

    public readonly Dictionary<string, ILanguageEngine> Languages = new Dictionary<string, ILanguageEngine>()
    {
        { ".py", new PythonLanguage() }
    };

    public ScriptEngine()
    {
        // Get all script files
        List<string> ScriptFiles = Directory.GetFiles(
                Path.Combine( Directory.GetCurrentDirectory(), "Upgrades" )
            )
            .Where( file => this.Languages.ContainsKey( Path.GetExtension( file ) ) )
            .ToList();

        foreach( string file in ScriptFiles )
        {
            string FileExtension = Path.GetExtension( file );

            ILanguageEngine lang = Languages[ FileExtension ];

            logger.info( $"Initializing language engine {lang.GetName()} for file {Path.GetFileName(file)}" );

            UpgradeContext? context = lang.Initialize( file );

            if( context is not null )
            {
                Mods.Add( context );
            }
            else
            {
                logger.error( $"Got an empty context from {lang.GetName()} for {file}" );
            }
        }
    }

    ~ScriptEngine()
    {
        Shutdown();
    }

    public void Shutdown()
    {
        logger.info( "Shutting down" );

        foreach( KeyValuePair<string, ILanguageEngine> e in Languages )
        {
            if( e.Value is not null )
            {
                e.Value.Shutdown();
            }
        }
    }
}
