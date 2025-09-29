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

public static class App
{
    public static void Main( params string[] args )
    {
        if( args.Length > 0 )
        {
            string file_path = args[0];

            if( File.Exists( file_path ) )
            {
                // We want exceptions to be thrown with this program
                FormatTitles.FormatTitles.Sensitive = true;
                // Does this buffer has been updated in sven?
                FormatTitles.FormatTitles.MaxBufferSize = 512;

                try
                {
                    // Did the user provided a sven titles?
                    if( args.Length > 1 )
                    {
                        FormatTitles.FormatTitles.ExistentTitles = FormatTitles.FormatTitles.ToList( File.ReadAllLines( args[1] ) );
                    }

                    string[] content = File.ReadAllLines( file_path );

                    string file_name = Path.GetFileNameWithoutExtension( file_path );

                    Console.WriteLine( "Writing:" );

                    Console.ForegroundColor = ConsoleColor.Cyan;

                    string ent_path = Path.Combine( Directory.GetCurrentDirectory(), $"{file_name}.ent" );
                    Console.WriteLine( ent_path );
                    File.WriteAllText( ent_path, FormatTitles.FormatTitles.ToEnt( content ) );

                    string json_path = Path.Combine( Directory.GetCurrentDirectory(), $"{file_name}.json" );
                    Console.WriteLine( json_path );
                    File.WriteAllText( json_path, FormatTitles.FormatTitles.ToJson( content ) );

                    FormatTitles.FormatTitles.ExistentTitles = null;
                }
                catch( Exception exception )
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.Write( "Error: " );

                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.Write( exception.Message );

                    Console.ForegroundColor = ConsoleColor.Gray;
                    Console.Write( exception.StackTrace );
                }

                Console.ResetColor();
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.Write( "Error: " );
                Console.ResetColor();

                Console.Write( "File \"" );

                Console.ForegroundColor = ConsoleColor.Green;
                Console.Write( file_path );
                Console.ResetColor();

                Console.WriteLine( "\" Doesn't exists!" );

                Console.WriteLine( "Write the full path to a titles.txt" );
                Console.WriteLine( "Or drag and drop it to the program." );
            }
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Write( "Error: " );
            Console.ResetColor();

            Console.WriteLine( "No arguments provided!" );

            Console.WriteLine( "Write the full path to a titles.txt" );
            Console.WriteLine( "Or drag and drop it to the program." );
        }

#if DEBUG
#else
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine( "Press enter to exit" );
        Console.ResetColor();
        Console.ReadLine();
#endif
    }
}
