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

public class Logger( string name, ConsoleColor color = ConsoleColor.Black )
{
    public readonly string name = name;
    public readonly ConsoleColor color = color;

    public void warn( string msg )
    {
        Console.BackgroundColor = this.color;
        Console.ForegroundColor = ( this.color != ConsoleColor.Yellow ) ? ConsoleColor.Yellow : ConsoleColor.DarkYellow;
        Console.WriteLine( $"[{this.name}] [Warning] {msg}" );
        Console.ResetColor();
    }

    public void info( string msg )
    {
        Console.BackgroundColor = this.color;
        Console.ForegroundColor = ( this.color != ConsoleColor.Cyan ) ? ConsoleColor.Cyan : ConsoleColor.DarkCyan;
        Console.WriteLine( $"[{this.name}] [Info] {msg}" );
        Console.ResetColor();
    }

    public void error( string msg )
    {
        Console.BackgroundColor = this.color;
        Console.ForegroundColor = ( this.color != ConsoleColor.Red ) ? ConsoleColor.Red : ConsoleColor.DarkRed;
        Console.WriteLine( $"[{this.name}] [Error] {msg}" );
        Console.ResetColor();
    }

    /// <summary>
    ///  Pauses the console and makes a beep sound. if exit is greater than -1 the program exits with that code error
    /// </summary>
    /// <param name="exit">Exit code error</param>
    public void pause( int exit = -1 )
    {
        Console.BackgroundColor = this.color;
        Console.ForegroundColor = ( this.color != ConsoleColor.Green ) ? ConsoleColor.Green : ConsoleColor.DarkGreen;
        Console.WriteLine( "Press Enter to continue." );
        Console.ResetColor();
        Console.Beep();
        Console.ReadLine();

        if( exit >= 0 )
        {
            // Shutdown everything on chain
            if( Program.Upgrader is not null )
            {
                Program.Upgrader.Shutdown();
            }

            Environment.Exit( exit );
        }
    }
}
