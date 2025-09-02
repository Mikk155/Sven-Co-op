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

using System.Linq.Expressions;

public class ContextSelector
{
    private static List<List<UpgradeContext>> SplitIntoPages()
    {
        List<List<UpgradeContext>> Pages = new List<List<UpgradeContext>>(){ new List<UpgradeContext>() };

        int iCount = 0;
        int ListIndex = 0;

        foreach( UpgradeContext context in Program.Upgrader.ScriptEngine.Mods )
        {
            iCount++;

            if( iCount > 7 )
            {
                iCount = 1;
                Pages.Add( new List<UpgradeContext>() );
                ListIndex++;
            }
            Pages[ ListIndex ].Add( context );
        }
        return Pages;
    }

#if false // Idk is messed up
    private static void ClearConsole()
    {
        int left = ContextSelector.menu[0];
        int top = ContextSelector.menu[1];

        for( int i = top; i < Console.WindowHeight; i++ )
        {
            Console.SetCursorPosition( 0, i );
            Console.Write( new string( ' ', Console.WindowWidth ) );
        }

        Console.SetCursorPosition( left, top );
    }
#endif

    private static int[] menu = null!;

    public static List<UpgradeContext> GetContexts()
    {
        // List containing the user's selection
        List<UpgradeContext> UserSelected = new List<UpgradeContext>();

        // Split into pages of 7 contexts each
        List<List<UpgradeContext>> Pages = ContextSelector.SplitIntoPages();

//        Console.BackgroundColor = ConsoleColor.DarkGray;

        ( int Left, int Top ) = Console.GetCursorPosition();
        ContextSelector.menu = [ Left, Top ];

        string? input;

        int CurrentPage = 1;
        int MaxPages = Pages.Count;

        bool DoneSelecting = false;
        while( DoneSelecting is false )
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine( "=== Select the mods you want to install ===" );
            Console.ForegroundColor = ConsoleColor.Cyan;

            List<UpgradeContext> Page = Pages[ CurrentPage - 1 ];

            int CurrentSizeOfProjects = Page.Count;

            for( int i = 0; i < Page.Count; i++ )
            {
                UpgradeContext uc = Page[i];
                Console.WriteLine();

                if( UserSelected.Contains( uc ) )
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine( $" { i + 1 }: {uc.Name} (Selected)" );
                    Console.ForegroundColor = ConsoleColor.Cyan;
                }
                else
                {
                    Console.WriteLine( $" { i + 1 }: {uc.Name}" );
                }

                Console.WriteLine( $"   {uc.Title}" );

                if( !string.IsNullOrEmpty( uc.Description ) )
                {
                    Console.WriteLine( $"      {uc.Description}" );
                }
            }

            Console.WriteLine();

            if( CurrentPage > 1 )
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine( " 8: Previus page" );
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine();
            }

            if( CurrentPage != MaxPages )
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine( " 9: Next page" );
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine();
            }

            if( MaxPages > 1 )
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine( $"=== current page {CurrentPage}/{MaxPages} ===" );
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine();
            }

            if( UserSelected.Count > 0 )
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine( " 0: All Done" );
                Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine();
            }

            input = Console.ReadLine();

            if( !string.IsNullOrEmpty( input ) )
            {
                if( int.TryParse( input, out int result ) )
                {
                    switch( result )
                    {
                        case 0:
                        {
                            if( UserSelected.Count > 0 )
                            {
                                DoneSelecting = true;
                            }
                            break;
                        }
                        case 8:
                        {
                            if( CurrentPage > 1 )
                                CurrentPage--;
                            break;
                        }
                        case 9:
                        {
                            if( CurrentPage < MaxPages )
                                CurrentPage++;
                            break;
                        }
                        default:
                        {
                            if( result <= CurrentSizeOfProjects )
                            {
                                UpgradeContext Selection = Page[ result - 1 ];
                                if( !UserSelected.Contains( Selection ) )
                                {
                                    UserSelected.Add( Selection );
                                }
                                else
                                {
                                    UserSelected.Remove( Selection );
                                }
                            }
                            break;
                        }
                    }
                }
            }

#if false
            if( DoneSelecting is false )
            {
                ContextSelector.ClearConsole();
            }
#endif
        }

        Console.ResetColor();

        return UserSelected;
    }
}
