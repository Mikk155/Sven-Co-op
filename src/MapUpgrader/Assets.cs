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

public class Assets()
{
    public static readonly Logger logger = new Logger( "Assets" );

    public List<string> AssetList = new List<string>();
    public Dictionary<string, string> AssetDict = new Dictionary<string, string>();

    /// <summary>Copy over an asset to the workspace directory, if target is provided the relative path will be overriden</summary>
    public void Copy( string src, string? target = null )
    {
        if( string.IsNullOrWhiteSpace( target ) )
        {
            Assets.logger.trace
                .Write( "Copying asset \"" )
                .Write( src, ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine();

            AssetList.Add( src );
        }
        else
        {
            Assets.logger.trace
                .Write( "Copying asset \"" )
                .Write( src, ConsoleColor.Cyan )
                .Write( "\" to directory \"" )
                .Write( target, ConsoleColor.Cyan )
                .Write( "\"" )
                .NewLine();

            AssetDict[ src ] = target;
        }
    }
}
