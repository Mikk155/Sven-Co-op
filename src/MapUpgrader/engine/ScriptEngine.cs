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

namespace MapUpgrader.engine;

using Mikk.Logger;

public class ScriptEngine
{
    public static readonly Logger logger = new Logger( "Script Engine", ConsoleColor.DarkGreen );

    /// <summary>
    /// List containing all the supported scripting languages
    /// </summary>
    public readonly List<ILanguage> Languages = new List<ILanguage>();

    /// <summary>
    /// List containing all the available script files
    /// </summary>
    public readonly List<Context.Upgrade> Mods = new List<Context.Upgrade>();

    public ScriptEngine()
    {
        // Initialize languages by Reflection on ILanguage
        foreach( Type type in System.Reflection.Assembly.GetExecutingAssembly().GetTypes() )
        {
            if( typeof(ILanguage).IsAssignableFrom( type ) && type.IsClass && !type.IsAbstract )
            {
                ILanguage language = (ILanguage)Activator.CreateInstance( type )!;

                ScriptEngine.logger.info
                    .Write( "Initializing scripting language \"" )
                    .Write( language.GetName(), ConsoleColor.Green )
                    .WriteLine( "\" " );

                this.Languages.Add( language );
            }
        }

        // Get all the script files
        foreach( string file in Directory.GetFiles( App.FullScriptingFolder ) )
        {
            string FileExtension = Path.GetExtension( file );

            ILanguage? lang = this.Languages.Find( e => e.ScriptsExtension() == FileExtension );

            if( lang is null )
                continue;

            ScriptEngine.logger.info
                .Write( "Initializing script " )
                .Write( Path.GetFileName(file), ConsoleColor.Cyan )
                .NewLine();

            Context.Upgrade? context = lang.register_context( file );

            if( context is not null )
            {
                Mods.Add( context );
            }
            else
            {
                ScriptEngine.logger.error
                    .Write( "Got an empty context from " )
                    .Write( lang.GetName(), ConsoleColor.Green )
                    .Write( " for " )
                    .Write( file, ConsoleColor.Cyan )
                    .NewLine();
            }
        }
    }

    public void Shutdown()
    {
        ScriptEngine.logger.debug.WriteLine( "Shutting down" );
        this.Languages.ForEach( a => a.Shutdown() );
    }
}
