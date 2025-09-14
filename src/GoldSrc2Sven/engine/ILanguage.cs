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

namespace GoldSrc2Sven.engine;

public interface ILanguage
{
    /// <summary>
    /// Script files extension
    /// </summary>
    /// <returns>".py" for example</returns>
    public string ScriptsExtension();

    /// <summary>
    /// Name of the language
    /// </summary>
    /// <returns></returns>
    public string GetName();

    /// <summary>
    /// Shutdown event called when all the language's scripts are released
    /// </summary>
    public void Shutdown();

    /// <summary>
    /// Registration event called when script file should be called for a context
    /// </summary>
    public Context.Upgrade? register_context( string script );

    /// <summary>
    /// Called when it's time to copy mod assets
    /// </summary>
    public void install_assets( Context.Upgrade context );

    /// <summary>
    /// Called when it's time to update the maps
    /// </summary>
    public void upgrade_map( Context.Map context );
}
