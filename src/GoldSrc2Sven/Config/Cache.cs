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

namespace GoldSrc2Sven.Config;

using Mikk.Cache;

public static class ConfigContext
{
    /// <summary>
    /// Gets a value for the given key. if it doesn't exists we'll ask the user in a loop until validator doesn't throw any exception
    /// </summary>
    public static void UserConfig( this Cache cache, string key, Func<string, bool> validator, string title )
    {
        // Try first to use the defined if any
        string? value = cache.Get<string>( key );

        if( value is null )
        {
            Console.ForegroundColor = ConsoleColor.DarkGreen;
            Console.WriteLine( title );
            Console.ResetColor();

            Console.WriteLine( "Please input a valid value" );

            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write( key );
            Console.ResetColor();

            Console.Write( ": " );
        }

        while( true )
        {
            try
            {
                // If validator didn't throw an exception then is safe to assume everything has been setup propertly.
                if( !string.IsNullOrWhiteSpace( value ) && validator( value ) )
                {
                    cache.data[ key ] = value;
                    cache.Write();
                    break;
                }
            }
            catch ( Exception exception )
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine( "Invalid value" );
                Console.WriteLine( "Error: " );

                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine( exception.Message );
                Console.ResetColor();

                Console.WriteLine( "Please input a valid value" );

                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.Write( key );
                Console.ResetColor();

                Console.Write( ": " );
            }

            Console.BackgroundColor = ConsoleColor.DarkGray;
            Console.ForegroundColor = ConsoleColor.White;

            value = Console.ReadLine();

            Console.ResetColor();

            // Write a line since the user is in the last output
            Console.WriteLine();
        }
    }
}
