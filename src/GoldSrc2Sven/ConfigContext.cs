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

public static class ConfigContext
{
    public static readonly Logger logger = new Logger( "Configuration", ConsoleColor.DarkRed );

    public static void Get( string key, Func<string, bool> validator, string? additional_info = null )
    {
        while( true )
        {
            // Try to use the cached one
            string? value = App.cache.Get<string>( key );

            try
            {
                if( !string.IsNullOrEmpty( value ) && validator( value ) )
                {
                    App.cache.Write();
                    break;
                }
            }
            catch { }

            ConfigContext.logger.warn
                .Write( "Invalid configuration '" )
                .Write( key, ConsoleColor.Green )
                .Write( "'. Please input a valid value:" )
                .NewLine();

            if( additional_info is not null )
            {
                ConfigContext.logger.info.Write( additional_info ).NewLine();
            }

            string? input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) )
            {
                App.cache.data[ key ] = input;
            }
        }
    }
}
